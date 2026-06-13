import 'dart:ui' show lerpDouble;

import 'package:flutter/widgets.dart';

/// The signature Auris **slant** path for [rect]: a right-leaning parallelogram
/// whose top edge starts [slant] in from the left and whose bottom edge ends
/// [slant] short of the right, so both vertical edges lean the same way.
///
/// This is the single place the slant geometry lives. It is the motif for the
/// HUD "data" controls — progress-bar segments and the switch track/thumb —
/// kept deliberately distinct from the corner chamfer ([aurisChamferPath]) used
/// on panels and buttons.
Path aurisSlantPath(Rect rect, double slant) {
  final double s = slant.clamp(0.0, rect.width / 2);
  return Path()
    ..moveTo(rect.left + s, rect.top)
    ..lineTo(rect.right, rect.top)
    ..lineTo(rect.right - s, rect.bottom)
    ..lineTo(rect.left, rect.bottom)
    ..close();
}

/// Clips a child to the [aurisSlantPath] parallelogram. Used by progress
/// segments and the switch so the clipped fill matches the slanted outline.
class SlantClipper extends CustomClipper<Path> {
  /// Creates a slant clipper with the given [slant] leg length.
  const SlantClipper(this.slant);

  /// The horizontal lean, in logical pixels.
  final double slant;

  @override
  Path getClip(Size size) => aurisSlantPath(Offset.zero & size, slant);

  @override
  bool shouldReclip(SlantClipper oldClipper) => oldClipper.slant != slant;
}

/// An [OutlinedBorder] tracing the [aurisSlantPath] parallelogram, so a slanted
/// surface can carry a border and a depth glow that follow the lean. The
/// counterpart of `AurisChamferBorder` for data controls.
class AurisSlantBorder extends OutlinedBorder {
  /// Creates a slant border with the given [slant] leg length.
  const AurisSlantBorder({
    this.slant = 0,
    super.side = BorderSide.none,
  });

  /// The horizontal lean, in logical pixels.
  final double slant;

  Path _buildPath(Rect rect, {double inset = 0}) {
    final Rect r = inset == 0 ? rect : rect.deflate(inset);
    return aurisSlantPath(r, slant);
  }

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(side.strokeInset);

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) =>
      _buildPath(rect);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) =>
      _buildPath(rect, inset: side.width);

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    if (side.style == BorderStyle.none || side.width == 0) {
      return;
    }
    canvas.drawPath(getOuterPath(rect), side.toPaint());
  }

  @override
  AurisSlantBorder copyWith({BorderSide? side, double? slant}) {
    return AurisSlantBorder(
      slant: slant ?? this.slant,
      side: side ?? this.side,
    );
  }

  @override
  AurisSlantBorder scale(double t) {
    return AurisSlantBorder(slant: slant * t, side: side.scale(t));
  }

  @override
  ShapeBorder? lerpFrom(ShapeBorder? a, double t) {
    if (a is AurisSlantBorder) {
      return AurisSlantBorder(
        slant: lerpDouble(a.slant, slant, t)!,
        side: BorderSide.lerp(a.side, side, t),
      );
    }
    return super.lerpFrom(a, t);
  }

  @override
  ShapeBorder? lerpTo(ShapeBorder? b, double t) {
    if (b is AurisSlantBorder) {
      return AurisSlantBorder(
        slant: lerpDouble(slant, b.slant, t)!,
        side: BorderSide.lerp(side, b.side, t),
      );
    }
    return super.lerpTo(b, t);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is AurisSlantBorder &&
        other.slant == slant &&
        other.side == side;
  }

  @override
  int get hashCode => Object.hash(slant, side);

  @override
  String toString() => 'AurisSlantBorder(slant: $slant, side: $side)';
}
