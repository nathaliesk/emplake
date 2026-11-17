import 'dart:math' as math;

/// Número racional exato (numerador/denominador em [BigInt]).
///
/// O denominador é sempre positivo e a fração está sempre reduzida, então
/// dois racionais iguais têm a mesma representação (útil para `==` e `Set`).
class Rational implements Comparable<Rational> {
  final BigInt numerator;
  final BigInt denominator;

  const Rational._(this.numerator, this.denominator);

  factory Rational(BigInt numerator, [BigInt? denominator]) {
    var n = numerator;
    var d = denominator ?? BigInt.one;
    if (d == BigInt.zero) {
      throw ArgumentError('Denominador zero');
    }
    if (d.isNegative) {
      n = -n;
      d = -d;
    }
    final g = n.gcd(d);
    if (g > BigInt.one) {
      n ~/= g;
      d ~/= g;
    }
    return Rational._(n, d);
  }

  factory Rational.fromInt(int value) => Rational._(BigInt.from(value), BigInt.one);

  static final Rational zero = Rational.fromInt(0);
  static final Rational one = Rational.fromInt(1);

  bool get isInteger => denominator == BigInt.one;
  bool get isNegative => numerator.isNegative;
  bool get isZero => numerator == BigInt.zero;

  Rational operator +(Rational o) =>
      Rational(numerator * o.denominator + o.numerator * denominator, denominator * o.denominator);

  Rational operator -(Rational o) =>
      Rational(numerator * o.denominator - o.numerator * denominator, denominator * o.denominator);

  Rational operator *(Rational o) =>
      Rational(numerator * o.numerator, denominator * o.denominator);

  /// Divisão; lança [ArgumentError] se [o] for zero.
  Rational operator /(Rational o) =>
      Rational(numerator * o.denominator, denominator * o.numerator);

  Rational operator -() => Rational._(-numerator, denominator);

  Rational abs() => isNegative ? -this : this;

  /// Maior inteiro menor ou igual (⌊x⌋).
  BigInt floor() {
    final q = numerator ~/ denominator; // trunca em direção a zero
    if (isNegative && !isInteger) return q - BigInt.one;
    return q;
  }

  /// Menor inteiro maior ou igual (⌈x⌉).
  BigInt ceil() {
    final q = numerator ~/ denominator;
    if (!isNegative && !isInteger) return q + BigInt.one;
    return q;
  }

  /// Potência com expoente inteiro (pode ser negativo).
  Rational pow(int exponent) {
    if (exponent >= 0) {
      return Rational(numerator.pow(exponent), denominator.pow(exponent));
    }
    final e = -exponent;
    return Rational(denominator.pow(e), numerator.pow(e));
  }

  /// Raiz k-ésima exata, ou `null` se não existir em racionais.
  /// Para k par, números negativos não têm raiz real.
  Rational? exactRoot(int k) {
    if (isNegative && k.isEven) return null;
    final n = _intRoot(numerator.abs(), k);
    final d = _intRoot(denominator, k);
    if (n == null || d == null) return null;
    final root = Rational(n, d);
    return isNegative ? -root : root;
  }

  double toDouble() {
    // Para frações gigantes, divide em partes para não virar infinito/NaN.
    final n = numerator.toDouble();
    final d = denominator.toDouble();
    if (n.isFinite && d.isFinite) return n / d;
    return (numerator * BigInt.from(1000000) ~/ denominator).toDouble() / 1000000;
  }

  /// Quantidade aproximada de dígitos do numerador (usada para limitar contas).
  int get magnitudeDigits => numerator.abs().toString().length;

  @override
  int compareTo(Rational other) =>
      (numerator * other.denominator).compareTo(other.numerator * denominator);

  @override
  bool operator ==(Object other) =>
      other is Rational && other.numerator == numerator && other.denominator == denominator;

  @override
  int get hashCode => Object.hash(numerator, denominator);

  @override
  String toString() => isInteger ? '$numerator' : '$numerator/$denominator';
}

/// Raiz k-ésima inteira exata de [x] ≥ 0, ou `null`.
BigInt? _intRoot(BigInt x, int k) {
  if (x == BigInt.zero || x == BigInt.one) return x;
  // Estimativa por double e ajuste fino; para números enormes, usa Newton.
  final approx = math.pow(x.toDouble(), 1 / k);
  if (approx.isFinite && approx < 9e15) {
    final base = BigInt.from(approx.round());
    for (final delta in [BigInt.zero, BigInt.one, -BigInt.one, BigInt.two, -BigInt.two]) {
      final c = base + delta;
      if (c >= BigInt.zero && c.pow(k) == x) return c;
    }
    return null;
  }
  // Newton para inteiros grandes.
  var r = BigInt.one << ((x.bitLength + k - 1) ~/ k);
  final bk = BigInt.from(k);
  while (true) {
    final next = ((bk - BigInt.one) * r + x ~/ r.pow(k - 1)) ~/ bk;
    if (next >= r) break;
    r = next;
  }
  return r.pow(k) == x ? r : null;
}
