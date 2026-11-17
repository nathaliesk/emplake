import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'firebase_options.dart';
import 'settings/settings_controller.dart';

/// Client ID web do OAuth do Google (Firebase → Authentication → Google →
/// "Configuração do SDK da Web" → ID do cliente da Web).
const googleClientId = String.fromEnvironment(
  'GOOGLE_CLIENT_ID',
  defaultValue: '883435653412-ulsa6g10pivf7qqdjp9k05u1sd4q3nfd.apps.googleusercontent.com',
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseUIAuth.configureProviders([
    EmailAuthProvider(),
    GoogleProvider(clientId: googleClientId),
  ]);

  final prefs = await SharedPreferences.getInstance();

  // Espera o Firebase restaurar a sessão antes de decidir a primeira rota;
  // sem isso, quem já estava logado veria a tela de login por um instante.
  await FirebaseAuth.instance.authStateChanges().first;

  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const EmplakeApp(),
    ),
  );
}
