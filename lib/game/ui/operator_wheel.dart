import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../engine/token.dart';
import '../state/game_controller.dart';

/// Abre a roda de operadores para a fenda [zone].
///
/// Anel interno: operadores binários (+ − × ÷ **).
/// Anel externo: parênteses, raízes, fatorial, módulo, base e teto.
/// Centro: o conteúdo atual da fenda, com botões de apagar.
Future<void> showOperatorWheel(BuildContext context, int zone) {
  final l10n = AppLocalizations.of(context);
  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: l10n.wheelDone,
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 380),
    pageBuilder: (context, _, __) => _OperatorWheel(zone: zone),
    transitionBuilder: (context, animation, _, child) {
      final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutBack);
      return FadeTransition(
        opacity: animation,
        child: RotationTransition(
          turns: Tween(begin: -0.12, end: 0.0).animate(curved),
          child: ScaleTransition(scale: curved, child: child),
        ),
      );
    },
  );
}

class _OperatorWheel extends ConsumerWidget {
  const _OperatorWheel({required this.zone});
  final int zone;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final game = ref.watch(gameProvider);
    final controller = ref.read(gameProvider.notifier);
    final tokens = game.zone(zone);
    final ops = game.level.orderedOperators;
    final inner = ops.where(Token.binaryKinds.contains).toList();
    final outer = ops.where((k) => !Token.binaryKinds.contains(k)).toList();

    final screen = MediaQuery.sizeOf(context);
    final size = math.min(400.0, math.min(screen.width, screen.height) - 32);
    final button = (size * 0.15).clamp(40.0, 60.0);

    return Center(
      child: Material(
        type: MaterialType.transparency,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: size,
              height: size,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Disco de fundo com dois anéis.
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: scheme.surfaceContainerHigh,
                      border: Border.all(color: scheme.primary, width: 3),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 24)],
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: 0.62,
                    heightFactor: 0.62,
                    child: DecoratedBox(
                      decoration: BoxDecoration(shape: BoxShape.circle, color: scheme.primaryContainer),
                    ),
                  ),
                  // Centro: o que já está na fenda (não captura cliques).
                  IgnorePointer(
                    child: SizedBox(
                      width: size * 0.22,
                      height: size * 0.14,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          tokens.isEmpty ? '·' : tokens.map((t) => t.symbol).join(),
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: scheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                    ),
                  ),
                  ..._ring(outer, size * 0.40, button, scheme.secondary, scheme.onSecondary,
                      (k) => controller.addToken(zone, k)),
                  ..._ring(inner, size * 0.205, button, scheme.primary, scheme.onPrimary,
                      (k) => controller.addToken(zone, k)),
                  
                ],
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                FilledButton.tonalIcon(
                  onPressed: tokens.isEmpty ? null : () => controller.backspace(zone),
                  icon: const Icon(Icons.backspace_outlined),
                  label: Text(l10n.wheelBackspace),
                ),
                FilledButton.tonalIcon(
                  onPressed: tokens.isEmpty ? null : () => controller.clearZone(zone),
                  icon: const Icon(Icons.delete_sweep_outlined),
                  label: Text(l10n.wheelClear),
                ),
                FilledButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.check),
                  label: Text(l10n.wheelDone),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Distribui os botões num círculo de raio [radius] em volta do centro.
  List<Widget> _ring(
    List<TokenKind> kinds,
    double radius,
    double button,
    Color bg,
    Color fg,
    void Function(TokenKind) onTap,
  ) {
    return [
      for (var i = 0; i < kinds.length; i++)
        Transform.translate(
          offset: Offset(
            radius * math.cos(-math.pi / 2 + 2 * math.pi * i / kinds.length),
            radius * math.sin(-math.pi / 2 + 2 * math.pi * i / kinds.length),
          ),
          child: SizedBox(
            width: button,
            height: button,
            child: Tooltip(
              message: Token.wheelLabelOf(kinds[i]),
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: bg,
                  foregroundColor: fg,
                  shape: const CircleBorder(),
                  padding: EdgeInsets.zero,
                ),
                onPressed: () => onTap(kinds[i]),
                child: FittedBox(
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Text(
                      Token.wheelLabelOf(kinds[i]),
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
    ];
  }
}
