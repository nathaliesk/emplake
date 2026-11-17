import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../help/help_dialog.dart';
import '../l10n/app_localizations.dart';

/// Moldura comum a todas as páginas depois do login: conteúdo + barra
/// inferior curva (curved_navigation_bar), sempre visível.
///
/// Itens da barra: Jogo, Histórico, Ranking, Ajuda (abre um diálogo) e
/// Configurações.
class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  static const _helpIndex = 3;
  final _barKey = GlobalKey<CurvedNavigationBarState>();

  /// Converte índice do ramo (rotas) para índice da barra (que tem a Ajuda no meio).
  int _barIndexFor(int branch) => branch >= _helpIndex ? branch + 1 : branch;
  int _branchFor(int barIndex) => barIndex > _helpIndex ? barIndex - 1 : barIndex;

  Future<void> _onTap(int index) async {
    if (index == _helpIndex) {
      await showHelpDialog(context);
      // A barra anima até o botão tocado; devolve a seleção para a página atual.
      _barKey.currentState?.setPage(_barIndexFor(widget.navigationShell.currentIndex));
      return;
    }
    final branch = _branchFor(index);
    widget.navigationShell.goBranch(
      branch,
      initialLocation: branch == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final items = <(IconData, String)>[
      (Icons.grid_view_rounded, l10n.navGame),
      (Icons.history, l10n.navHistory),
      (Icons.leaderboard_outlined, l10n.navRanking),
      (Icons.help_outline, l10n.navHelp),
      (Icons.settings_outlined, l10n.navSettings),
    ];

    return Scaffold(
      body: widget.navigationShell,
      extendBody: false,
      bottomNavigationBar: CurvedNavigationBar(
        key: _barKey,
        index: _barIndexFor(widget.navigationShell.currentIndex),
        height: 62,
        color: scheme.primaryContainer,
        buttonBackgroundColor: scheme.primary,
        backgroundColor: scheme.surface,
        animationDuration: const Duration(milliseconds: 350),
        items: [
          for (var i = 0; i < items.length; i++)
            Tooltip(
              message: items[i].$2,
              child: Semantics(
                label: items[i].$2,
                child: Icon(
                  items[i].$1,
                  size: 28,
                  color: i == _barIndexFor(widget.navigationShell.currentIndex)
                      ? scheme.onPrimary
                      : scheme.onPrimaryContainer,
                ),
              ),
            ),
        ],
        onTap: _onTap,
      ),
    );
  }
}
