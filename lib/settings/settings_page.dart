import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:firebase_ui_auth/firebase_ui_auth.dart' show FirebaseUIAuth;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/widgets/app_loader.dart';
import '../core/widgets/language_selector.dart';
import '../game/state/game_controller.dart';
import '../l10n/app_localizations.dart';
import 'settings_controller.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final s = ref.watch(settingsProvider);
    final c = ref.read(settingsProvider.notifier);
    final theme = Theme.of(context);

    String presetName(ThemePreset p) => switch (p) {
          ThemePreset.ocean => l10n.presetOcean,
          ThemePreset.forest => l10n.presetForest,
          ThemePreset.sunset => l10n.presetSunset,
          ThemePreset.grape => l10n.presetGrape,
          ThemePreset.classic => l10n.presetClassic,
          ThemePreset.terminal => l10n.presetTerminal,
        };

    final sections = <Widget>[
      _Section(
        title: l10n.appearance,
        icon: Icons.palette_outlined,
        children: [
          Text(l10n.themeMode, style: theme.textTheme.labelLarge),
          const SizedBox(height: 8),
          SegmentedButton<ThemeMode>(
            segments: [
              ButtonSegment(value: ThemeMode.system, icon: const Icon(Icons.brightness_auto), label: Text(l10n.themeSystem)),
              ButtonSegment(value: ThemeMode.light, icon: const Icon(Icons.light_mode), label: Text(l10n.themeLight)),
              ButtonSegment(value: ThemeMode.dark, icon: const Icon(Icons.dark_mode), label: Text(l10n.themeDark)),
            ],
            selected: {s.themeMode},
            onSelectionChanged: (v) => c.setThemeMode(v.first),
          ),
          const SizedBox(height: 20),
          Text('${l10n.fontSize}: ${(s.fontScale * 100).round()}%', style: theme.textTheme.labelLarge),
          Slider(
            value: s.fontScale,
            min: 0.8,
            max: 1.5,
            divisions: 7,
            label: '${(s.fontScale * 100).round()}%',
            onChanged: c.setFontScale,
          ),
          const SizedBox(height: 8),
          DropdownMenu<String>(
            initialSelection: s.fontFamily,
            label: Text(l10n.fontFamily),
            expandedInsets: EdgeInsets.zero,
            dropdownMenuEntries: [
              for (final f in availableFonts)
                DropdownMenuEntry(value: f, label: f, style: MenuItemButton.styleFrom(textStyle: GoogleFonts.getFont(f))),
            ],
            onSelected: (f) {
              if (f != null) c.setFontFamily(f);
            },
          ),
          const SizedBox(height: 20),
          Text(l10n.seedColor, style: theme.textTheme.labelLarge),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final color in seedPalette)
                _ColorDot(
                  color: color,
                  selected: color.toARGB32() == s.seedColor.toARGB32(),
                  onTap: () => c.setSeedColor(color),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Text(l10n.presetThemes, style: theme.textTheme.labelLarge),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final p in ThemePreset.values)
                ActionChip(
                  avatar: CircleAvatar(backgroundColor: p.seed, radius: 8),
                  label: Text(presetName(p), style: GoogleFonts.getFont(p.font)),
                  onPressed: () => c.applyPreset(p),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Card(
            color: theme.colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                l10n.previewText,
                style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onPrimaryContainer),
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: c.reset,
              icon: const Icon(Icons.restart_alt),
              label: Text(l10n.resetSettings),
            ),
          ),
        ],
      ),
      _Section(
        title: l10n.sound,
        icon: Icons.music_note_outlined,
        children: [
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.sound),
            subtitle: Text(l10n.soundDescription),
            value: s.soundEnabled,
            onChanged: c.setSoundEnabled,
          ),
        ],
      ),
      _Section(
        title: l10n.languageSetting,
        icon: Icons.translate,
        children: const [LanguageSelector()],
      ),
      _Section(
        title: l10n.account,
        icon: Icons.person_outline,
        children: [
          _AccountTile(onSignOut: () async {
            // Limpa o estado do jogo antes de trocar de conta.
            ref.invalidate(gameProvider);
            await FirebaseUIAuth.signOut();
          }),
        ],
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: LayoutBuilder(builder: (context, constraints) {
        final twoColumns = constraints.maxWidth >= 1000;
        if (twoColumns) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: MaxWidth(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: sections.first),
                  const SizedBox(width: 16),
                  Expanded(child: Column(children: sections.skip(1).toList())),
                ],
              ),
            ),
          );
        }
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [for (final s in sections) MaxWidth(maxWidth: 720, child: s)],
        );
      }),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.icon, required this.children});
  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icon, color: theme.colorScheme.primary),
              const SizedBox(width: 10),
              Text(title, style: theme.textTheme.titleLarge),
            ]),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _ColorDot extends StatelessWidget {
  const _ColorDot({required this.color, required this.selected, required this.onTap});
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: 24,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? Theme.of(context).colorScheme.onSurface : Colors.transparent,
            width: 3,
          ),
        ),
        child: selected ? const Icon(Icons.check, color: Colors.white) : null,
      ),
    );
  }
}

class _AccountTile extends StatelessWidget {
  const _AccountTile({required this.onSignOut});
  final Future<void> Function() onSignOut;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final user = FirebaseAuth.instance.currentUser;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundImage: user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
        child: user?.photoURL == null ? const Icon(Icons.person) : null,
      ),
      title: Text(user?.displayName ?? user?.email ?? ''),
      subtitle: user?.displayName != null ? Text(user?.email ?? '') : null,
      trailing: FilledButton.tonalIcon(
        onPressed: onSignOut,
        icon: const Icon(Icons.logout),
        label: Text(l10n.signOut),
      ),
    );
  }
}
