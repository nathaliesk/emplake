import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Bandeiras desenhadas com CustomPainter (não dependem de imagens ou emoji,
/// que não aparecem em todos os navegadores).
class FlagIcon extends StatelessWidget {
  const FlagIcon({super.key, required this.languageCode, this.width = 36});

  final String languageCode;
  final double width;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: SizedBox(
        width: width,
        height: width * 0.7,
        child: CustomPaint(
          painter: languageCode == 'pt' ? _BrazilPainter() : _UsaPainter(),
        ),
      ),
    );
  }
}

class _BrazilPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    canvas.drawRect(Offset.zero & s, Paint()..color = const Color(0xFF009C3B));
    final m = s.width * 0.08;
    final rhombus = Path()
      ..moveTo(s.width / 2, m)
      ..lineTo(s.width - m, s.height / 2)
      ..lineTo(s.width / 2, s.height - m)
      ..lineTo(m, s.height / 2)
      ..close();
    canvas.drawPath(rhombus, Paint()..color = const Color(0xFFFFDF00));
    final center = Offset(s.width / 2, s.height / 2);
    final r = s.height * 0.26;
    canvas.drawCircle(center, r, Paint()..color = const Color(0xFF002776));
    // Faixa branca levemente curva.
    final band = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.22;
    canvas.save();
    canvas.clipPath(Path()..addOval(Rect.fromCircle(center: center, radius: r)));
    canvas.drawArc(
      Rect.fromCircle(center: center.translate(-r * 0.4, r * 1.6), radius: r * 2),
      -math.pi * 0.62,
      math.pi * 0.42,
      false,
      band,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _UsaPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    final stripe = s.height / 13;
    for (var i = 0; i < 13; i++) {
      canvas.drawRect(
        Rect.fromLTWH(0, i * stripe, s.width, stripe + 0.5),
        Paint()..color = i.isEven ? const Color(0xFFB22234) : Colors.white,
      );
    }
    final canton = Rect.fromLTWH(0, 0, s.width * 0.42, stripe * 7);
    canvas.drawRect(canton, Paint()..color = const Color(0xFF3C3B6E));
    final star = Paint()..color = Colors.white;
    for (var row = 0; row < 4; row++) {
      for (var col = 0; col < 5; col++) {
        canvas.drawCircle(
          Offset(canton.width * (col + 0.6) / 5.2, canton.height * (row + 0.6) / 4.2),
          s.width * 0.012,
          star,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
