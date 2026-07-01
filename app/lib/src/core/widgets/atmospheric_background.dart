import 'package:flutter/material.dart';

/// Extremely subtle atmospheric background inspired by Japanese aesthetics.
///
/// Draws barely-visible enso-like arcs using the gold accent colour at very
/// low opacity. The effect is perceptible only when the eye is looking for it,
/// and never distracts from content.
///
/// Usage: place behind screen content using a [Stack], or as the background
/// of a [Scaffold] via [Scaffold.body]:
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
    final alphaPrimary = isDark ? 10 : 13;
    final alphaSecondary = isDark ? 7 : 9;

    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..color = _gold.withAlpha(alphaPrimary);

    // Large enso-inspired arc anchored to the upper-right.
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

    // Smaller answering arc at the lower-left.
    canvas.drawArc(
      Rect.fromCircle(
        center: Offset(size.width * -0.12, size.height * 1.08),
        radius: size.width * 0.52,
      ),
      -0.55,
      1.9,
      false,
      stroke..color = _gold.withAlpha(alphaSecondary),
    );
  }

  @override
  bool shouldRepaint(_AtmosphericPainter old) => old.isDark != isDark;
}
