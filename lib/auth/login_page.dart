import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/widgets/language_selector.dart';
import '../game/ui/plate_widgets.dart';
import '../l10n/app_localizations.dart';

/// Integrantes do grupo (requisito: aparecer na página de login).
const teamMembers = ['Nathalie Santos Komatsu'];

/// Login com e-mail/senha ou Google, gerenciado pelo Firebase (firebase_ui_auth).
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SignInScreen(
      breakpoint: 840,
      showPasswordVisibilityToggle: true,
      headerMaxExtent: 220,
      headerBuilder: (context, constraints, shrinkOffset) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 8),
        child: Center(child: LogoPlate(text: l10n.appTitle.toUpperCase())),
      ),
      sideBuilder: (context, constraints) => _SidePanel(l10n: l10n),
      subtitleBuilder: (context, action) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(l10n.loginSubtitle),
      ),
      footerBuilder: (context, action) => Padding(
        padding: const EdgeInsets.only(top: 24),
        child: Column(
          children: [
            Text(l10n.language, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            const LanguageSelector(),
            const SizedBox(height: 24),
            const _TeamCard(),
          ],
        ),
      ),
      actions: [
        AuthStateChangeAction<SignedIn>((context, state) => context.go('/game')),
        AuthStateChangeAction<UserCreated>((context, state) => context.go('/game')),
      ],
    );
  }
}

class _SidePanel extends StatelessWidget {
  const _SidePanel({required this.l10n});
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: theme.colorScheme.primaryContainer,
      padding: const EdgeInsets.all(48),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LogoPlate(text: l10n.appTitle.toUpperCase(), large: true),
              const SizedBox(height: 32),
              Text(
                l10n.loginTagline,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall
                    ?.copyWith(color: theme.colorScheme.onPrimaryContainer),
              ),
              const SizedBox(height: 32),
              const _TeamCard(),
            ],
          ),
        ),
      ),
    );
  }
}

class _TeamCard extends StatelessWidget {
  const _TeamCard();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.teamMember, style: theme.textTheme.labelMedium),
            const SizedBox(height: 4),
            for (final name in teamMembers)
              Text(name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(l10n.courseInfo, style: theme.textTheme.bodySmall, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
