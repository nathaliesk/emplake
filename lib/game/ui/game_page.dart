import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/app_loader.dart';
import '../../l10n/app_localizations.dart';
import '../../settings/settings_controller.dart';
import '../domain/level.dart';
import '../state/game_controller.dart';
import 'expression_track.dart';
import 'l10n_helpers.dart';
import 'plate_widgets.dart';

/// Tela principal do jogo.
class GamePage extends ConsumerStatefulWidget {
  const GamePage({super.key});

  @override
  ConsumerState<GamePage> createState() => _GamePageState();
}

class _GamePageState extends ConsumerState<GamePage> {
  /// Carrega do Firestore as placas já resolvidas antes de sortear a primeira.
  late Future<void> _loading;

  @override
  void initState() {
    super.initState();
    _loading = ref.read(gameProvider.notifier).ensureLoaded();
  }

  void _retry() => setState(() => _loading = ref.read(gameProvider.notifier).ensureLoaded());

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<void>(
          future: _loading,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return AppLoader(message: l10n.loadingPlate);
            }
            if (snapshot.hasError) {
              return ErrorRetry(message: l10n.loadError, retryLabel: l10n.retry, onRetry: _retry);
            }
            return const _GameBody();
          },
        ),
      ),
    );
  }
}

class _GameBody extends ConsumerWidget {
  const _GameBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(gameProvider.select((s) => s.status));
    final l10n = AppLocalizations.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 900;
        final Widget board = switch (status) {
          RoundStatus.loading => AppLoader(message: l10n.loadingPlate),
          RoundStatus.exhausted => _Exhausted(message: l10n.allSolved),
          _ => const _Board(),
        };

        if (wide) {
          // Computador / janela larga: placa à esquerda, painel à direita.
          return MaxWidth(
            maxWidth: 1280,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: SingleChildScrollView(child: board)),
                  const SizedBox(width: 24),
                  const SizedBox(width: 340, child: SingleChildScrollView(child: _SidePanel())),
                ],
              ),
            ),
          );
        }
        // Celular / tablet: tudo em coluna.
        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: constraints.maxWidth < 600 ? 12 : 32, vertical: 12),
          child: MaxWidth(
            maxWidth: 760,
            child: Column(
              children: [
                const _TopBar(),
                const SizedBox(height: 12),
                board,
                const SizedBox(height: 16),
                if (status != RoundStatus.loading) const _Actions(),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Painel lateral no layout largo.
class _SidePanel extends ConsumerWidget {
  const _SidePanel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(gameProvider.select((s) => s.status));
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _TopBar(vertical: true),
            const Divider(height: 32),
            if (status != RoundStatus.loading) const _Actions(vertical: true),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends ConsumerWidget {
  const _TopBar({this.vertical = false});
  final bool vertical;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final level = ref.watch(gameProvider.select((s) => s.level));
    final score = ref.watch(gameProvider.select((s) => s.score));
    final sound = ref.watch(settingsProvider.select((s) => s.soundEnabled));
    final scheme = Theme.of(context).colorScheme;

    final levelPicker = FittedBox(
      fit: BoxFit.scaleDown,
      child: SegmentedButton<Level>(
        showSelectedIcon: false,
        segments: [
          for (final l in Level.values) ButtonSegment(value: l, label: Text(l10n.levelName(l))),
        ],
        selected: {level},
        onSelectionChanged: (s) => ref.read(gameProvider.notifier).setLevel(s.first),
      ),
    );

    final stats = Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      alignment: vertical ? WrapAlignment.start : WrapAlignment.center,
      children: [
        Chip(
          avatar: Icon(Icons.emoji_events_outlined, color: scheme.primary),
          label: Text('${l10n.scoreLabel}: $score'),
        ),
        const _TimerChip(),
        IconButton.filledTonal(
          tooltip: sound ? l10n.soundOn : l10n.soundOff,
          icon: Icon(sound ? Icons.volume_up : Icons.volume_off),
          onPressed: () => ref.read(settingsProvider.notifier).setSoundEnabled(!sound),
        ),
      ],
    );

    return Column(
      crossAxisAlignment: vertical ? CrossAxisAlignment.stretch : CrossAxisAlignment.center,
      children: [
        Text(l10n.levelLabel, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 6),
        levelPicker,
        const SizedBox(height: 12),
        stats,
      ],
    );
  }
}

/// Cronômetro da placa atual (só para exibição e para salvar o tempo gasto).
class _TimerChip extends ConsumerStatefulWidget {
  const _TimerChip();

  @override
  ConsumerState<_TimerChip> createState() => _TimerChipState();
}

class _TimerChipState extends ConsumerState<_TimerChip> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final game = ref.watch(gameProvider);
    final running = game.status == RoundStatus.playing || game.status == RoundStatus.error;
    final secs = running ? DateTime.now().difference(game.startedAt).inSeconds : 0;
    final mm = (secs ~/ 60).toString().padLeft(2, '0');
    final ss = (secs % 60).toString().padLeft(2, '0');
    return Chip(
      avatar: const Icon(Icons.timer_outlined),
      label: Text('${l10n.timeLabel}: $mm:$ss'),
    );
  }
}

/// Placa + fórmula + LaTeX + mensagens.
class _Board extends ConsumerWidget {
  const _Board();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final game = ref.watch(gameProvider);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final plate = game.plate;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ShakeOnChange(
          trigger: game.errorTick,
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFE9E9E4),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFF262626), width: 4),
              boxShadow: [
                BoxShadow(color: scheme.shadow.withValues(alpha: 0.25), blurRadius: 18, offset: const Offset(0, 8)),
              ],
            ),
            child: Column(
              children: [
                // Faixa superior: país, UF, cidade e letras da placa.
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: scheme.primary,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(17)),
                  ),
                  child: DefaultTextStyle(
                    style: theme.textTheme.titleSmall!.copyWith(
                      color: scheme.onPrimary,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                    ),
                    child: Row(
                      children: [
                        Text(l10n.plateBand),
                        const Spacer(),
                        Flexible(
                          child: Text(
                            '${plate.uf} · ${plate.city}',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: scheme.onPrimary.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(plate.letters),
                        ),
                      ],
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 20),
                  child: ExpressionTrack(),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Icon(Icons.touch_app_outlined, size: 18, color: scheme.onSurfaceVariant),
            const SizedBox(width: 6),
            Expanded(
              child: Text(l10n.slotHint,
                  style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _FormulaCard(expression: game.expression, latex: game.latex),
        const SizedBox(height: 14),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) => SizeTransition(
            sizeFactor: animation,
            child: FadeTransition(opacity: animation, child: child),
          ),
          child: _statusMessage(context, game, l10n),
        ),
      ],
    );
  }

  Widget _statusMessage(BuildContext context, GameState game, AppLocalizations l10n) {
    final scheme = Theme.of(context).colorScheme;
    if (game.status == RoundStatus.error && game.error != null) {
      return Card(
        key: ValueKey('err${game.errorTick}'),
        color: scheme.errorContainer,
        child: ListTile(
          leading: Icon(Icons.error_outline, color: scheme.onErrorContainer),
          title: Text(
            l10n.errorMessage(game.error!, left: game.errorLeft, right: game.errorRight),
            style: TextStyle(color: scheme.onErrorContainer),
          ),
        ),
      );
    }
    if (game.status == RoundStatus.success) {
      return Card(
        key: const ValueKey('success'),
        color: scheme.tertiaryContainer,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(Icons.verified, color: scheme.onTertiaryContainer, size: 32),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.successTitle,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: scheme.onTertiaryContainer,
                                  fontWeight: FontWeight.w800,
                                )),
                        Text(l10n.successMessage(game.lastPoints),
                            style: TextStyle(color: scheme.onTertiaryContainer)),
                      ],
                    ),
                  ),
                ],
              ),
              if (game.solvedLatex != null) ...[
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Math.tex(
                    game.solvedLatex!,
                    textStyle: TextStyle(fontSize: 24, color: scheme.onTertiaryContainer),
                    onErrorFallback: (e) => Text(game.solvedLatex!),
                  ),
                ),
              ],
              if (game.saveFailed) ...[
                const SizedBox(height: 8),
                Text(l10n.saveError, style: TextStyle(color: scheme.error)),
              ],
            ],
          ),
        ),
      );
    }
    return const SizedBox.shrink(key: ValueKey('none'));
  }
}

/// Fórmula montada (símbolos) e, logo abaixo, a renderização em LaTeX.
class _FormulaCard extends StatelessWidget {
  const _FormulaCard({required this.expression, required this.latex});
  final String expression;
  final String latex;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.yourFormula, style: theme.textTheme.labelMedium),
            const SizedBox(height: 4),
            SelectableText(
              expression,
              style: theme.textTheme.titleLarge?.copyWith(
                fontFeatures: const [FontFeature.tabularFigures()],
                letterSpacing: 1,
              ),
            ),
            const Divider(height: 24),
            Text(l10n.latexLabel, style: theme.textTheme.labelMedium),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Math.tex(
                latex,
                mathStyle: MathStyle.display,
                textStyle: TextStyle(fontSize: 26, color: theme.colorScheme.onSurface),
                onErrorFallback: (e) => Text(latex, style: theme.textTheme.bodyMedium),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Actions extends ConsumerWidget {
  const _Actions({this.vertical = false});
  final bool vertical;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final game = ref.watch(gameProvider);
    final controller = ref.read(gameProvider.notifier);
    final solved = game.status == RoundStatus.success;
    final exhausted = game.status == RoundStatus.exhausted;

    final buttons = <Widget>[
      if (solved)
        FilledButton.icon(
          onPressed: game.returning ? null : controller.next,
          icon: const Icon(Icons.arrow_forward),
          label: Text(l10n.nextPlate),
        )
      else if (!exhausted)
        FilledButton.icon(
          onPressed: controller.verify,
          icon: const Icon(Icons.fact_check_outlined),
          label: Text(l10n.verify),
        ),
      if (!solved && !exhausted)
        OutlinedButton.icon(
          onPressed: game.hasOperators ? controller.clearAll : null,
          icon: const Icon(Icons.cleaning_services_outlined),
          label: Text(l10n.clear),
        ),
      if (!solved)
        TextButton.icon(
          onPressed: controller.skip,
          icon: const Icon(Icons.skip_next),
          label: Text(l10n.skip),
        ),
    ];

    if (vertical) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final b in buttons) Padding(padding: const EdgeInsets.only(bottom: 10), child: b),
        ],
      );
    }
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: buttons,
    );
  }
}

class _Exhausted extends StatelessWidget {
  const _Exhausted({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            const Icon(Icons.celebration_outlined, size: 64),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      );
}
