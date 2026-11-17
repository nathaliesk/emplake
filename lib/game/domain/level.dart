import '../engine/token.dart';

/// Níveis de jogo e os operadores permitidos em cada um (requisito do enunciado).
enum Level {
  easy(
    points: 1,
    allowsNonIntegerDivision: true,
    operators: {
      TokenKind.plus, TokenKind.minus, TokenKind.times, TokenKind.divide,
      TokenKind.lParen, TokenKind.rParen, TokenKind.sqrt, TokenKind.cbrt,
      TokenKind.factorial, TokenKind.power, TokenKind.absOpen, TokenKind.absClose,
      TokenKind.floorOpen, TokenKind.floorClose, TokenKind.ceilOpen, TokenKind.ceilClose,
    },
  ),
  intermediate(
    points: 2,
    allowsNonIntegerDivision: false,
    operators: {
      TokenKind.plus, TokenKind.minus, TokenKind.times, TokenKind.divide,
      TokenKind.lParen, TokenKind.rParen, TokenKind.sqrt, TokenKind.cbrt,
      TokenKind.factorial, TokenKind.power, TokenKind.absOpen, TokenKind.absClose,
    },
  ),
  advanced(
    points: 3,
    allowsNonIntegerDivision: false,
    operators: {
      TokenKind.plus, TokenKind.minus, TokenKind.times, TokenKind.divide,
      TokenKind.lParen, TokenKind.rParen, TokenKind.sqrt, TokenKind.factorial,
      TokenKind.absOpen, TokenKind.absClose,
    },
  ),
  hard(
    points: 5,
    allowsNonIntegerDivision: false,
    operators: {
      TokenKind.plus, TokenKind.minus, TokenKind.times, TokenKind.divide,
      TokenKind.lParen, TokenKind.rParen, TokenKind.absOpen, TokenKind.absClose,
    },
  );

  const Level({
    required this.points,
    required this.allowsNonIntegerDivision,
    required this.operators,
  });

  /// Pontos ganhos ao resolver um número neste nível.
  final int points;

  /// Só o nível Fácil aceita divisão (e raiz) com resultado não inteiro.
  final bool allowsNonIntegerDivision;

  /// Operadores disponíveis (o "=" está sempre disponível).
  final Set<TokenKind> operators;

  bool allows(TokenKind kind) =>
      kind == TokenKind.digit || kind == TokenKind.equals || operators.contains(kind);

  /// Ordem de exibição dos operadores na roda.
  List<TokenKind> get orderedOperators =>
      TokenKind.values.where((k) => operators.contains(k)).toList();
}
