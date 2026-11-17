import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../game/domain/level.dart';

/// Uma placa resolvida pelo jogador.
class SolvedEntry {
  final int number;
  final Level level;
  final String expression;
  final String latex;
  final int seconds;
  final DateTime? solvedAt;

  const SolvedEntry({
    required this.number,
    required this.level,
    required this.expression,
    required this.latex,
    required this.seconds,
    this.solvedAt,
  });

  factory SolvedEntry.fromMap(Map<String, dynamic> m) => SolvedEntry(
        number: (m['number'] as num?)?.toInt() ?? 0,
        level: Level.values.asNameMap()[m['level']] ?? Level.easy,
        expression: m['expression'] as String? ?? '',
        latex: m['latex'] as String? ?? '',
        seconds: (m['seconds'] as num?)?.toInt() ?? 0,
        solvedAt: (m['solvedAt'] as Timestamp?)?.toDate(),
      );
}

class UserStats {
  final int score;
  final Map<Level, int> solvedByLevel;
  final List<SolvedEntry> recent;

  const UserStats({required this.score, required this.solvedByLevel, required this.recent});

  int get totalSolved => solvedByLevel.values.fold(0, (a, b) => a + b);
}

class RankingEntry {
  final String uid;
  final String name;
  final int score;
  const RankingEntry(this.uid, this.name, this.score);
}

/// Acesso ao Firestore.
///
/// Estrutura:
/// ```
/// users/{uid}                       nome, email, score, solved.{nivel}
/// users/{uid}/solved/{nivel_numero} number, level, expression, latex, seconds, solvedAt
/// ranking/{uid}                     name, score
/// ```
class FirestoreRepository {
  FirestoreRepository(this._db);
  final FirebaseFirestore _db;

  DocumentReference<Map<String, dynamic>> _user(String uid) => _db.collection('users').doc(uid);
  CollectionReference<Map<String, dynamic>> _solved(String uid) => _user(uid).collection('solved');

  static String solvedId(Level level, int number) =>
      '${level.name}_${number.toString().padLeft(4, '0')}';

  /// Números já resolvidos pelo jogador neste nível.
  Future<Set<int>> solvedNumbers(String uid, Level level) async {
    final snap = await _solved(uid).where('level', isEqualTo: level.name).get();
    return {for (final d in snap.docs) (d.data()['number'] as num).toInt()};
  }

  Future<int> score(String uid) async {
    final doc = await _user(uid).get();
    return (doc.data()?['score'] as num?)?.toInt() ?? 0;
  }

  /// Salva o acerto e soma os pontos (no perfil e no ranking) numa só operação.
  Future<void> saveSolved(User user, SolvedEntry entry) async {
    final ref = _solved(user.uid).doc(solvedId(entry.level, entry.number));
    final name = _displayName(user);
    final batch = _db.batch()
      ..set(ref, {
        'number': entry.number,
        'level': entry.level.name,
        'expression': entry.expression,
        'latex': entry.latex,
        'seconds': entry.seconds,
        'solvedAt': FieldValue.serverTimestamp(),
      })
      ..set(
        _user(user.uid),
        {
          'name': name,
          'email': user.email,
          'score': FieldValue.increment(entry.level.points),
          'solved': {entry.level.name: FieldValue.increment(1)},
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      )
      ..set(
        _db.collection('ranking').doc(user.uid),
        {'name': name, 'score': FieldValue.increment(entry.level.points)},
        SetOptions(merge: true),
      );
    await batch.commit();
  }

  Future<UserStats> stats(String uid) async {
    final results = await Future.wait([
      _user(uid).get(),
      _solved(uid).orderBy('solvedAt', descending: true).limit(30).get(),
    ]);
    final userDoc = results[0] as DocumentSnapshot<Map<String, dynamic>>;
    final recent = results[1] as QuerySnapshot<Map<String, dynamic>>;
    final data = userDoc.data() ?? {};
    final solvedMap = (data['solved'] as Map<String, dynamic>?) ?? {};
    return UserStats(
      score: (data['score'] as num?)?.toInt() ?? 0,
      solvedByLevel: {
        for (final l in Level.values) l: (solvedMap[l.name] as num?)?.toInt() ?? 0,
      },
      recent: recent.docs.map((d) => SolvedEntry.fromMap(d.data())).toList(),
    );
  }

  Future<List<RankingEntry>> ranking({int limit = 20}) async {
    final snap =
        await _db.collection('ranking').orderBy('score', descending: true).limit(limit).get();
    return snap.docs
        .map((d) => RankingEntry(
              d.id,
              d.data()['name'] as String? ?? '',
              (d.data()['score'] as num?)?.toInt() ?? 0,
            ))
        .toList();
  }

  static String _displayName(User user) {
    final n = user.displayName;
    if (n != null && n.trim().isNotEmpty) return n.trim();
    final email = user.email;
    if (email != null && email.contains('@')) return email.split('@').first;
    return '';
  }
}

final firestoreRepositoryProvider =
    Provider<FirestoreRepository>((ref) => FirestoreRepository(FirebaseFirestore.instance));

/// Usuário logado (Riverpod escuta o stream do Firebase Auth).
final authUserProvider = StreamProvider<User?>((ref) => FirebaseAuth.instance.authStateChanges());
