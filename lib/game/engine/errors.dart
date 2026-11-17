/// Erros possíveis ao montar ou calcular uma expressão.
///
/// A interface traduz cada código com o AppLocalizations, por isso aqui
/// não há texto para o usuário.
enum EvalErrorCode {
  missingEquals,
  multipleEquals,
  emptySide,
  unexpectedToken,
  unexpectedEnd,
  unbalanced,
  operatorNotAllowed,
  divisionByZero,
  nonIntegerDivision,
  nonIntegerResult,
  inexactRoot,
  negativeRoot,
  invalidFactorial,
  factorialTooLarge,
  invalidExponent,
  numberTooLarge,
  notEqual,
}

class EvalException implements Exception {
  final EvalErrorCode code;

  /// Posição do token problemático (quando faz sentido).
  final int? position;

  const EvalException(this.code, [this.position]);

  @override
  String toString() => 'EvalException($code, pos: $position)';
}
