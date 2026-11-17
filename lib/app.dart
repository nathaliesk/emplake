import 'package:firebase_ui_localizations/firebase_ui_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'l10n/app_localizations.dart';
import 'settings/settings_controller.dart';

class EmplakeApp extends ConsumerWidget {
  const EmplakeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      themeMode: settings.themeMode,
      theme: AppTheme.build(settings, Brightness.light),
      darkTheme: AppTheme.build(settings, Brightness.dark),
      locale: settings.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: [
        ...AppLocalizations.localizationsDelegates,
        FirebaseUILocalizations.delegate,
      ],
      localeResolutionCallback: (device, supported) {
        if (device == null) return supported.first;
        return supported.firstWhere(
          (l) => l.languageCode == device.languageCode,
          orElse: () => const Locale('en'),
        );
      },
      // Tamanho da fonte escolhido nas configurações vale para o app inteiro.
      builder: (context, child) {
        final mq = MediaQuery.of(context);
        return MediaQuery(
          data: mq.copyWith(textScaler: TextScaler.linear(settings.fontScale)),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
