import 'dart:math' as math;

import '../domain/level.dart';
import 'ast.dart';
import 'errors.dart';
import 'parser.dart';
import 'rational.dart';
import 'token.dart';

/// Valor de uma expressão: exato (racional) ou aproximado (só no Fácil,
/// quando aparece uma raiz não exata, como √2).
sealed class Value {
  const Value();
  double get asDouble;
  bool get isExactInteger => false;

  /// Igualdade: exata entre racionais; com tolerância quando há aproximação.
  bool sameAs(Value other) {
    if (this is Exact && other is Exact) {
      return (this as Exact).value == other.value;
    }
    final a = asDouble, b = other.asDouble;
    return (a - b).abs() <= 1e-9 * math.max(1.0, math.max(a.abs(), b.abs()));
  }

  /// Texto curto para mostrar ao jogador (ex.: "3", "5/2", "≈ 1.4142").
  String display();
}

class Exact extends Value {
  final Rational value;
  const Exact(this.value);
  @override
  double get asDouble => value.toDouble();
  @override
  bool get isExactInteger => value.isInteger;
  @override
  String display() => value.toString();
}

class Approx extends Value {
  final double value;
  const Approx(this.value);
  @override
  double get asDouble => value;
  @override
  String display() => '≈ ${value.toStringAsFixed(4)}';
}

/// Resultado de verificar uma igualdade.
class CheckResult {
  final Value left;
  final Value right;
  bool get isCorrect => left.sameAs(right);
  const CheckResult(this.left, this.right);
}

/// Calcula expressões respeitando as regras do nível.
class Evaluator {
  final Level level;
  const Evaluator(this.level);

  /// Limite de dígitos de qualquer resultado intermediário.
  static const maxDigits = 18;

  /// Maior fatorial aceito (20! ainda cabe em 64 bits).
  static const maxFactorial = 20;

  /// Verifica a igualdade montada pelo jogador.
  CheckResult check(List<Token> tokens) {
    for (var i = 0; i < tokens.length; i++) {
      if (!level.allows(tokens[i].kind)) {
        throw EvalException(EvalErrorCode.operatorNotAllowed, i);
      }
    }
    final eq = Parser.parseEquation(tokens);
    return CheckResult(evaluate(eq.left), evaluate(eq.right));
  }

  Value evaluate(Node node) => switch (node) {
        NumberNode(:final value) => Exact(Rational.fromInt(value)),
        ParenNode(:final child) => evaluate(child),
        UnaryNode(:final op, :final child) => _unary(op, evaluate(child)),
        BinaryNode(:final op, :final left, :final right) =>
          _binary(op, evaluate(left), evaluate(right)),
      };

  Value _unary(UnaryOp op, Value v) {
    switch (op) {
      case UnaryOp.negate:
        return v is Exact ? Exact(-v.value) : Approx(-v.asDouble);
      case UnaryOp.abs:
        return v is Exact ? Exact(v.value.abs()) : Approx(v.asDouble.abs());
      case UnaryOp.floor:
        if (v is Exact) return Exact(Rational(v.value.floor()));
        return Exact(Rational.fromInt((v.asDouble + 1e-12).floor()));
      case UnaryOp.ceil:
        if (v is Exact) return Exact(Rational(v.value.ceil()));
        return Exact(Rational.fromInt((v.asDouble - 1e-12).ceil()));
      case UnaryOp.sqrt:
        return _root(v, 2);
      case UnaryOp.cbrt:
        return _root(v, 3);
      case UnaryOp.factorial:
        return _factorial(v);
    }
  }

  Value _root(Value v, int k) {
    if (k.isEven && v.asDouble < 0) throw const EvalException(EvalErrorCode.negativeRoot);
    if (v is Exact) {
      final r = v.value.exactRoot(k);
      if (r != null) return Exact(r);
    }
    if (!level.allowsNonIntegerDivision) throw const EvalException(EvalErrorCode.inexactRoot);
    final d = v.asDouble;
    final root = k == 2 ? math.sqrt(d) : (d < 0 ? -math.pow(-d, 1 / 3) : math.pow(d, 1 / 3));
    return Approx(root.toDouble());
  }

  Value _factorial(Value v) {
    int n;
    if (v is Exact) {
      if (!v.value.isInteger || v.value.isNegative) {
        throw const EvalException(EvalErrorCode.invalidFactorial);
      }
      if (v.value.compareTo(Rational.fromInt(maxFactorial)) > 0) {
        throw const EvalException(EvalErrorCode.factorialTooLarge);
      }
      n = v.value.numerator.toInt();
    } else {
      final d = v.asDouble;
      final rounded = d.roundToDouble();
      if ((d - rounded).abs() > 1e-9 || rounded < 0) {
        throw const EvalException(EvalErrorCode.invalidFactorial);
      }
      if (rounded > maxFactorial) throw const EvalException(EvalErrorCode.factorialTooLarge);
      n = rounded.toInt();
    }
    var result = BigInt.one;
    for (var i = 2; i <= n; i++) {
      result *= BigInt.from(i);
    }
    return Exact(Rational(result));
  }

  Value _binary(BinaryOp op, Value a, Value b) {
    if (a is Exact && b is Exact) return _exactBinary(op, a.value, b.value);
    // Pelo menos um lado é aproximado (só acontece no Fácil).
    final x = a.asDouble, y = b.asDouble;
    switch (op) {
      case BinaryOp.add:
        return Approx(x + y);
      case BinaryOp.subtract:
        return Approx(x - y);
      case BinaryOp.multiply:
        return Approx(x * y);
      case BinaryOp.divide:
        if (y.abs() < 1e-15) throw const EvalException(EvalErrorCode.divisionByZero);
        return Approx(x / y);
      case BinaryOp.power:
        final r = math.pow(x, y).toDouble();
        if (r.isNaN) throw const EvalException(EvalErrorCode.invalidExponent);
        if (r.isInfinite || r.abs() > 1e18) {
          throw const EvalException(EvalErrorCode.numberTooLarge);
        }
        return Approx(r);
    }
  }

  Value _exactBinary(BinaryOp op, Rational a, Rational b) {
    final Rational r;
    switch (op) {
      case BinaryOp.add:
        r = a + b;
      case BinaryOp.subtract:
        r = a - b;
      case BinaryOp.multiply:
        r = a * b;
      case BinaryOp.divide:
        if (b.isZero) throw const EvalException(EvalErrorCode.divisionByZero);
        r = a / b;
        if (!level.allowsNonIntegerDivision && !r.isInteger) {
          throw const EvalException(EvalErrorCode.nonIntegerDivision);
        }
      case BinaryOp.power:
        return _power(a, b);
    }
    _checkSize(r);
    return Exact(r);
  }

  Value _power(Rational base, Rational exponent) {
    if (!exponent.isInteger) {
      // Expoente fracionário: só no Fácil e com base não negativa.
      if (!level.allowsNonIntegerDivision || base.isNegative) {
        throw const EvalException(EvalErrorCode.invalidExponent);
      }
      final r = math.pow(base.toDouble(), exponent.toDouble()).toDouble();
      if (r.isInfinite || r.abs() > 1e18) throw const EvalException(EvalErrorCode.numberTooLarge);
      return Approx(r);
    }
    final e = exponent.numerator;
    if (e.abs() > BigInt.from(64)) throw const EvalException(EvalErrorCode.numberTooLarge);
    final ei = e.toInt();
    if (base.isZero && ei < 0) throw const EvalException(EvalErrorCode.divisionByZero);
    // Estimativa do tamanho antes de calcular, para não travar com 9**64.
    final digits = base.abs().magnitudeDigits;
    if (digits * ei.abs() > maxDigits + 2 && !(base.abs() == Rational.one)) {
      throw const EvalException(EvalErrorCode.numberTooLarge);
    }
    final r = base.pow(ei);
    if (!level.allowsNonIntegerDivision && !r.isInteger) {
      throw const EvalException(EvalErrorCode.nonIntegerResult);
    }
    _checkSize(r);
    return Exact(r);
  }

  void _checkSize(Rational r) {
    if (r.magnitudeDigits > maxDigits || r.denominator.toString().length > maxDigits) {
      throw const EvalException(EvalErrorCode.numberTooLarge);
    }
  }
}
