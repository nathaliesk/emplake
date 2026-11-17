import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../settings/settings_controller.dart';
import 'flags.dart';

/// Botões de idioma com bandeira (login e configurações).
class LanguageSelector extends ConsumerWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final current = Localizations.localeOf(context).languageCode;
    final options = [('pt', l10n.portuguese), ('en', l10n.english)];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        for (final (code, label) in options)
          ChoiceChip(
            avatar: FlagIcon(languageCode: code, width: 26),
            label: Text(label),
            selected: current == code,
            showCheckmark: false,
            onSelected: (_) => ref.read(settingsProvider.notifier).setLanguage(code),
          ),
      ],
    );
  }
}
