/// Árvore sintática de um lado da igualdade.
sealed class Node {
  const Node();
}

/// Número formado por um ou mais dígitos vizinhos (ex.: 2, 28, 812).
class NumberNode extends Node {
  final int value;
  final String text;
  const NumberNode(this.value, this.text);
}

/// Parênteses escritos pelo jogador (mantidos para o LaTeX ficar fiel).
class ParenNode extends Node {
  final Node child;
  const ParenNode(this.child);
}

enum UnaryOp { negate, sqrt, cbrt, factorial, abs, floor, ceil }

class UnaryNode extends Node {
  final UnaryOp op;
  final Node child;
  const UnaryNode(this.op, this.child);
}

enum BinaryOp { add, subtract, multiply, divide, power }

class BinaryNode extends Node {
  final BinaryOp op;
  final Node left;
  final Node right;
  const BinaryNode(this.op, this.left, this.right);
}

/// Igualdade completa: lado esquerdo = lado direito.
class Equation {
  final Node left;
  final Node right;
  const Equation(this.left, this.right);
}
