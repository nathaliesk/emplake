import 'package:emplake/game/domain/level.dart';
import 'package:emplake/game/engine/errors.dart';
import 'package:emplake/game/engine/evaluator.dart';
import 'package:emplake/game/engine/latex.dart';
import 'package:emplake/game/engine/parser.dart';
import 'package:emplake/game/engine/rational.dart';
import 'package:emplake/game/engine/solver.dart';
import 'package:emplake/game/engine/token.dart';
import 'package:flutter_test/flutter_test.dart';

/// Converte uma string compacta em tokens. Símbolos:
/// + - * / ^ (potência) r (√) c (∛) ! ( ) [ ] (módulo) { } (base) < > (teto) =
List<Token> t(String s) => [
      for (final ch in s.split('').where((c) => c != ' '))
        switch (ch) {
          '+' => const Token(TokenKind.plus),
          '-' => const Token(TokenKind.minus),
          '*' => const Token(TokenKind.times),
          '/' => const Token(TokenKind.divide),
          '^' => const Token(TokenKind.power),
          'r' => const Token(TokenKind.sqrt),
          'c' => const Token(TokenKind.cbrt),
          '!' => const Token(TokenKind.factorial),
          '(' => const Token(TokenKind.lParen),
          ')' => const Token(TokenKind.rParen),
          '[' => const Token(TokenKind.absOpen),
          ']' => const Token(TokenKind.absClose),
          '{' => const Token(TokenKind.floorOpen),
          '}' => const Token(TokenKind.floorClose),
          '<' => const Token(TokenKind.ceilOpen),
          '>' => const Token(TokenKind.ceilClose),
          '=' => const Token(TokenKind.equals),
          _ => Token.digit(int.parse(ch)),
        },
    ];

bool ok(Level level, String expr) => Evaluator(level).check(t(expr)).isCorrect;

EvalErrorCode? err(Level level, String expr) {
  try {
    Evaluator(level).check(t(expr));
    return null;
  } on EvalException catch (e) {
    return e.code;
  }
}

void main() {
  group('Rational', () {
    test('reduz e normaliza sinal', () {
      final r = Rational(BigInt.from(4), BigInt.from(-6));
      expect(r.toString(), '-2/3');
    });
    test('base e teto', () {
      final r = Rational(BigInt.from(-5), BigInt.two);
      expect(r.floor(), BigInt.from(-3));
      expect(r.ceil(), BigInt.from(-2));
    });
    test('raiz exata', () {
      expect(Rational.fromInt(81).exactRoot(2), Rational.fromInt(9));
      expect(Rational.fromInt(-27).exactRoot(3), Rational.fromInt(-3));
      expect(Rational.fromInt(8).exactRoot(2), isNull);
    });
  });

  group('Avaliação', () {
    test('exemplo do enunciado: √(8+1) = 3**1', () {
      expect(ok(Level.easy, 'r(8+1)=3^1'), isTrue);
    });
    test('concatenação de dígitos', () {
      expect(ok(Level.hard, '12=3*4'), isTrue);
    });
    test('precedência e menos unário', () {
      expect(ok(Level.hard, '2+3*4=14'), isTrue);
      expect(ok(Level.hard, '-(2-5)=3'), isTrue);
      expect(ok(Level.intermediate, '-2^2=-4'), isTrue);
      expect(ok(Level.intermediate, '2^3^2=512'), isTrue); // associativo à direita
    });
    test('fatorial e módulo', () {
      expect(ok(Level.advanced, '(5-2)!=6*1'), isTrue);
      expect(ok(Level.hard, '[2-5]=3'), isTrue);
    });
    test('base e teto no Fácil', () {
      expect(ok(Level.easy, '{5/2}=2'), isTrue);
      expect(ok(Level.easy, '<5/2>=3'), isTrue);
    });
    test('divisão não inteira só no Fácil', () {
      expect(ok(Level.easy, '5/2*2=5'), isTrue);
      expect(err(Level.intermediate, '5/2*2=5'), EvalErrorCode.nonIntegerDivision);
    });
    test('raiz não exata: aproximada no Fácil, erro nos demais', () {
      expect(ok(Level.easy, 'r2*r2=2'), isTrue);
      expect(err(Level.advanced, 'r2*r2=2'), EvalErrorCode.inexactRoot);
    });
    test('operador fora do nível', () {
      expect(err(Level.hard, 'r9=3'), EvalErrorCode.operatorNotAllowed);
    });
    test('erros de estrutura', () {
      expect(err(Level.hard, '(1+2=3'), EvalErrorCode.unbalanced);
      expect(err(Level.hard, '1+2'), EvalErrorCode.missingEquals);
      expect(err(Level.hard, '=12'), EvalErrorCode.emptySide);
      expect(err(Level.hard, '1/0=1'), EvalErrorCode.divisionByZero);
      expect(err(Level.hard, '1+=2'), EvalErrorCode.unexpectedEnd);
      expect(err(Level.hard, '1)+2=3'), EvalErrorCode.unbalanced);
    });
    test('igualdade falsa', () {
      expect(ok(Level.hard, '1+1=3'), isFalse);
    });
  });

  group('LaTeX', () {
    test('raiz e potência', () {
      final eq = Parser.parseEquation(t('r(8+1)=3^1'));
      expect(LatexBuilder.fromNode(eq.left), r'\sqrt{8 + 1}');
      expect(LatexBuilder.fromNode(eq.right), '{3}^{1}');
    });
    test('expressão incompleta usa a tradução peça a peça', () {
      expect(LatexBuilder.fromTokens(t('8+')), contains('8'));
    });
  });

  group('Solver', () {
    test('encontra solução para números conhecidos', () {
      expect(Solver(Level.hard).isSolvable(1236), isTrue); // 1 × 2 × 3 = 6
      expect(Solver(Level.hard).isSolvable(2442), isTrue); // 2 × 4 = 4 × 2
      expect(Solver(Level.hard).isSolvable(1001), isTrue); // 1 = 001
      expect(Solver(Level.easy).isSolvable(8131), isTrue); // √(8+1) = 3 × 1
    });
    test('a maioria dos números do Fácil tem solução', () {
      final s = Solver(Level.easy);
      var count = 0;
      for (var n = 0; n < 500; n++) {
        if (s.isSolvable(n)) count++;
      }
      expect(count, greaterThan(200));
    });
  });
}
