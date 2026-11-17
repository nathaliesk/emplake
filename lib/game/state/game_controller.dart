import 'dart:async';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/firestore_repository.dart';
import '../../settings/settings_controller.dart';
import '../../sound/sound_service.dart';
import '../domain/level.dart';
import '../domain/plates.dart';
import '../engine/errors.dart';
import '../engine/evaluator.dart';
import '../engine/latex.dart';
import '../engine/solver.dart';
import '../engine/token.dart';

enum RoundStatus { loading, playing, success, error, exhausted }

/// Índice especial da "fenda" logo à direita do sinal de =.
const afterEqualsZone = 5;

@immutable
class GameState {
  final Level level;
  final int? number;
  final RoundStatus status;

  /// Fendas 0..4: antes do 1º dígito, entre os dígitos e depois do 4º.
  final List<List<Token>> zones;

  /// Operadores à direita do "=" (na mesma fenda em que ele está).
  final List<Token> afterEquals;

  /// Em qual fenda (1..3) está o "=".
  final int equalsGap;

  final int score;
  final EvalErrorCode? error;
  final String? errorLeft;
  final String? errorRight;

  /// Muda a cada erro; a placa "treme" quando ele muda.
  final int errorTick;

  /// `true` enquanto os operadores voltam para a roda (animação pós-acerto).
  final bool returning;
  final int lastPoints;
  final bool saveFailed;
  final DateTime startedAt;

  /// Expressão do último acerto (para mostrar no cartão de sucesso).
  final String? solvedLatex;

  const GameState({
    required this.level,
    this.number,
    this.status = RoundStatus.loading,
    this.zones = const [[], [], [], [], []],
    this.afterEquals = const [],
    this.equalsGap = 2,
    this.score = 0,
    this.error,
    this.errorLeft,
    this.errorRight,
    this.errorTick = 0,
    this.returning = false,
    this.lastPoints = 0,
    this.saveFailed = false,
    required this.startedAt,
    this.solvedLatex,
  });

  List<int> get digits {
    final n = number ?? 0;
    return n.toString().padLeft(4, '0').split('').map(int.parse).toList();
  }

  Plate get plate => Plate.forNumber(number ?? 0, level);

  List<Token> zone(int index) => index == afterEqualsZone ? afterEquals : zones[index];

  bool get hasOperators => zones.any((z) => z.isNotEmpty) || afterEquals.isNotEmpty;

  /// Expressão completa, na ordem: fenda, dígito, fenda, dígito... com o "=".
  List<Token> get tokens {
    final out = <Token>[];
    final d = digits;
    for (var i = 0; i < 5; i++) {
      out.addAll(zones[i]);
      if (i == equalsGap) {
        out.add(const Token(TokenKind.equals));
        out.addAll(afterEquals);
      }
      if (i < 4) out.add(Token.digit(d[i]));
    }
    return out;
  }

  String get latex => LatexBuilder.fromTokens(tokens);
  String get expression => tokens.map((t) => t.symbol).join(' ');

  GameState copyWith({
    Level? level,
    int? number,
    RoundStatus? status,
    List<List<Token>>? zones,
    List<Token>? afterEquals,
    int? equalsGap,
    int? score,
    EvalErrorCode? error,
    bool clearError = false,
    String? errorLeft,
    String? errorRight,
    int? errorTick,
    bool? returning,
    int? lastPoints,
    bool? saveFailed,
    DateTime? startedAt,
    String? solvedLatex,
  }) =>
      GameState(
        level: level ?? this.level,
        number: number ?? this.number,
        status: status ?? this.status,
        zones: zones ?? this.zones,
        afterEquals: afterEquals ?? this.afterEquals,
        equalsGap: equalsGap ?? this.equalsGap,
        score: score ?? this.score,
        error: clearError ? null : (error ?? this.error),
        errorLeft: clearError ? null : (errorLeft ?? this.errorLeft),
        errorRight: clearError ? null : (errorRight ?? this.errorRight),
        errorTick: errorTick ?? this.errorTick,
        returning: returning ?? this.returning,
        lastPoints: lastPoints ?? this.lastPoints,
        saveFailed: saveFailed ?? this.saveFailed,
        startedAt: startedAt ?? this.startedAt,
        solvedLatex: solvedLatex ?? this.solvedLatex,
      );
}

/// Regras e fluxo de uma partida (Riverpod Notifier).
class GameController extends Notifier<GameState> {
  final _random = Random();
  final Map<Level, Set<int>> _solved = {};
  final Map<Level, Solver> _solvers = {};
  bool _scoreLoaded = false;

  static const _kCurrent = 'game.current.';

  @override
  GameState build() {
    final level = ref.read(settingsProvider).level;
    return GameState(level: level, startedAt: DateTime.now());
  }

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;
  FirestoreRepository get _repo => ref.read(firestoreRepositoryProvider);
  SoundService get _sound => ref.read(soundProvider);
  Solver _solver(Level l) => _solvers.putIfAbsent(l, () => Solver(l));

  /// Carrega pontuação e placas resolvidas do Firestore e sorteia a primeira.
  /// Usado pelo FutureBuilder da tela de jogo.
  Future<void> ensureLoaded() async {
    if (state.number != null && _solved.containsKey(state.level)) return;
    final uid = _uid;
    if (uid != null && !_scoreLoaded) {
      final score = await _repo.score(uid);
      _scoreLoaded = true;
      state = state.copyWith(score: score);
    }
    await _loadSolved(state.level);
    _startRound(preferSaved: true);
  }

  Future<void> _loadSolved(Level level) async {
    if (_solved.containsKey(level)) return;
    final uid = _uid;
    _solved[level] = uid == null ? <int>{} : await _repo.solvedNumbers(uid, level);
  }

  Future<void> setLevel(Level level) async {
    if (level == state.level) return;
    ref.read(settingsProvider.notifier).setLevel(level);
    state = state.copyWith(level: level, status: RoundStatus.loading, clearError: true);
    await _loadSolved(level);
    _startRound(preferSaved: true);
  }

  /// Sorteia um número que tem solução no nível e que o jogador ainda não resolveu.
  void _startRound({bool preferSaved = false}) {
    final level = state.level;
    final solved = _solved[level] ?? <int>{};
    final prefs = ref.read(sharedPreferencesProvider);

    int? chosen;
    if (preferSaved) {
      final saved = prefs.getInt('$_kCurrent${level.name}');
      if (saved != null && !solved.contains(saved)) chosen = saved;
    }
    final solver = _solver(level);
    for (var i = 0; chosen == null && i < 800; i++) {
      final n = _random.nextInt(10000);
      if (n == state.number || solved.contains(n)) continue;
      if (solver.isSolvable(n)) chosen = n;
    }
    if (chosen == null) {
      state = state.copyWith(status: RoundStatus.exhausted, clearError: true);
      return;
    }
    prefs.setInt('$_kCurrent${level.name}', chosen);
    state = GameState(
      level: level,
      number: chosen,
      status: RoundStatus.playing,
      score: state.score,
      errorTick: state.errorTick,
      startedAt: DateTime.now(),
    );
  }

  void addToken(int zone, TokenKind kind) {
    if (!_editable) return;
    _sound.play(Sfx.tap);
    _updateZone(zone, (z) => [...z, Token(kind)]);
  }

  void backspace(int zone) {
    if (!_editable) return;
    _updateZone(zone, (z) => z.isEmpty ? z : z.sublist(0, z.length - 1));
  }

  void clearZone(int zone) {
    if (!_editable) return;
    _updateZone(zone, (_) => const []);
  }

  void clearAll() {
    if (!_editable) return;
    state = state.copyWith(
      zones: const [[], [], [], [], []],
      afterEquals: const [],
      status: RoundStatus.playing,
      clearError: true,
    );
  }

  /// Move o "=" uma fenda para a esquerda (-1) ou direita (+1).
  /// O que estava à direita do "=" fica na fenda antiga.
  void moveEquals(int delta) {
    if (!_editable) return;
    final target = state.equalsGap + delta;
    if (target < 1 || target > 3) return;
    final zones = [for (final z in state.zones) List<Token>.of(z)];
    zones[state.equalsGap].addAll(state.afterEquals);
    state = state.copyWith(
      zones: zones,
      afterEquals: const [],
      equalsGap: target,
      status: RoundStatus.playing,
      clearError: true,
    );
  }

  bool get _editable =>
      !state.returning &&
      (state.status == RoundStatus.playing || state.status == RoundStatus.error);

  void _updateZone(int zone, List<Token> Function(List<Token>) change) {
    if (zone == afterEqualsZone) {
      state = state.copyWith(
        afterEquals: change(state.afterEquals),
        status: RoundStatus.playing,
        clearError: true,
      );
      return;
    }
    final zones = [for (final z in state.zones) List<Token>.of(z)];
    zones[zone] = change(zones[zone]);
    state = state.copyWith(zones: zones, status: RoundStatus.playing, clearError: true);
  }

  /// Confere a igualdade. Se estiver certa, salva no Firestore e soma pontos.
  Future<void> verify() async {
    if (!_editable || state.number == null) return;
    final tokens = state.tokens;
    final evaluator = Evaluator(state.level);
    try {
      final result = evaluator.check(tokens);
      if (!result.isCorrect) {
        _fail(EvalErrorCode.notEqual, result.left.display(), result.right.display());
        return;
      }
    } on EvalException catch (e) {
      _fail(e.code);
      return;
    }
    await _succeed();
  }

  void _fail(EvalErrorCode code, [String? left, String? right]) {
    _sound.play(Sfx.error);
    state = state.copyWith(
      status: RoundStatus.error,
      error: code,
      errorLeft: left,
      errorRight: right,
      errorTick: state.errorTick + 1,
    );
  }

  Future<void> _succeed() async {
    final s = state;
    final number = s.number!;
    final seconds = DateTime.now().difference(s.startedAt).inSeconds;
    final points = s.level.points;
    _sound.play(Sfx.success);
    _solved.putIfAbsent(s.level, () => <int>{}).add(number);

    // Operadores "voltam para a roda": a interface anima enquanto returning = true.
    state = s.copyWith(
      status: RoundStatus.success,
      score: s.score + points,
      lastPoints: points,
      returning: true,
      saveFailed: false,
      solvedLatex: s.latex,
      clearError: true,
    );
    Timer(const Duration(milliseconds: 750), () {
      if (state.number == number && state.status == RoundStatus.success) {
        state = state.copyWith(
          zones: const [[], [], [], [], []],
          afterEquals: const [],
          equalsGap: 2,
          returning: false,
        );
      }
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      await _repo.saveSolved(
        user,
        SolvedEntry(
          number: number,
          level: s.level,
          expression: s.expression,
          latex: s.latex,
          seconds: seconds,
        ),
      );
    } catch (e) {
      debugPrint('Erro ao salvar no Firestore: $e');
      if (state.number == number) state = state.copyWith(saveFailed: true);
    }
  }

  /// Próxima placa depois de um acerto.
  void next() => _startRound();

  /// Pula a placa atual (sem pontos).
  void skip() {
    if (state.status == RoundStatus.loading) return;
    _sound.play(Sfx.skip);
    _startRound();
  }
}

final gameProvider = NotifierProvider<GameController, GameState>(GameController.new);
