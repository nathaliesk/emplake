import 'dart:math' as math;

import '../domain/level.dart';
import 'token.dart';

/// Racional leve com `int` usado só pelo solver (rápido também na web).
/// Os valores são limitados por [Solver.bound], então não há overflow.
class _Q {
  final int n;
  final int d; // sempre > 0, fração reduzida

  const _Q._(this.n, this.d);

  static _Q? of(int n, int d) {
    if (d == 0) return null;
    if (d < 0) {
      n = -n;
      d = -d;
    }
    final g = _gcd(n.abs(), d);
    n ~/= g;
    d ~/= g;
    if (n.abs() > Solver.bound || d > Solver.maxDen) return null;
    return _Q._(n, d);
  }

  static _Q integer(int v) => _Q._(v, 1);

  bool get isInt => d == 1;

  @override
  bool operator ==(Object o) => o is _Q && o.n == n && o.d == d;

  @override
  int get hashCode => n * 1000003 + d;
}

int _gcd(int a, int b) {
  while (b != 0) {
    final t = a % b;
    a = b;
    b = t;
  }
  return a == 0 ? 1 : a;
}

/// Descobre se um número de 4 dígitos tem solução num nível.
///
/// Ideia: o "=" separa os dígitos em dois lados (1|3, 2|2 ou 3|1).
/// - Para lados de 1 e 2 dígitos, calcula o conjunto de todos os valores possíveis.
/// - No caso 2|2, basta ver se os conjuntos se cruzam.
/// - Nos casos 1|3 e 3|1, para cada valor alvo do lado curto, procura no lado
///   de 3 dígitos uma operação `a op b` que chegue no alvo, calculando o `b`
///   necessário a partir de `a` (inversa da operação). Isso evita montar o
///   conjunto enorme de valores de 3 dígitos.
///
/// A busca é conservadora: se ela diz "tem solução", existe uma expressão
/// válida. Pode deixar passar algumas soluções muito exóticas, o que só faz o
/// número não ser sorteado.
class Solver {
  final Level level;
  Solver(this.level);

  static const bound = 1000000;
  static const maxDen = 1000;

  final Map<String, Set<_Q>> _sets = {};
  final Map<String, bool> _cache = {};

  bool get _hasSqrt => level.operators.contains(TokenKind.sqrt);
  bool get _hasCbrt => level.operators.contains(TokenKind.cbrt);
  bool get _hasFact => level.operators.contains(TokenKind.factorial);
  bool get _hasPow => level.operators.contains(TokenKind.power);
  bool get _hasFloor => level.operators.contains(TokenKind.floorOpen);
  bool get _fractions => level.allowsNonIntegerDivision;

  /// `true` se existe alguma igualdade válida com os dígitos de [number].
  bool isSolvable(int number) {
    final s = number.toString().padLeft(4, '0');
    return _cache.putIfAbsent(s, () => _solve(s));
  }

  bool _solve(String s) {
    // 2 | 2
    final a = _valuesOf(s.substring(0, 2));
    final b = _valuesOf(s.substring(2));
    if (a.length < b.length ? a.any(b.contains) : b.any(a.contains)) return true;
    // 1 | 3
    for (final t in _valuesOf(s.substring(0, 1))) {
      if (_reach3(s.substring(1), t)) return true;
    }
    // 3 | 1
    for (final t in _valuesOf(s.substring(3))) {
      if (_reach3(s.substring(0, 3), t)) return true;
    }
    return false;
  }

  /// Todos os valores que um trecho de 1 ou 2 dígitos consegue formar.
  Set<_Q> _valuesOf(String seg) {
    final cached = _sets[seg];
    if (cached != null) return cached;
    final base = <_Q>{_Q.integer(int.parse(seg))};
    Set<_Q> result;
    if (seg.length == 2) {
      final left = _valuesOf(seg.substring(0, 1));
      final right = _valuesOf(seg.substring(1));
      for (final x in left) {
        for (final y in right) {
          base.addAll(_combine(x, y));
        }
      }
      result = _closure(base, 1);
    } else {
      result = _closure(base, 2);
    }
    _sets[seg] = result;
    return result;
  }

  /// Aplica operadores unários (−, √, ∛, !, ⌊⌋, ⌈⌉) até [depth] vezes.
  Set<_Q> _closure(Set<_Q> start, int depth) {
    final result = <_Q>{...start};
    var frontier = start;
    for (var i = 0; i < depth; i++) {
      final next = <_Q>{};
      for (final v in frontier) {
        for (final u in _unaries(v)) {
          if (result.add(u)) next.add(u);
        }
      }
      frontier = next;
    }
    return result;
  }

  Iterable<_Q> _unaries(_Q v) sync* {
    final neg = _Q.of(-v.n, v.d);
    if (neg != null) yield neg;
    if (_hasSqrt && v.n >= 0) {
      final r = _root(v, 2);
      if (r != null) yield r;
    }
    if (_hasCbrt) {
      final r = _root(v, 3);
      if (r != null) yield r;
    }
    if (_hasFact && v.isInt && v.n >= 0 && v.n <= 9) {
      yield _Q.integer(_factorial(v.n));
    }
    if (_hasFloor && !v.isInt) {
      final f = (v.n / v.d).floor();
      yield _Q.integer(f);
      yield _Q.integer(f + 1);
    }
  }

  /// Todos os resultados de `x op y` permitidos no nível.
  List<_Q> _combine(_Q x, _Q y) {
    final out = <_Q>[];
    void add(_Q? q) {
      if (q != null) out.add(q);
    }

    add(_Q.of(x.n * y.d + y.n * x.d, x.d * y.d));
    add(_Q.of(x.n * y.d - y.n * x.d, x.d * y.d));
    add(_Q.of(x.n * y.n, x.d * y.d));
    add(_div(x, y));
    if (_hasPow) add(_pow(x, y));
    return out;
  }

  _Q? _div(_Q x, _Q y) {
    if (y.n == 0) return null;
    final q = _Q.of(x.n * y.d, x.d * y.n);
    if (q == null) return null;
    if (!_fractions && !q.isInt) return null;
    return q;
  }

  _Q? _pow(_Q base, _Q exp) {
    if (!exp.isInt || exp.n.abs() > 20) return null;
    if (exp.n < 0 && (!_fractions || base.n == 0)) return null;
    var n = 1, d = 1;
    for (var i = 0; i < exp.n.abs(); i++) {
      n *= base.n;
      d *= base.d;
      if (n.abs() > bound || d > bound) return null;
    }
    return exp.n >= 0 ? _Q.of(n, d) : _Q.of(d, n);
  }

  _Q? _root(_Q v, int k) {
    final rn = _intRoot(v.n, k);
    final rd = _intRoot(v.d, k);
    if (rn == null || rd == null) return null;
    return _Q.of(rn, rd);
  }

  static int? _intRoot(int x, int k) {
    final neg = x < 0;
    if (neg && k.isEven) return null;
    final ax = x.abs();
    if (ax <= 1) return x;
    final guess = math.pow(ax, 1 / k).round();
    for (var c = guess - 1; c <= guess + 1; c++) {
      if (c < 0) continue;
      var p = 1;
      for (var i = 0; i < k && p <= ax; i++) {
        p *= c;
      }
      if (p == ax) return neg ? -c : c;
    }
    return null;
  }

  static int _factorial(int n) {
    var r = 1;
    for (var i = 2; i <= n; i++) {
      r *= i;
    }
    return r;
  }

  /// Valores `p` tais que aplicar um unário em `p` dá [t] (inclui o próprio t).
  Set<_Q> _preimages(_Q t) {
    final out = <_Q>{t};
    final neg = _Q.of(-t.n, t.d);
    if (neg != null) out.add(neg);
    for (final s in [t, if (neg != null) neg]) {
      if (_hasSqrt && s.n >= 0) {
        final sq = _Q.of(s.n * s.n, s.d * s.d); // √(s²) = s
        if (sq != null) out.add(sq);
      }
      if (_hasCbrt) {
        final cu = _Q.of(s.n * s.n * s.n, s.d * s.d * s.d);
        if (cu != null) out.add(cu);
      }
      if (_hasFact && s.isInt) {
        for (var n = 3; n <= 9; n++) {
          if (_factorial(n) == s.n) out.add(_Q.integer(n));
        }
      }
    }
    return out;
  }

  /// Existe uma expressão com o trecho de 3 dígitos [seg] que vale [t]?
  bool _reach3(String seg, _Q t) {
    final targets = _preimages(t);
    if (targets.contains(_Q.integer(int.parse(seg)))) return true;
    // a | bc   (itera pelo lado de 1 dígito)
    final a1 = _valuesOf(seg.substring(0, 1));
    final bc = _valuesOf(seg.substring(1));
    // ab | c
    final ab = _valuesOf(seg.substring(0, 2));
    final c1 = _valuesOf(seg.substring(2));
    for (final p in targets) {
      for (final a in a1) {
        if (_needRight(a, p, bc)) return true;
      }
      for (final c in c1) {
        if (_needLeft(c, p, ab)) return true;
      }
    }
    return false;
  }

  /// Existe y em [right] com `a op y = p`?
  bool _needRight(_Q a, _Q p, Set<_Q> right) {
    bool has(_Q? y) => y != null && right.contains(y);
    if (has(_Q.of(p.n * a.d - a.n * p.d, p.d * a.d))) return true; // a + y
    if (has(_Q.of(a.n * p.d - p.n * a.d, a.d * p.d))) return true; // a − y
    if (a.n != 0) {
      final y = _Q.of(p.n * a.d, p.d * a.n); // a × y
      if (has(y)) return true;
    } else if (p.n == 0 && right.isNotEmpty) {
      return true; // 0 × qualquer coisa
    }
    if (p.n != 0) {
      final y = _Q.of(a.n * p.d, a.d * p.n); // a ÷ y
      if (y != null && y.n != 0 && has(y) && _div(a, y) == p) return true;
    } else if (a.n == 0 && right.any((y) => y.n != 0)) {
      return true; // 0 ÷ y
    }
    if (_hasPow) {
      for (final y in right) {
        if (y.isInt && _pow(a, y) == p) return true;
      }
    }
    return false;
  }

  /// Existe x em [left] com `x op c = p`?
  bool _needLeft(_Q c, _Q p, Set<_Q> left) {
    bool has(_Q? x) => x != null && left.contains(x);
    if (has(_Q.of(p.n * c.d - c.n * p.d, p.d * c.d))) return true; // x + c
    if (has(_Q.of(p.n * c.d + c.n * p.d, p.d * c.d))) return true; // x − c
    if (c.n != 0) {
      if (has(_Q.of(p.n * c.d, p.d * c.n))) return true; // x × c
      final x = _Q.of(p.n * c.n, p.d * c.d); // x ÷ c
      if (x != null && has(x) && _div(x, c) == p) return true;
    } else if (p.n == 0 && left.isNotEmpty) {
      return true;
    }
    if (_hasPow && c.isInt && c.n > 0 && c.n <= 20) {
      final x = _root(p, c.n);
      if (x != null && has(x)) return true;
      if (c.n.isEven) {
        final nx = x == null ? null : _Q.of(-x.n, x.d);
        if (has(nx)) return true;
      }
    }
    return false;
  }
}
