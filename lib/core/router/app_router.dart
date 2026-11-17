import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../auth/login_page.dart';
import '../../game/ui/game_page.dart';
import '../../history/history_page.dart';
import '../../ranking/ranking_page.dart';
import '../../settings/settings_controller.dart';
import '../../settings/settings_page.dart';
import '../../shell/app_shell.dart';

/// Caminhos das páginas.
abstract final class Routes {
  static const login = '/login';
  static const game = '/game';
  static const history = '/history';
  static const ranking = '/ranking';
  static const settings = '/settings';

  static const shellPages = [game, history, ranking, settings];
}

/// Guarda e recupera a última página visitada (requisito: ao reabrir o app,
/// ele volta para onde estava).
class RouteMemory {
  static const _key = 'nav.lastRoute';

  static String? read(SharedPreferences prefs) {
    final saved = prefs.getString(_key);
    return Routes.shellPages.contains(saved) ? saved : null;
  }

  static void write(SharedPreferences prefs, String location) {
    if (Routes.shellPages.contains(location)) prefs.setString(_key, location);
  }
}

/// Faz o go_router reavaliar o redirect quando o login muda.
class _AuthRefresh extends ChangeNotifier {
  _AuthRefresh(Stream<User?> stream) {
    _sub = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<User?> _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final prefs = ref.read(sharedPreferencesProvider);
  final auth = FirebaseAuth.instance;
  final refresh = _AuthRefresh(auth.authStateChanges());

  final router = GoRouter(
    initialLocation: RouteMemory.read(prefs) ?? Routes.game,
    refreshListenable: refresh,
    debugLogDiagnostics: kDebugMode,
    redirect: (context, state) {
      final loggedIn = auth.currentUser != null;
      final atLogin = state.matchedLocation == Routes.login;
      if (!loggedIn) return atLogin ? null : Routes.login;
      if (atLogin) return RouteMemory.read(prefs) ?? Routes.game;
      return null;
    },
    routes: [
      GoRoute(
        path: Routes.login,
        pageBuilder: (context, state) => const NoTransitionPage(child: LoginPage()),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: Routes.game, builder: (context, state) => const GamePage()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: Routes.history, builder: (context, state) => const HistoryPage()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: Routes.ranking, builder: (context, state) => const RankingPage()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: Routes.settings, builder: (context, state) => const SettingsPage()),
          ]),
        ],
      ),
    ],
  );

  void remember() {
    final location = router.routerDelegate.currentConfiguration.uri.path;
    RouteMemory.write(prefs, location);
  }

  router.routerDelegate.addListener(remember);
  ref.onDispose(() {
    router.routerDelegate.removeListener(remember);
    refresh.dispose();
    router.dispose();
  });
  return router;
});
