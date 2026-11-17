import '../../l10n/app_localizations.dart';
import '../domain/level.dart';
import '../engine/errors.dart';

/// Traduções que dependem de enums do jogo.
extension GameL10n on AppLocalizations {
  String levelName(Level level) => switch (level) {
        Level.easy => levelEasy,
        Level.intermediate => levelIntermediate,
        Level.advanced => levelAdvanced,
        Level.hard => levelHard,
      };

  String errorMessage(EvalErrorCode code, {String? left, String? right}) => switch (code) {
        EvalErrorCode.missingEquals => errMissingEquals,
        EvalErrorCode.multipleEquals => errMultipleEquals,
        EvalErrorCode.emptySide => errEmptySide,
        EvalErrorCode.unexpectedToken => errUnexpectedToken,
        EvalErrorCode.unexpectedEnd => errUnexpectedEnd,
        EvalErrorCode.unbalanced => errUnbalanced,
        EvalErrorCode.operatorNotAllowed => errOperatorNotAllowed,
        EvalErrorCode.divisionByZero => errDivisionByZero,
        EvalErrorCode.nonIntegerDivision => errNonIntegerDivision,
        EvalErrorCode.nonIntegerResult => errNonIntegerResult,
        EvalErrorCode.inexactRoot => errInexactRoot,
        EvalErrorCode.negativeRoot => errNegativeRoot,
        EvalErrorCode.invalidFactorial => errInvalidFactorial,
        EvalErrorCode.factorialTooLarge => errFactorialTooLarge,
        EvalErrorCode.invalidExponent => errInvalidExponent,
        EvalErrorCode.numberTooLarge => errNumberTooLarge,
        EvalErrorCode.notEqual => errNotEqual(left ?? '?', right ?? '?'),
      };
}
