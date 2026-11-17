// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Emplake';

  @override
  String get loginTagline =>
      'Monte uma igualdade verdadeira com os 4 dígitos da placa.';

  @override
  String get loginSubtitle =>
      'Entre para salvar sua pontuação e as placas que você já resolveu.';

  @override
  String get teamMember => 'Integrante do grupo';

  @override
  String get courseInfo => 'Desenvolvimento para Dispositivos Móveis — UFSCar';

  @override
  String get language => 'Idioma';

  @override
  String get portuguese => 'Português';

  @override
  String get english => 'Inglês';

  @override
  String get navGame => 'Jogo';

  @override
  String get navHistory => 'Histórico';

  @override
  String get navRanking => 'Ranking';

  @override
  String get navHelp => 'Ajuda';

  @override
  String get navSettings => 'Configurações';

  @override
  String get levelLabel => 'Nível';

  @override
  String get levelEasy => 'Fácil';

  @override
  String get levelIntermediate => 'Intermediário';

  @override
  String get levelAdvanced => 'Avançado';

  @override
  String get levelHard => 'Difícil';

  @override
  String get scoreLabel => 'Pontos';

  @override
  String get timeLabel => 'Tempo';

  @override
  String get plateBand => 'BRASIL';

  @override
  String get verify => 'Verificar';

  @override
  String get clear => 'Limpar';

  @override
  String get skip => 'Pular';

  @override
  String get nextPlate => 'Próxima placa';

  @override
  String get slotHint =>
      'Toque numa fenda (entre ou ao lado dos dígitos) para abrir a roda de operadores.';

  @override
  String slotSemantics(int index) {
    return 'Fenda $index';
  }

  @override
  String get moveEqualsLeft => 'Mover o = para a esquerda';

  @override
  String get moveEqualsRight => 'Mover o = para a direita';

  @override
  String get yourFormula => 'Sua fórmula';

  @override
  String get latexLabel => 'Renderização em LaTeX';

  @override
  String get successTitle => 'Placa emplacada!';

  @override
  String successMessage(int points) {
    return 'Correto! Você ganhou $points pontos.';
  }

  @override
  String get skippedMessage => 'Placa pulada. Sem problema, vem outra!';

  @override
  String get wheelTitle => 'Roda de operadores';

  @override
  String get wheelBackspace => 'Apagar o último';

  @override
  String get wheelClear => 'Esvaziar fenda';

  @override
  String get wheelDone => 'Pronto';

  @override
  String get wheelEmpty => 'fenda vazia';

  @override
  String get loadingPlate =>
      'Procurando uma placa que você ainda não resolveu…';

  @override
  String get allSolved =>
      'Uau! Não encontramos mais placas novas neste nível. Tente outro nível.';

  @override
  String get soundOn => 'Som ligado (toque para desligar)';

  @override
  String get soundOff => 'Som desligado (toque para ligar)';

  @override
  String get loadError => 'Não foi possível carregar os dados.';

  @override
  String get retry => 'Tentar de novo';

  @override
  String get saveError =>
      'Acertou, mas não deu para salvar na nuvem. Verifique a conexão.';

  @override
  String get historyTitle => 'Seu histórico';

  @override
  String get totalScore => 'Pontuação total';

  @override
  String solvedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count placas resolvidas',
      one: '1 placa resolvida',
      zero: 'Nenhuma placa resolvida',
    );
    return '$_temp0';
  }

  @override
  String get solvedByLevel => 'Por nível';

  @override
  String get recentSolved => 'Últimas placas resolvidas';

  @override
  String get noSolvedYet =>
      'Você ainda não resolveu nenhuma placa. Bora jogar!';

  @override
  String solvedIn(String level, int seconds) {
    return '$level · $seconds s';
  }

  @override
  String get rankingTitle => 'Ranking geral';

  @override
  String get rankingEmpty => 'Ninguém pontuou ainda. Seja o primeiro!';

  @override
  String get you => 'você';

  @override
  String get anonymousPlayer => 'Jogador anônimo';

  @override
  String points(int points) {
    return '$points pts';
  }

  @override
  String get settingsTitle => 'Configurações';

  @override
  String get appearance => 'Aparência';

  @override
  String get themeMode => 'Tema';

  @override
  String get themeSystem => 'Do aparelho';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Escuro';

  @override
  String get fontSize => 'Tamanho da fonte';

  @override
  String get fontFamily => 'Tipo da fonte';

  @override
  String get seedColor => 'Cor semente do tema';

  @override
  String get presetThemes => 'Temas prontos';

  @override
  String get presetOcean => 'Oceano';

  @override
  String get presetForest => 'Floresta';

  @override
  String get presetSunset => 'Pôr do sol';

  @override
  String get presetGrape => 'Uva';

  @override
  String get presetClassic => 'Clássico';

  @override
  String get presetTerminal => 'Terminal';

  @override
  String get previewText => 'Exemplo: √(8 + 1) = 3¹';

  @override
  String get sound => 'Efeitos sonoros';

  @override
  String get soundDescription =>
      'Desligado por padrão. Ligue se quiser ouvir os acertos e erros.';

  @override
  String get languageSetting => 'Idioma do aplicativo';

  @override
  String get account => 'Conta';

  @override
  String get signOut => 'Sair';

  @override
  String get resetSettings => 'Restaurar padrão';

  @override
  String get helpTitle => 'Como jogar';

  @override
  String get helpGoal =>
      'A placa mostra 4 dígitos. Sem mudar a ordem deles, insira operadores e o sinal de = para formar uma igualdade verdadeira.';

  @override
  String get helpSlots =>
      'Toque numa fenda (os espaços entre e ao lado dos dígitos) para abrir a roda de operadores. Cada toque na roda acrescenta um operador naquela fenda.';

  @override
  String get helpEquals =>
      'O = já está na placa: use as setas ao lado dele para mudar a posição.';

  @override
  String get helpJoin =>
      'Dígitos vizinhos sem operador entre eles formam um número só (2 e 8 viram 28).';

  @override
  String get helpDivision =>
      'Só o nível Fácil aceita divisões e raízes com resultado não inteiro.';

  @override
  String helpOperators(String level) {
    return 'Operadores do nível $level:';
  }

  @override
  String get helpExample => 'Exemplo com a placa 8 1 3 1:';

  @override
  String get helpSkip =>
      'Achou difícil? Use Pular para trocar de placa. Cada acerto vale mais pontos nos níveis mais difíceis.';

  @override
  String get close => 'Fechar';

  @override
  String get errMissingEquals => 'Falta o sinal de =.';

  @override
  String get errMultipleEquals => 'Use apenas um sinal de =.';

  @override
  String get errEmptySide => 'Um dos lados do = está vazio.';

  @override
  String get errUnexpectedToken => 'Tem um operador fora do lugar.';

  @override
  String get errUnexpectedEnd =>
      'A expressão terminou no meio de uma operação.';

  @override
  String get errUnbalanced =>
      'Parênteses ou barras não estão fechando direito.';

  @override
  String get errOperatorNotAllowed => 'Esse operador não existe neste nível.';

  @override
  String get errDivisionByZero => 'Divisão por zero não vale!';

  @override
  String get errNonIntegerDivision =>
      'Neste nível a divisão precisa dar um número inteiro.';

  @override
  String get errNonIntegerResult =>
      'Neste nível o resultado precisa ser inteiro.';

  @override
  String get errInexactRoot => 'Neste nível a raiz precisa ser exata.';

  @override
  String get errNegativeRoot =>
      'Não existe raiz quadrada real de número negativo.';

  @override
  String get errInvalidFactorial =>
      'Fatorial só de inteiros maiores ou iguais a zero.';

  @override
  String get errFactorialTooLarge => 'Fatorial grande demais (máximo 20!).';

  @override
  String get errInvalidExponent => 'Esse expoente não é permitido aqui.';

  @override
  String get errNumberTooLarge => 'O número ficou grande demais.';

  @override
  String errNotEqual(String left, String right) {
    return 'Os lados não são iguais: $left ≠ $right';
  }
}
