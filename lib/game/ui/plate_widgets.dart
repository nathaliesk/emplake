import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Placa pequena usada como logotipo (login).
class LogoPlate extends StatelessWidget {
  const LogoPlate({super.key, required this.text, this.large = false});

  final String text;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final w = large ? 340.0 : 240.0;
    return Container(
      width: w,
      decoration: BoxDecoration(
        color: const Color(0xFFF4F4F2),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF2B2B2B), width: 3),
        boxShadow: [BoxShadow(color: scheme.shadow.withValues(alpha: 0.25), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: large ? 30 : 22,
            decoration: BoxDecoration(
              color: scheme.primary,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
            ),
            alignment: Alignment.center,
            child: Text(
              '= ? =',
              style: TextStyle(color: scheme.onPrimary, fontWeight: FontWeight.w800, letterSpacing: 6),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: large ? 14 : 8),
            child: Text(
              text,
              style: TextStyle(
                fontSize: large ? 52 : 38,
                fontWeight: FontWeight.w900,
                letterSpacing: 6,
                color: const Color(0xFF1C1C1C),
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Faz o filho "tremer" sempre que [trigger] muda (feedback de erro).
/// Animação explícita com AnimationController.
class ShakeOnChange extends StatefulWidget {
  const ShakeOnChange({super.key, required this.trigger, required this.child});

  final int trigger;
  final Widget child;

  @override
  State<ShakeOnChange> createState() => _ShakeOnChangeState();
}

class _ShakeOnChangeState extends State<ShakeOnChange> with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 450));

  @override
  void didUpdateWidget(covariant ShakeOnChange oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.trigger != widget.trigger) _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        final t = _controller.value;
        final dx = math.sin(t * math.pi * 6) * 10 * (1 - t);
        return Transform.translate(offset: Offset(dx, 0), child: child);
      },
    );
  }
}
