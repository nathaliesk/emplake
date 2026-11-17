import 'ast.dart';
import 'parser.dart';
import 'token.dart';

/// Converte expressões para LaTeX (renderizado com flutter_math_fork).
class LatexBuilder {
  const LatexBuilder._();

  /// LaTeX da igualdade. Se a expressão ainda estiver incompleta, faz uma
  /// tradução peça a peça para o jogador ver o que está montando.
  static String fromTokens(List<Token> tokens) {
    if (tokens.isEmpty) return r'\square';
    try {
      final eq = Parser.parseEquation(tokens);
      return '${fromNode(eq.left)} = ${fromNode(eq.right)}';
    } catch (_) {
      return _fallback(tokens);
    }
  }

  static String fromNode(Node node) => switch (node) {
        NumberNode(:final text) => text,
        ParenNode(:final child) => r'\left(' '${fromNode(child)}' r'\right)',
        UnaryNode(:final op, :final child) => _unary(op, child),
        BinaryNode(:final op, :final left, :final right) => _binary(op, left, right),
      };

  /// Remove um par de parênteses externo quando ele já está implícito
  /// no LaTeX (ex.: √(8+1) vira \sqrt{8+1}).
  static String _inner(Node n) => n is ParenNode ? fromNode(n.child) : fromNode(n);

  static String _unary(UnaryOp op, Node child) => switch (op) {
        UnaryOp.negate => '-${fromNode(child)}',
        UnaryOp.sqrt => '\\sqrt{${_inner(child)}}',
        UnaryOp.cbrt => '\\sqrt[3]{${_inner(child)}}',
        UnaryOp.factorial => '${fromNode(child)}!',
        UnaryOp.abs => '\\left|${fromNode(child)}\\right|',
        UnaryOp.floor => '\\left\\lfloor ${fromNode(child)} \\right\\rfloor',
        UnaryOp.ceil => '\\left\\lceil ${fromNode(child)} \\right\\rceil',
      };

  static String _binary(BinaryOp op, Node l, Node r) => switch (op) {
        BinaryOp.add => '${fromNode(l)} + ${fromNode(r)}',
        BinaryOp.subtract => '${fromNode(l)} - ${fromNode(r)}',
        BinaryOp.multiply => '${fromNode(l)} \\times ${fromNode(r)}',
        BinaryOp.divide => '${fromNode(l)} \\div ${fromNode(r)}',
        BinaryOp.power => '{${fromNode(l)}}^{${_inner(r)}}',
      };

  static String _fallback(List<Token> tokens) {
    final b = StringBuffer();
    for (final t in tokens) {
      b.write(switch (t.kind) {
        TokenKind.digit => '${t.digit}',
        TokenKind.plus => ' + ',
        TokenKind.minus => ' - ',
        TokenKind.times => r' \times ',
        TokenKind.divide => r' \div ',
        TokenKind.power => r'^{\square}',
        TokenKind.sqrt => r'\sqrt{\,}',
        TokenKind.cbrt => r'\sqrt[3]{\,}',
        TokenKind.factorial => '!',
        TokenKind.lParen => '(',
        TokenKind.rParen => ')',
        TokenKind.absOpen || TokenKind.absClose => r'\vert ',
        TokenKind.floorOpen => r'\lfloor ',
        TokenKind.floorClose => r'\rfloor ',
        TokenKind.ceilOpen => r'\lceil ',
        TokenKind.ceilClose => r'\rceil ',
        TokenKind.equals => ' = ',
      });
    }
    return b.toString();
  }
}
