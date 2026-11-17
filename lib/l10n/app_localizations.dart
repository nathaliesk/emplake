import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pt')
  ];

  /// No description provided for @appTitle.
  ///
  /// In pt, this message translates to:
  /// **'Emplake'**
  String get appTitle;

  /// No description provided for @loginTagline.
  ///
  /// In pt, this message translates to:
  /// **'Monte uma igualdade verdadeira com os 4 dígitos da placa.'**
  String get loginTagline;

  /// No description provided for @loginSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Entre para salvar sua pontuação e as placas que você já resolveu.'**
  String get loginSubtitle;

  /// No description provided for @teamMember.
  ///
  /// In pt, this message translates to:
  /// **'Integrante do grupo'**
  String get teamMember;

  /// No description provided for @courseInfo.
  ///
  /// In pt, this message translates to:
  /// **'Desenvolvimento para Dispositivos Móveis — UFSCar'**
  String get courseInfo;

  /// No description provided for @language.
  ///
  /// In pt, this message translates to:
  /// **'Idioma'**
  String get language;

  /// No description provided for @portuguese.
  ///
  /// In pt, this message translates to:
  /// **'Português'**
  String get portuguese;

  /// No description provided for @english.
  ///
  /// In pt, this message translates to:
  /// **'Inglês'**
  String get english;

  /// No description provided for @navGame.
  ///
  /// In pt, this message translates to:
  /// **'Jogo'**
  String get navGame;

  /// No description provided for @navHistory.
  ///
  /// In pt, this message translates to:
  /// **'Histórico'**
  String get navHistory;

  /// No description provided for @navRanking.
  ///
  /// In pt, this message translates to:
  /// **'Ranking'**
  String get navRanking;

  /// No description provided for @navHelp.
  ///
  /// In pt, this message translates to:
  /// **'Ajuda'**
  String get navHelp;

  /// No description provided for @navSettings.
  ///
  /// In pt, this message translates to:
  /// **'Configurações'**
  String get navSettings;

  /// No description provided for @levelLabel.
  ///
  /// In pt, this message translates to:
  /// **'Nível'**
  String get levelLabel;

  /// No description provided for @levelEasy.
  ///
  /// In pt, this message translates to:
  /// **'Fácil'**
  String get levelEasy;

  /// No description provided for @levelIntermediate.
  ///
  /// In pt, this message translates to:
  /// **'Intermediário'**
  String get levelIntermediate;

  /// No description provided for @levelAdvanced.
  ///
  /// In pt, this message translates to:
  /// **'Avançado'**
  String get levelAdvanced;

  /// No description provided for @levelHard.
  ///
  /// In pt, this message translates to:
  /// **'Difícil'**
  String get levelHard;

  /// No description provided for @scoreLabel.
  ///
  /// In pt, this message translates to:
  /// **'Pontos'**
  String get scoreLabel;

  /// No description provided for @timeLabel.
  ///
  /// In pt, this message translates to:
  /// **'Tempo'**
  String get timeLabel;

  /// No description provided for @plateBand.
  ///
  /// In pt, this message translates to:
  /// **'BRASIL'**
  String get plateBand;

  /// No description provided for @verify.
  ///
  /// In pt, this message translates to:
  /// **'Verificar'**
  String get verify;

  /// No description provided for @clear.
  ///
  /// In pt, this message translates to:
  /// **'Limpar'**
  String get clear;

  /// No description provided for @skip.
  ///
  /// In pt, this message translates to:
  /// **'Pular'**
  String get skip;

  /// No description provided for @nextPlate.
  ///
  /// In pt, this message translates to:
  /// **'Próxima placa'**
  String get nextPlate;

  /// No description provided for @slotHint.
  ///
  /// In pt, this message translates to:
  /// **'Toque numa fenda (entre ou ao lado dos dígitos) para abrir a roda de operadores.'**
  String get slotHint;

  /// No description provided for @slotSemantics.
  ///
  /// In pt, this message translates to:
  /// **'Fenda {index}'**
  String slotSemantics(int index);

  /// No description provided for @moveEqualsLeft.
  ///
  /// In pt, this message translates to:
  /// **'Mover o = para a esquerda'**
  String get moveEqualsLeft;

  /// No description provided for @moveEqualsRight.
  ///
  /// In pt, this message translates to:
  /// **'Mover o = para a direita'**
  String get moveEqualsRight;

  /// No description provided for @yourFormula.
  ///
  /// In pt, this message translates to:
  /// **'Sua fórmula'**
  String get yourFormula;

  /// No description provided for @latexLabel.
  ///
  /// In pt, this message translates to:
  /// **'Renderização em LaTeX'**
  String get latexLabel;

  /// No description provided for @successTitle.
  ///
  /// In pt, this message translates to:
  /// **'Placa emplacada!'**
  String get successTitle;

  /// No description provided for @successMessage.
  ///
  /// In pt, this message translates to:
  /// **'Correto! Você ganhou {points} pontos.'**
  String successMessage(int points);

  /// No description provided for @skippedMessage.
  ///
  /// In pt, this message translates to:
  /// **'Placa pulada. Sem problema, vem outra!'**
  String get skippedMessage;

  /// No description provided for @wheelTitle.
  ///
  /// In pt, this message translates to:
  /// **'Roda de operadores'**
  String get wheelTitle;

  /// No description provided for @wheelBackspace.
  ///
  /// In pt, this message translates to:
  /// **'Apagar o último'**
  String get wheelBackspace;

  /// No description provided for @wheelClear.
  ///
  /// In pt, this message translates to:
  /// **'Esvaziar fenda'**
  String get wheelClear;

  /// No description provided for @wheelDone.
  ///
  /// In pt, this message translates to:
  /// **'Pronto'**
  String get wheelDone;

  /// No description provided for @wheelEmpty.
  ///
  /// In pt, this message translates to:
  /// **'fenda vazia'**
  String get wheelEmpty;

  /// No description provided for @loadingPlate.
  ///
  /// In pt, this message translates to:
  /// **'Procurando uma placa que você ainda não resolveu…'**
  String get loadingPlate;

  /// No description provided for @allSolved.
  ///
  /// In pt, this message translates to:
  /// **'Uau! Não encontramos mais placas novas neste nível. Tente outro nível.'**
  String get allSolved;

  /// No description provided for @soundOn.
  ///
  /// In pt, this message translates to:
  /// **'Som ligado (toque para desligar)'**
  String get soundOn;

  /// No description provided for @soundOff.
  ///
  /// In pt, this message translates to:
  /// **'Som desligado (toque para ligar)'**
  String get soundOff;

  /// No description provided for @loadError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível carregar os dados.'**
  String get loadError;

  /// No description provided for @retry.
  ///
  /// In pt, this message translates to:
  /// **'Tentar de novo'**
  String get retry;

  /// No description provided for @saveError.
  ///
  /// In pt, this message translates to:
  /// **'Acertou, mas não deu para salvar na nuvem. Verifique a conexão.'**
  String get saveError;

  /// No description provided for @historyTitle.
  ///
  /// In pt, this message translates to:
  /// **'Seu histórico'**
  String get historyTitle;

  /// No description provided for @totalScore.
  ///
  /// In pt, this message translates to:
  /// **'Pontuação total'**
  String get totalScore;

  /// No description provided for @solvedCount.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =0{Nenhuma placa resolvida} =1{1 placa resolvida} other{{count} placas resolvidas}}'**
  String solvedCount(int count);

  /// No description provided for @solvedByLevel.
  ///
  /// In pt, this message translates to:
  /// **'Por nível'**
  String get solvedByLevel;

  /// No description provided for @recentSolved.
  ///
  /// In pt, this message translates to:
  /// **'Últimas placas resolvidas'**
  String get recentSolved;

  /// No description provided for @noSolvedYet.
  ///
  /// In pt, this message translates to:
  /// **'Você ainda não resolveu nenhuma placa. Bora jogar!'**
  String get noSolvedYet;

  /// No description provided for @solvedIn.
  ///
  /// In pt, this message translates to:
  /// **'{level} · {seconds} s'**
  String solvedIn(String level, int seconds);

  /// No description provided for @rankingTitle.
  ///
  /// In pt, this message translates to:
  /// **'Ranking geral'**
  String get rankingTitle;

  /// No description provided for @rankingEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Ninguém pontuou ainda. Seja o primeiro!'**
  String get rankingEmpty;

  /// No description provided for @you.
  ///
  /// In pt, this message translates to:
  /// **'você'**
  String get you;

  /// No description provided for @anonymousPlayer.
  ///
  /// In pt, this message translates to:
  /// **'Jogador anônimo'**
  String get anonymousPlayer;

  /// No description provided for @points.
  ///
  /// In pt, this message translates to:
  /// **'{points} pts'**
  String points(int points);

  /// No description provided for @settingsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Configurações'**
  String get settingsTitle;

  /// No description provided for @appearance.
  ///
  /// In pt, this message translates to:
  /// **'Aparência'**
  String get appearance;

  /// No description provided for @themeMode.
  ///
  /// In pt, this message translates to:
  /// **'Tema'**
  String get themeMode;

  /// No description provided for @themeSystem.
  ///
  /// In pt, this message translates to:
  /// **'Do aparelho'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In pt, this message translates to:
  /// **'Claro'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In pt, this message translates to:
  /// **'Escuro'**
  String get themeDark;

  /// No description provided for @fontSize.
  ///
  /// In pt, this message translates to:
  /// **'Tamanho da fonte'**
  String get fontSize;

  /// No description provided for @fontFamily.
  ///
  /// In pt, this message translates to:
  /// **'Tipo da fonte'**
  String get fontFamily;

  /// No description provided for @seedColor.
  ///
  /// In pt, this message translates to:
  /// **'Cor semente do tema'**
  String get seedColor;

  /// No description provided for @presetThemes.
  ///
  /// In pt, this message translates to:
  /// **'Temas prontos'**
  String get presetThemes;

  /// No description provided for @presetOcean.
  ///
  /// In pt, this message translates to:
  /// **'Oceano'**
  String get presetOcean;

  /// No description provided for @presetForest.
  ///
  /// In pt, this message translates to:
  /// **'Floresta'**
  String get presetForest;

  /// No description provided for @presetSunset.
  ///
  /// In pt, this message translates to:
  /// **'Pôr do sol'**
  String get presetSunset;

  /// No description provided for @presetGrape.
  ///
  /// In pt, this message translates to:
  /// **'Uva'**
  String get presetGrape;

  /// No description provided for @presetClassic.
  ///
  /// In pt, this message translates to:
  /// **'Clássico'**
  String get presetClassic;

  /// No description provided for @presetTerminal.
  ///
  /// In pt, this message translates to:
  /// **'Terminal'**
  String get presetTerminal;

  /// No description provided for @previewText.
  ///
  /// In pt, this message translates to:
  /// **'Exemplo: √(8 + 1) = 3¹'**
  String get previewText;

  /// No description provided for @sound.
  ///
  /// In pt, this message translates to:
  /// **'Efeitos sonoros'**
  String get sound;

  /// No description provided for @soundDescription.
  ///
  /// In pt, this message translates to:
  /// **'Desligado por padrão. Ligue se quiser ouvir os acertos e erros.'**
  String get soundDescription;

  /// No description provided for @languageSetting.
  ///
  /// In pt, this message translates to:
  /// **'Idioma do aplicativo'**
  String get languageSetting;

  /// No description provided for @account.
  ///
  /// In pt, this message translates to:
  /// **'Conta'**
  String get account;

  /// No description provided for @signOut.
  ///
  /// In pt, this message translates to:
  /// **'Sair'**
  String get signOut;

  /// No description provided for @resetSettings.
  ///
  /// In pt, this message translates to:
  /// **'Restaurar padrão'**
  String get resetSettings;

  /// No description provided for @helpTitle.
  ///
  /// In pt, this message translates to:
  /// **'Como jogar'**
  String get helpTitle;

  /// No description provided for @helpGoal.
  ///
  /// In pt, this message translates to:
  /// **'A placa mostra 4 dígitos. Sem mudar a ordem deles, insira operadores e o sinal de = para formar uma igualdade verdadeira.'**
  String get helpGoal;

  /// No description provided for @helpSlots.
  ///
  /// In pt, this message translates to:
  /// **'Toque numa fenda (os espaços entre e ao lado dos dígitos) para abrir a roda de operadores. Cada toque na roda acrescenta um operador naquela fenda.'**
  String get helpSlots;

  /// No description provided for @helpEquals.
  ///
  /// In pt, this message translates to:
  /// **'O = já está na placa: use as setas ao lado dele para mudar a posição.'**
  String get helpEquals;

  /// No description provided for @helpJoin.
  ///
  /// In pt, this message translates to:
  /// **'Dígitos vizinhos sem operador entre eles formam um número só (2 e 8 viram 28).'**
  String get helpJoin;

  /// No description provided for @helpDivision.
  ///
  /// In pt, this message translates to:
  /// **'Só o nível Fácil aceita divisões e raízes com resultado não inteiro.'**
  String get helpDivision;

  /// No description provided for @helpOperators.
  ///
  /// In pt, this message translates to:
  /// **'Operadores do nível {level}:'**
  String helpOperators(String level);

  /// No description provided for @helpExample.
  ///
  /// In pt, this message translates to:
  /// **'Exemplo com a placa 8 1 3 1:'**
  String get helpExample;

  /// No description provided for @helpSkip.
  ///
  /// In pt, this message translates to:
  /// **'Achou difícil? Use Pular para trocar de placa. Cada acerto vale mais pontos nos níveis mais difíceis.'**
  String get helpSkip;

  /// No description provided for @close.
  ///
  /// In pt, this message translates to:
  /// **'Fechar'**
  String get close;

  /// No description provided for @errMissingEquals.
  ///
  /// In pt, this message translates to:
  /// **'Falta o sinal de =.'**
  String get errMissingEquals;

  /// No description provided for @errMultipleEquals.
  ///
  /// In pt, this message translates to:
  /// **'Use apenas um sinal de =.'**
  String get errMultipleEquals;

  /// No description provided for @errEmptySide.
  ///
  /// In pt, this message translates to:
  /// **'Um dos lados do = está vazio.'**
  String get errEmptySide;

  /// No description provided for @errUnexpectedToken.
  ///
  /// In pt, this message translates to:
  /// **'Tem um operador fora do lugar.'**
  String get errUnexpectedToken;

  /// No description provided for @errUnexpectedEnd.
  ///
  /// In pt, this message translates to:
  /// **'A expressão terminou no meio de uma operação.'**
  String get errUnexpectedEnd;

  /// No description provided for @errUnbalanced.
  ///
  /// In pt, this message translates to:
  /// **'Parênteses ou barras não estão fechando direito.'**
  String get errUnbalanced;

  /// No description provided for @errOperatorNotAllowed.
  ///
  /// In pt, this message translates to:
  /// **'Esse operador não existe neste nível.'**
  String get errOperatorNotAllowed;

  /// No description provided for @errDivisionByZero.
  ///
  /// In pt, this message translates to:
  /// **'Divisão por zero não vale!'**
  String get errDivisionByZero;

  /// No description provided for @errNonIntegerDivision.
  ///
  /// In pt, this message translates to:
  /// **'Neste nível a divisão precisa dar um número inteiro.'**
  String get errNonIntegerDivision;

  /// No description provided for @errNonIntegerResult.
  ///
  /// In pt, this message translates to:
  /// **'Neste nível o resultado precisa ser inteiro.'**
  String get errNonIntegerResult;

  /// No description provided for @errInexactRoot.
  ///
  /// In pt, this message translates to:
  /// **'Neste nível a raiz precisa ser exata.'**
  String get errInexactRoot;

  /// No description provided for @errNegativeRoot.
  ///
  /// In pt, this message translates to:
  /// **'Não existe raiz quadrada real de número negativo.'**
  String get errNegativeRoot;

  /// No description provided for @errInvalidFactorial.
  ///
  /// In pt, this message translates to:
  /// **'Fatorial só de inteiros maiores ou iguais a zero.'**
  String get errInvalidFactorial;

  /// No description provided for @errFactorialTooLarge.
  ///
  /// In pt, this message translates to:
  /// **'Fatorial grande demais (máximo 20!).'**
  String get errFactorialTooLarge;

  /// No description provided for @errInvalidExponent.
  ///
  /// In pt, this message translates to:
  /// **'Esse expoente não é permitido aqui.'**
  String get errInvalidExponent;

  /// No description provided for @errNumberTooLarge.
  ///
  /// In pt, this message translates to:
  /// **'O número ficou grande demais.'**
  String get errNumberTooLarge;

  /// No description provided for @errNotEqual.
  ///
  /// In pt, this message translates to:
  /// **'Os lados não são iguais: {left} ≠ {right}'**
  String errNotEqual(String left, String right);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
