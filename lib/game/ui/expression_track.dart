import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../engine/token.dart';
import '../state/game_controller.dart';
import 'operator_wheel.dart';

/// A placa interativa: dígitos fixos e "fendas" entre eles.
///
/// Tocar numa fenda abre a roda de operadores. O "=" fica sempre visível e
/// muda de fenda com as setinhas.
class ExpressionTrack extends ConsumerWidget {
  const ExpressionTrack({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(gameProvider);
    final digits = game.digits;
    final children = <Widget>[];
    for (var i = 0; i < 5; i++) {
      children.add(_Zone(index: i, tokens: game.zones[i], returning: game.returning));
      if (i == game.equalsGap) {
        children.add(_EqualsChip(gap: game.equalsGap));
        children.add(_Zone(index: afterEqualsZone, tokens: game.afterEquals, returning: game.returning));
      }
      if (i < 4) children.add(_DigitTile(digit: digits[i]));
    }
    // FittedBox encolhe a placa em telas estreitas em vez de quebrar o layout.
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(mainAxisSize: MainAxisSize.min, children: children),
    );
  }
}

class _DigitTile extends StatelessWidget {
  const _DigitTile({required this.digit});
  final int digit;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      transitionBuilder: (child, animation) => RotationTransition(
        turns: Tween(begin: 0.5, end: 1.0).animate(animation),
        child: FadeTransition(opacity: animation, child: child),
      ),
      child: Container(
        key: ValueKey(digit),
        width: 64,
        height: 92,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFFF7F7F4),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF2A2A2A), width: 2.5),
          boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 6, offset: Offset(0, 3))],
        ),
        child: Text(
          '$digit',
          style: const TextStyle(
            fontSize: 64,
            height: 1,
            fontWeight: FontWeight.w900,
            color: Color(0xFF151515),
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        ),
      ),
    );
  }
}

/// Uma fenda: vazia aparece como um traço pontilhado; com operadores,
/// mostra as fichas. Tocar abre a roda.
class _Zone extends StatelessWidget {
  const _Zone({required this.index, required this.tokens, required this.returning});

  final int index;
  final List<Token> tokens;
  final bool returning;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final empty = tokens.isEmpty;
    return Semantics(
      button: true,
      label: l10n.slotSemantics(index + 1),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => showOperatorWheel(context, index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          alignment: Alignment.center,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          padding: EdgeInsets.symmetric(horizontal: empty ? 0 : 6),
          constraints: BoxConstraints(minWidth: empty ? 26 : 34, minHeight: 92),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: empty ? Colors.transparent : scheme.secondaryContainer,
            border: Border.all(
              color: empty ? scheme.outline.withValues(alpha: 0.6) : scheme.secondary,
              width: empty ? 1.5 : 2,
            ),
          ),
          child: empty
              ? Icon(Icons.add, size: 16, color: scheme.outline)
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var i = 0; i < tokens.length; i++)
                      _TokenChip(token: tokens[i], order: i, returning: returning),
                  ],
                ),
        ),
      ),
    );
  }
}

/// Ficha de operador. Depois de um acerto, as fichas "voltam para a roda":
/// descem e somem em sequência (animação implícita escalonada).
class _TokenChip extends StatelessWidget {
  const _TokenChip({required this.token, required this.order, required this.returning});

  final Token token;
  final int order;
  final bool returning;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final duration = Duration(milliseconds: 380 + order * 70);
    return AnimatedSlide(
      duration: duration,
      curve: Curves.easeInBack,
      offset: returning ? const Offset(0, 2.6) : Offset.zero,
      child: AnimatedOpacity(
        duration: duration,
        opacity: returning ? 0 : 1,
        child: AnimatedScale(
          duration: duration,
          scale: returning ? 0.3 : 1,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1),
            child: Text(
              token.symbol,
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.w800,
                color: scheme.onSecondaryContainer,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EqualsChip extends ConsumerWidget {
  const _EqualsChip({required this.gap});
  final int gap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final controller = ref.read(gameProvider.notifier);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 3),
      height: 92,
      decoration: BoxDecoration(
        color: scheme.tertiary,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '=',
            style: TextStyle(fontSize: 40, height: 1, fontWeight: FontWeight.w900, color: scheme.onTertiary),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _Arrow(
                icon: Icons.chevron_left,
                tooltip: l10n.moveEqualsLeft,
                onTap: gap > 1 ? () => controller.moveEquals(-1) : null,
                color: scheme.onTertiary,
              ),
              _Arrow(
                icon: Icons.chevron_right,
                tooltip: l10n.moveEqualsRight,
                onTap: gap < 3 ? () => controller.moveEquals(1) : null,
                color: scheme.onTertiary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Arrow extends StatelessWidget {
  const _Arrow({required this.icon, required this.tooltip, required this.onTap, required this.color});
  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkResponse(
        onTap: onTap,
        radius: 18,
        child: Icon(icon, size: 26, color: onTap == null ? color.withValues(alpha: 0.35) : color),
      ),
    );
  }
}
