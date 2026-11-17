/// Tipos de peça que podem aparecer numa expressão.
enum TokenKind {
  digit,
  plus,
  minus,
  times,
  divide,
  power,
  sqrt,
  cbrt,
  factorial,
  lParen,
  rParen,
  absOpen,
  absClose,
  floorOpen,
  floorClose,
  ceilOpen,
  ceilClose,
  equals,
}

/// Uma peça da expressão: um dígito ou um operador.
class Token {
  final TokenKind kind;

  /// Valor do dígito (0–9) quando [kind] é [TokenKind.digit].
  final int? digit;

  const Token(this.kind) : digit = null;
  const Token.digit(int value)
      : kind = TokenKind.digit,
        digit = value;

  /// Símbolo exibido na interface (fórmula "crua", acima do LaTeX).
  String get symbol => kind == TokenKind.digit ? '$digit' : symbolOf(kind);

  static String symbolOf(TokenKind kind) => switch (kind) {
        TokenKind.digit => '#',
        TokenKind.plus => '+',
        TokenKind.minus => '−',
        TokenKind.times => '×',
        TokenKind.divide => '÷',
        TokenKind.power => '**',
        TokenKind.sqrt => '√',
        TokenKind.cbrt => '∛',
        TokenKind.factorial => '!',
        TokenKind.lParen => '(',
        TokenKind.rParen => ')',
        TokenKind.absOpen => '|',
        TokenKind.absClose => '|',
        TokenKind.floorOpen => '⌊',
        TokenKind.floorClose => '⌋',
        TokenKind.ceilOpen => '⌈',
        TokenKind.ceilClose => '⌉',
        TokenKind.equals => '=',
      };

  /// Rótulo usado na roda de operadores (deixa claro abertura x fechamento).
  static String wheelLabelOf(TokenKind kind) => switch (kind) {
        TokenKind.absOpen => '|x',
        TokenKind.absClose => 'x|',
        TokenKind.floorOpen => '⌊x',
        TokenKind.floorClose => 'x⌋',
        TokenKind.ceilOpen => '⌈x',
        TokenKind.ceilClose => 'x⌉',
        TokenKind.factorial => 'x!',
        TokenKind.sqrt => '√x',
        TokenKind.cbrt => '∛x',
        TokenKind.power => 'xʸ',
        _ => symbolOf(kind),
      };

  /// Operadores binários (ficam no anel interno da roda).
  static const binaryKinds = {
    TokenKind.plus,
    TokenKind.minus,
    TokenKind.times,
    TokenKind.divide,
    TokenKind.power,
  };

  @override
  bool operator ==(Object other) => other is Token && other.kind == kind && other.digit == digit;

  @override
  int get hashCode => Object.hash(kind, digit);

  @override
  String toString() => symbol;

  /// Serialização simples para salvar no SharedPreferences.
  String encode() => kind == TokenKind.digit ? 'd$digit' : kind.name;

  static Token decode(String s) {
    if (s.startsWith('d') && s.length == 2) return Token.digit(int.parse(s.substring(1)));
    return Token(TokenKind.values.byName(s));
  }
}
