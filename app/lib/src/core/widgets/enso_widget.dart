import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A minimalist Ensō-inspired open circle.
///
/// The Ensō (円相) symbolises completeness, the universe, and the void —
/// themes central to Japanese martial arts. Rendered as a nearly-complete
/// circle with rounded stroke ends, it communicates meditative calm.
///
/// Keep [opacity] low for decorative use (0.12 – 0.25).
/// Raise it for focal elements such as loading states.
class EnsoDecoration extends StatelessWidget {
  const EnsoDecoration({
    this.size = 80.0,
    this.strokeWidth = 1.5,
    this.opacity = 0.18,
    super.key,
  });

  final double size;
  final double strokeWidth;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary.withAlpha(
      (opacity * 255).clamp(0, 255).round(),
    );
    return RepaintBoundary(
      child: CustomPaint(
        size: Size(size, size),
        painter: _EnsoPainter(color: color, strokeWidth: strokeWidth),
      ),
    );
  }
}

class _EnsoPainter extends CustomPainter {
  const _EnsoPainter({required this.color, required this.strokeWidth});

  final Color color;
  final double strokeWidth;

  // Where the brush lifts — a small intentional gap.
  static const _gapAngle = 0.42;

  @override
  void paint(Canvas canvas, Size size) {
    final inset = strokeWidth;
    final rect = Rect.fromLTWH(
      inset,
      inset,
      size.width - inset * 2,
      size.height - inset * 2,
    );

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = color;

    // Begin just past the gap; sweep almost the full circle.
    final startAngle = -math.pi / 2 + _gapAngle / 2;
    final sweepAngle = math.pi * 2 - _gapAngle;

    canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
  }

  @override
  bool shouldRepaint(_EnsoPainter old) =>
      old.color != color || old.strokeWidth != strokeWidth;
}
