import 'package:flutter/material.dart';

/// A subtle abstract koi silhouette rendered via [CustomPainter].
///
/// The koi is always decorative — a quiet signature rather than a mascot.
/// It should feel discovered, not displayed.
///
/// Recommended opacities:
/// - Background use: 0.05 – 0.10
/// - Empty-state accent: 0.12 – 0.18
/// - Splash use: 0.14 – 0.20
class KoiMotif extends StatelessWidget {
  const KoiMotif({
    this.size = 80.0,
    this.opacity = 0.12,
    super.key,
  });

  /// The width of the bounding box. Height is automatically half the width.
  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary.withAlpha(
      (opacity * 255).clamp(0, 255).round(),
    );
    return RepaintBoundary(
      child: CustomPaint(
        // Koi aspect ratio: ~2:1 (width:height)
        size: Size(size, size * 0.5),
        painter: _KoiPainter(color: color),
      ),
    );
  }
}

class _KoiPainter extends CustomPainter {
  const _KoiPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9
      ..strokeCap = StrokeCap.round
      ..color = color;

    final cx = size.width * 0.52;
    final cy = size.height * 0.50;
    final bx = size.width * 0.40; // half-body length
    final by = size.height * 0.36; // half-body girth

    // Body: pointed snout → arched back → narrowing tail base.
    final body = Path()
      ..moveTo(cx + bx, cy) // snout
      ..cubicTo(
        cx + bx * 0.55, cy - by,
        cx - bx * 0.25, cy - by * 0.92,
        cx - bx, cy, // tail junction
      )
      ..cubicTo(
        cx - bx * 0.25, cy + by * 0.92,
        cx + bx * 0.55, cy + by,
        cx + bx, cy, // back to snout
      );
    canvas.drawPath(body, paint);

    // Tail: two fan lobes — upper and lower.
    final tail = Path()
      ..moveTo(cx - bx, cy)
      ..cubicTo(
        cx - bx * 1.32, cy - by * 0.28,
        cx - bx * 1.62, cy - by * 0.58,
        cx - bx * 1.85, cy - by * 0.38,
      )
      ..moveTo(cx - bx, cy)
      ..cubicTo(
        cx - bx * 1.32, cy + by * 0.28,
        cx - bx * 1.62, cy + by * 0.58,
        cx - bx * 1.85, cy + by * 0.38,
      );
    canvas.drawPath(tail, paint);

    // Dorsal fin: a single graceful arc above the back.
    final fin = Path()
      ..moveTo(cx + bx * 0.18, cy - by * 0.88)
      ..cubicTo(
        cx + bx * 0.02, cy - by * 1.32,
        cx - bx * 0.38, cy - by * 1.25,
        cx - bx * 0.52, cy - by * 0.88,
      );
    canvas.drawPath(fin, paint);
  }

  @override
  bool shouldRepaint(_KoiPainter old) => old.color != color;
}
