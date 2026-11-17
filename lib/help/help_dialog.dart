import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../game/engine/token.dart';
import '../game/state/game_controller.dart';
import '../game/ui/l10n_helpers.dart';
import '../l10n/app_localizations.dart';

/// Ajuda aberta pelo botão da barra inferior (showDialog).
Future<void> showHelpDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (context) => const _HelpDialog(),
  );
}

class _HelpDialog extends ConsumerWidget {
  const _HelpDialog();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final level = ref.watch(gameProvider.select((s) => s.level));

    Widget item(IconData icon, String text) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 22, color: theme.colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(child: Text(text)),
            ],
          ),
        );

    return AlertDialog(
      icon: const Icon(Icons.lightbulb_outline),
      title: Text(l10n.helpTitle),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              item(Icons.flag_outlined, l10n.helpGoal),
              item(Icons.touch_app_outlined, l10n.helpSlots),
              item(Icons.drag_handle, l10n.helpEquals),
              item(Icons.link, l10n.helpJoin),
              item(Icons.percent, l10n.helpDivision),
              item(Icons.skip_next, l10n.helpSkip),
              const SizedBox(height: 4),
              Text(l10n.helpOperators(l10n.levelName(level)), style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final k in level.orderedOperators) Chip(label: Text(Token.wheelLabelOf(k))),
                ],
              ),
              const SizedBox(height: 16),
              Text(l10n.helpExample, style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),
              Center(
                child: Math.tex(
                  r'\sqrt{8 + 1} = 3 \times 1 \qquad 8 - 1 = 3! + 1',
                  textStyle: const TextStyle(fontSize: 22),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        FilledButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.close)),
      ],
    );
  }
}
