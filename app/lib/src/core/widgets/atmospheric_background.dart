import 'package:flutter/material.dart';

/// Extremely subtle atmospheric background inspired by Japanese aesthetics.
///
/// Draws barely-visible enso-like arcs and a faint koi silhouette using the
/// gold accent colour at very low opacity. The effect is perceptible only
/// when the eye is looking for it, and never distracts from content.
///
/// Usage: place behind screen content using a [Stack]:
///
/// ```dart
/// Stack(
///   children: [
///     const Positioned.fill(child: AtmosphericBackground()),
///     // your content
///   ],
/// )
/// ```
class AtmosphericBackground extends StatelessWidget {
  const AtmosphericBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return RepaintBoundary(
      child: CustomPaint(
        painter: _AtmosphericPainter(isDark: isDark),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _AtmosphericPainter extends CustomPainter {
  const _AtmosphericPainter({required this.isDark});

  final bool isDark;

  static const _gold = Color(0xFFC8A84A);

  @override
  void paint(Canvas canvas, Size size) {
    final arcAlpha = isDark ? 10 : 13;
    final arcAlpha2 = isDark ? 7 : 9;
    final koiAlpha = isDark ? 8 : 11;

    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..color = _gold.withAlpha(arcAlpha);

    // Large enso-inspired arc — upper-right.
    canvas.drawArc(
      Rect.fromCircle(
        center: Offset(size.width * 1.05, size.height * -0.05),
        radius: size.width * 0.72,
      ),
      1.15,
      2.1,
      false,
      stroke,
    );

    // Answering arc — lower-left.
    canvas.drawArc(
      Rect.fromCircle(
        center: Offset(size.width * -0.12, size.height * 1.08),
        radius: size.width * 0.52,
      ),
      -0.55,
      1.9,
      false,
      stroke..color = _gold.withAlpha(arcAlpha2),
    );

    // Koi silhouette — mid-right, almost invisible.
    _drawKoi(canvas, size, koiAlpha);
  }

  void _drawKoi(Canvas canvas, Size size, int alpha) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.55
      ..strokeCap = StrokeCap.round
      ..color = _gold.withAlpha(alpha);

    // Position in the mid-right area; scale relative to canvas.
    final cx = size.width * 0.80;
    final cy = size.height * 0.40;
    final bx = size.width * 0.075;
    final by = size.height * 0.040;

    // Body.
    final body = Path()
      ..moveTo(cx + bx, cy)
      ..cubicTo(cx + bx * 0.5, cy - by, cx - bx * 0.3, cy - by * 0.9, cx - bx, cy)
      ..cubicTo(cx - bx * 0.3, cy + by * 0.9, cx + bx * 0.5, cy + by, cx + bx, cy);
    canvas.drawPath(body, paint);

    // Tail lobes.
    final tail = Path()
      ..moveTo(cx - bx, cy)
      ..cubicTo(cx - bx * 1.3, cy - by * 0.28, cx - bx * 1.62, cy - by * 0.58, cx - bx * 1.82, cy - by * 0.38)
      ..moveTo(cx - bx, cy)
      ..cubicTo(cx - bx * 1.3, cy + by * 0.28, cx - bx * 1.62, cy + by * 0.58, cx - bx * 1.82, cy + by * 0.38);
    canvas.drawPath(tail, paint);

    // Dorsal fin.
    final fin = Path()
      ..moveTo(cx + bx * 0.18, cy - by * 0.88)
      ..cubicTo(cx, cy - by * 1.32, cx - bx * 0.38, cy - by * 1.25, cx - bx * 0.52, cy - by * 0.88);
    canvas.drawPath(fin, paint);
  }

  @override
  bool shouldRepaint(_AtmosphericPainter old) => old.isDark != isDark;
}

