import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// Paints a tessellating cluster of flat-top hexagon outlines used as ambient
/// page-background detail by `AurisHexOrnament` (§spec:custom-widgets).
///
/// Purely decorative: the painter draws stroked hex outlines in [color] at the
/// given [hexRadius] and [strokeWidth], filling the canvas in a honeycomb grid.
/// The hexagon math lives here so the ornament widget stays a thin
/// [CustomPaint] wrapper.
class HexPainter extends CustomPainter {
  /// Creates a hex-cluster painter.
  const HexPainter({
    required this.color,
    this.hexRadius = 18,
    this.strokeWidth = 1,
  });

  /// The outline color (the ornament supplies an already-faded scheme color).
  final Color color;

  /// The circumradius of each hexagon, in logical pixels.
  final double hexRadius;

  /// The outline stroke width.
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = color;

    // Flat-top hexagon geometry: width = 2r, height = sqrt(3) * r. Columns
    // advance by 1.5r; alternate columns are offset vertically by half a row.
    final double r = hexRadius;
    final double horizontalStep = r * 1.5;
    final double verticalStep = r * math.sqrt(3);

    int column = 0;
    for (double cx = 0; cx - r <= size.width; cx += horizontalStep) {
      final double yOffset = column.isOdd ? verticalStep / 2 : 0;
      for (double cy = yOffset; cy - r <= size.height; cy += verticalStep) {
        canvas.drawPath(_hexPath(Offset(cx, cy), r), paint);
      }
      column++;
    }
  }

  /// A flat-top hexagon path centred at [center] with circumradius [r].
  Path _hexPath(Offset center, double r) {
    final Path path = Path();
    for (int i = 0; i < 6; i++) {
      final double angle = math.pi / 3 * i;
      final Offset vertex = Offset(
        center.dx + r * math.cos(angle),
        center.dy + r * math.sin(angle),
      );
      if (i == 0) {
        path.moveTo(vertex.dx, vertex.dy);
      } else {
        path.lineTo(vertex.dx, vertex.dy);
      }
    }
    return path..close();
  }

  @override
  bool shouldRepaint(covariant HexPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.hexRadius != hexRadius ||
      oldDelegate.strokeWidth != strokeWidth;
}
