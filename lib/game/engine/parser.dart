import 'ast.dart';
import 'errors.dart';
import 'token.dart';

/// Analisador sintático por descida recursiva.
///
/// Gramática (da menor para a maior precedência):
/// ```
/// expr    := term (('+' | '−') term)*
/// term    := unary (('×' | '÷') unary)*
/// unary   := '−' unary | power
/// power   := prefix ('**' unary)?          // associativo à direita
/// prefix  := ('√' | '∛') prefix | '−' prefix | postfix
/// postfix := primary '!'*
/// primary := digitos | '(' expr ')' | '|' expr '|' | '⌊' expr '⌋' | '⌈' expr '⌉'
/// ```
/// Dígitos vizinhos sem operador entre eles formam um número só (2 8 → 28).
class Parser {
  final List<Token> _tokens;
  final int _offset;
  int _pos = 0;

  Parser._(this._tokens, this._offset);

  /// Analisa a igualdade inteira (precisa ter exatamente um "=").
  static Equation parseEquation(List<Token> tokens) {
    final equalsAt = <int>[];
    for (var i = 0; i < tokens.length; i++) {
      if (tokens[i].kind == TokenKind.equals) equalsAt.add(i);
    }
    if (equalsAt.isEmpty) throw const EvalException(EvalErrorCode.missingEquals);
    if (equalsAt.length > 1) {
      throw EvalException(EvalErrorCode.multipleEquals, equalsAt[1]);
    }
    final e = equalsAt.first;
    final left = parseSide(tokens.sublist(0, e), 0);
    final right = parseSide(tokens.sublist(e + 1), e + 1);
    return Equation(left, right);
  }

  /// Analisa um lado. [offset] serve só para reportar a posição do erro.
  static Node parseSide(List<Token> tokens, [int offset = 0]) {
    if (tokens.isEmpty) throw EvalException(EvalErrorCode.emptySide, offset);
    final p = Parser._(tokens, offset);
    final node = p._expr();
    if (!p._atEnd) {
      final kind = p._peek!.kind;
      final closing = kind == TokenKind.rParen ||
          kind == TokenKind.absClose ||
          kind == TokenKind.floorClose ||
          kind == TokenKind.ceilClose;
      throw EvalException(
        closing ? EvalErrorCode.unbalanced : EvalErrorCode.unexpectedToken,
        offset + p._pos,
      );
    }
    return node;
  }

  bool get _atEnd => _pos >= _tokens.length;
  Token? get _peek => _atEnd ? null : _tokens[_pos];
  bool _check(TokenKind k) => !_atEnd && _tokens[_pos].kind == k;

  Token _advance() => _tokens[_pos++];

  Node _expr() {
    var left = _term();
    while (_check(TokenKind.plus) || _check(TokenKind.minus)) {
      final op = _advance().kind == TokenKind.plus ? BinaryOp.add : BinaryOp.subtract;
      left = BinaryNode(op, left, _term());
    }
    return left;
  }

  Node _term() {
    var left = _unary();
    while (_check(TokenKind.times) || _check(TokenKind.divide)) {
      final op = _advance().kind == TokenKind.times ? BinaryOp.multiply : BinaryOp.divide;
      left = BinaryNode(op, left, _unary());
    }
    return left;
  }

  Node _unary() {
    if (_check(TokenKind.minus)) {
      _advance();
      return UnaryNode(UnaryOp.negate, _unary());
    }
    return _power();
  }

  Node _power() {
    final base = _prefix();
    if (_check(TokenKind.power)) {
      _advance();
      return BinaryNode(BinaryOp.power, base, _unary());
    }
    return base;
  }

  Node _prefix() {
    if (_check(TokenKind.sqrt)) {
      _advance();
      return UnaryNode(UnaryOp.sqrt, _prefix());
    }
    if (_check(TokenKind.cbrt)) {
      _advance();
      return UnaryNode(UnaryOp.cbrt, _prefix());
    }
    if (_check(TokenKind.minus)) {
      _advance();
      return UnaryNode(UnaryOp.negate, _prefix());
    }
    return _postfix();
  }

  Node _postfix() {
    var node = _primary();
    while (_check(TokenKind.factorial)) {
      _advance();
      node = UnaryNode(UnaryOp.factorial, node);
    }
    return node;
  }

  Node _primary() {
    if (_atEnd) throw EvalException(EvalErrorCode.unexpectedEnd, _offset + _pos);
    final t = _peek!;
    switch (t.kind) {
      case TokenKind.digit:
        final buffer = StringBuffer();
        while (_check(TokenKind.digit)) {
          buffer.write(_advance().digit);
        }
        final text = buffer.toString();
        return NumberNode(int.parse(text), text);
      case TokenKind.lParen:
        _advance();
        final inner = _expr();
        _expect(TokenKind.rParen);
        return ParenNode(inner);
      case TokenKind.absOpen:
        _advance();
        final inner = _expr();
        _expect(TokenKind.absClose);
        return UnaryNode(UnaryOp.abs, inner);
      case TokenKind.floorOpen:
        _advance();
        final inner = _expr();
        _expect(TokenKind.floorClose);
        return UnaryNode(UnaryOp.floor, inner);
      case TokenKind.ceilOpen:
        _advance();
        final inner = _expr();
        _expect(TokenKind.ceilClose);
        return UnaryNode(UnaryOp.ceil, inner);
      case TokenKind.rParen:
      case TokenKind.absClose:
      case TokenKind.floorClose:
      case TokenKind.ceilClose:
        throw EvalException(EvalErrorCode.unbalanced, _offset + _pos);
      default:
        throw EvalException(EvalErrorCode.unexpectedToken, _offset + _pos);
    }
  }

  void _expect(TokenKind kind) {
    if (_check(kind)) {
      _advance();
      return;
    }
    throw EvalException(EvalErrorCode.unbalanced, _offset + _pos);
  }
}
