import 'package:flutter/material.dart';

import '../painters/hex_painter.dart';
import '../scheme.dart';

/// A non-interactive cluster of hexagons for ambient page-background detail
/// (§spec:custom-widgets).
///
/// Wraps a [CustomPaint] (driven by [HexPainter]) in an [IgnorePointer] so it
/// never intercepts gestures — it is decoration only. The outline color is a
/// faded scheme role (defaulting to the resting border) read from the
/// [AurisScheme]; size it with a parent constraint (e.g. inside a `Positioned`
/// or `SizedBox`).
class AurisHexOrnament extends StatelessWidget {
  /// Creates a decorative hex-cluster ornament.
  const AurisHexOrnament({
    super.key,
    this.color,
    this.opacity = 0.5,
    this.hexRadius = 18,
    this.strokeWidth = 1,
  });

  /// The base outline color. Defaults to the scheme's resting border.
  final Color? color;

  /// Opacity applied to the outline color (kept faint as ambient detail).
  final double opacity;

  /// The circumradius of each hexagon.
  final double hexRadius;

  /// The outline stroke width.
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    final AurisScheme scheme = Theme.of(context).extension<AurisScheme>()!;
    final Color base = color ?? scheme.borderBright;
    return IgnorePointer(
      child: CustomPaint(
        painter: HexPainter(
          color: base.withValues(alpha: opacity),
          hexRadius: hexRadius,
          strokeWidth: strokeWidth,
        ),
      ),
    );
  }
}
