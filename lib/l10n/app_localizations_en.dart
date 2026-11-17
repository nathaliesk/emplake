// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Emplake';

  @override
  String get loginTagline =>
      'Build a true equation with the 4 digits of the license plate.';

  @override
  String get loginSubtitle =>
      'Sign in to save your score and the plates you have already solved.';

  @override
  String get teamMember => 'Team member';

  @override
  String get courseInfo => 'Mobile Device Development — UFSCar';

  @override
  String get language => 'Language';

  @override
  String get portuguese => 'Portuguese';

  @override
  String get english => 'English';

  @override
  String get navGame => 'Game';

  @override
  String get navHistory => 'History';

  @override
  String get navRanking => 'Ranking';

  @override
  String get navHelp => 'Help';

  @override
  String get navSettings => 'Settings';

  @override
  String get levelLabel => 'Level';

  @override
  String get levelEasy => 'Easy';

  @override
  String get levelIntermediate => 'Intermediate';

  @override
  String get levelAdvanced => 'Advanced';

  @override
  String get levelHard => 'Hard';

  @override
  String get scoreLabel => 'Score';

  @override
  String get timeLabel => 'Time';

  @override
  String get plateBand => 'BRAZIL';

  @override
  String get verify => 'Check';

  @override
  String get clear => 'Clear';

  @override
  String get skip => 'Skip';

  @override
  String get nextPlate => 'Next plate';

  @override
  String get slotHint =>
      'Tap a slot (between or beside the digits) to open the operator wheel.';

  @override
  String slotSemantics(int index) {
    return 'Slot $index';
  }

  @override
  String get moveEqualsLeft => 'Move = to the left';

  @override
  String get moveEqualsRight => 'Move = to the right';

  @override
  String get yourFormula => 'Your formula';

  @override
  String get latexLabel => 'LaTeX rendering';

  @override
  String get successTitle => 'Plate solved!';

  @override
  String successMessage(int points) {
    return 'Correct! You earned $points points.';
  }

  @override
  String get skippedMessage => 'Plate skipped. No worries, here comes another!';

  @override
  String get wheelTitle => 'Operator wheel';

  @override
  String get wheelBackspace => 'Delete last';

  @override
  String get wheelClear => 'Empty slot';

  @override
  String get wheelDone => 'Done';

  @override
  String get wheelEmpty => 'empty slot';

  @override
  String get loadingPlate => 'Looking for a plate you haven\'t solved yet…';

  @override
  String get allSolved =>
      'Wow! No new plates left at this level. Try another level.';

  @override
  String get soundOn => 'Sound on (tap to turn off)';

  @override
  String get soundOff => 'Sound off (tap to turn on)';

  @override
  String get loadError => 'Could not load the data.';

  @override
  String get retry => 'Try again';

  @override
  String get saveError =>
      'Correct, but it could not be saved to the cloud. Check your connection.';

  @override
  String get historyTitle => 'Your history';

  @override
  String get totalScore => 'Total score';

  @override
  String solvedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count plates solved',
      one: '1 plate solved',
      zero: 'No plates solved',
    );
    return '$_temp0';
  }

  @override
  String get solvedByLevel => 'By level';

  @override
  String get recentSolved => 'Latest solved plates';

  @override
  String get noSolvedYet => 'You haven\'t solved any plate yet. Let\'s play!';

  @override
  String solvedIn(String level, int seconds) {
    return '$level · $seconds s';
  }

  @override
  String get rankingTitle => 'Leaderboard';

  @override
  String get rankingEmpty => 'Nobody has scored yet. Be the first!';

  @override
  String get you => 'you';

  @override
  String get anonymousPlayer => 'Anonymous player';

  @override
  String points(int points) {
    return '$points pts';
  }

  @override
  String get settingsTitle => 'Settings';

  @override
  String get appearance => 'Appearance';

  @override
  String get themeMode => 'Theme';

  @override
  String get themeSystem => 'Device';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get fontSize => 'Font size';

  @override
  String get fontFamily => 'Font family';

  @override
  String get seedColor => 'Theme seed color';

  @override
  String get presetThemes => 'Ready-made themes';

  @override
  String get presetOcean => 'Ocean';

  @override
  String get presetForest => 'Forest';

  @override
  String get presetSunset => 'Sunset';

  @override
  String get presetGrape => 'Grape';

  @override
  String get presetClassic => 'Classic';

  @override
  String get presetTerminal => 'Terminal';

  @override
  String get previewText => 'Example: √(8 + 1) = 3¹';

  @override
  String get sound => 'Sound effects';

  @override
  String get soundDescription =>
      'Off by default. Turn it on to hear hits and misses.';

  @override
  String get languageSetting => 'App language';

  @override
  String get account => 'Account';

  @override
  String get signOut => 'Sign out';

  @override
  String get resetSettings => 'Restore defaults';

  @override
  String get helpTitle => 'How to play';

  @override
  String get helpGoal =>
      'The plate shows 4 digits. Without changing their order, insert operators and the = sign to build a true equation.';

  @override
  String get helpSlots =>
      'Tap a slot (the gaps between and beside the digits) to open the operator wheel. Each tap on the wheel adds an operator to that slot.';

  @override
  String get helpEquals =>
      'The = is already on the plate: use the arrows next to it to change its position.';

  @override
  String get helpJoin =>
      'Neighbouring digits with no operator between them form a single number (2 and 8 become 28).';

  @override
  String get helpDivision =>
      'Only the Easy level accepts divisions and roots with non-integer results.';

  @override
  String helpOperators(String level) {
    return 'Operators at the $level level:';
  }

  @override
  String get helpExample => 'Example with the plate 8 1 3 1:';

  @override
  String get helpSkip =>
      'Too hard? Use Skip to get another plate. Each hit is worth more points at harder levels.';

  @override
  String get close => 'Close';

  @override
  String get errMissingEquals => 'The = sign is missing.';

  @override
  String get errMultipleEquals => 'Use only one = sign.';

  @override
  String get errEmptySide => 'One side of the = is empty.';

  @override
  String get errUnexpectedToken => 'There is an operator out of place.';

  @override
  String get errUnexpectedEnd =>
      'The expression ends in the middle of an operation.';

  @override
  String get errUnbalanced => 'Parentheses or bars are not balanced.';

  @override
  String get errOperatorNotAllowed =>
      'That operator is not available at this level.';

  @override
  String get errDivisionByZero => 'Division by zero is not allowed!';

  @override
  String get errNonIntegerDivision =>
      'At this level, division must result in a whole number.';

  @override
  String get errNonIntegerResult =>
      'At this level, the result must be a whole number.';

  @override
  String get errInexactRoot => 'At this level, the root must be exact.';

  @override
  String get errNegativeRoot =>
      'There is no real square root of a negative number.';

  @override
  String get errInvalidFactorial =>
      'Factorial only applies to whole numbers greater than or equal to zero.';

  @override
  String get errFactorialTooLarge => 'Factorial too large (max 20!).';

  @override
  String get errInvalidExponent => 'That exponent is not allowed here.';

  @override
  String get errNumberTooLarge => 'The number got too large.';

  @override
  String errNotEqual(String left, String right) {
    return 'The sides are not equal: $left ≠ $right';
  }
}
