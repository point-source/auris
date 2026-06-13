import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

/// The effective chamfer cut for [rect]: [cut] clamped to half the shorter side
/// so a large bevel on a small rect degrades gracefully instead of
/// self-crossing.
///
/// This is the single clamp rule shared by every consumer of the Auris corner
/// geometry — [AurisChamferBorder], [AurisChamferInputBorder], and
/// `ChamferClipper` — so the clipped silhouette matches the bordered one
/// exactly.
double aurisEffectiveChamferCut(Rect rect, double cut) =>
    cut.clamp(0.0, rect.shortestSide / 2);

/// The signature Auris notched polygon for [rect]: a six-vertex path cutting
/// **only the top-left and bottom-right** corners by [cut] (clamped per-rect).
///
/// This is the single place the corner *path* lives. [AurisChamferBorder]
/// (theme layer) and `ChamferClipper` (widget layer) both build their geometry
/// from this function, so "which corners are cut" and "how the cut is shaped"
/// is one definition, not several that can drift apart (§spec:design-tokens
/// "Shape").
///
/// Starting on the top edge a [cut] before the top-left corner, it slants
/// down-left to the left edge ([cut] below the corner), runs down to the square
/// bottom-left corner, along the bottom to a [cut] before the bottom-right
/// corner, slants up-right to the right edge, and up to the square top-right
/// corner before closing.
Path aurisChamferPath(Rect rect, double cut) {
  final double c = aurisEffectiveChamferCut(rect, cut);
  if (c <= 0) {
    return Path()..addRect(rect);
  }
  return Path()
    // Top edge, a cut before the top-left corner.
    ..moveTo(rect.left + c, rect.top)
    // Slant down-left to the left edge (top-left corner cut).
    ..lineTo(rect.left, rect.top + c)
    // Down the left edge to the square bottom-left corner.
    ..lineTo(rect.left, rect.bottom)
    // Along the bottom to a cut before the bottom-right corner.
    ..lineTo(rect.right - c, rect.bottom)
    // Slant up-right to the right edge (bottom-right corner cut).
    ..lineTo(rect.right, rect.bottom - c)
    // Up the right edge to the square top-right corner, then back to start.
    ..lineTo(rect.right, rect.top)
    ..close();
}

/// The signature Auris corner geometry: an **asymmetric** 45° chamfer that cuts
/// **only the top-left and bottom-right** corners, leaving the top-right and
/// bottom-left square (§spec:design-tokens "Shape", §spec:theme-layer).
///
/// This is the single place the corner rule lives. Flutter's
/// [BeveledRectangleBorder] cannot express it because it bevels all four
/// corners equally; [AurisChamferBorder] owns the notched-panel silhouette so
/// "which corners are cut" is one edit, not a sweep across every theme.
///
/// The outer path is a six-vertex polygon. Starting on the top edge a [cut]
/// before the top-left corner, it slants down-left to the left edge ([cut]
/// below the corner), runs to the square top-right corner, down to the
/// bottom-right where it slants in by [cut] on both edges, along the bottom to
/// the square bottom-left corner, and back up to the start.
class AurisChamferBorder extends OutlinedBorder {
  /// Creates a chamfered border whose top-left and bottom-right corners are cut
  /// by [cut] (the length of each 45° leg, in logical pixels).
  const AurisChamferBorder({
    this.cut = 0,
    super.side = BorderSide.none,
  });

  /// The length of each 45° cut leg, in logical pixels. Clamped per-rect so it
  /// never exceeds half the shorter side.
  final double cut;

  /// The notched polygon for [rect], inset on all edges by [inset] (used to
  /// derive the inner path from the outer one). Delegates to the shared
  /// [aurisChamferPath] so the silhouette matches `ChamferClipper` exactly.
  Path _buildPath(Rect rect, {double inset = 0}) {
    final Rect r = inset == 0 ? rect : rect.deflate(inset);
    return aurisChamferPath(r, cut);
  }

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
    final Path path = getOuterPath(rect, textDirection: textDirection);
    canvas.drawPath(path, side.toPaint());
  }

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(side.strokeInset);

  @override
  AurisChamferBorder copyWith({BorderSide? side, double? cut}) {
    return AurisChamferBorder(
      cut: cut ?? this.cut,
      side: side ?? this.side,
    );
  }

  @override
  AurisChamferBorder scale(double t) {
    return AurisChamferBorder(
      cut: cut * t,
      side: side.scale(t),
    );
  }

  @override
  ShapeBorder? lerpFrom(ShapeBorder? a, double t) {
    if (a is AurisChamferBorder) {
      return AurisChamferBorder(
        cut: lerpDouble(a.cut, cut, t)!,
        side: BorderSide.lerp(a.side, side, t),
      );
    }
    return super.lerpFrom(a, t);
  }

  @override
  ShapeBorder? lerpTo(ShapeBorder? b, double t) {
    if (b is AurisChamferBorder) {
      return AurisChamferBorder(
        cut: lerpDouble(cut, b.cut, t)!,
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
    return other is AurisChamferBorder &&
        other.cut == cut &&
        other.side == side;
  }

  @override
  int get hashCode => Object.hash(cut, side);

  @override
  String toString() => 'AurisChamferBorder(cut: $cut, side: $side)';
}

/// The text-field counterpart of [AurisChamferBorder].
///
/// [InputDecorationTheme] requires an [InputBorder] rather than a
/// [ShapeBorder], so this paints the identical top-left + bottom-right cut
/// silhouette while satisfying the [InputBorder] contract (and respecting the
/// active [borderSide] supplied by `InputDecorator` for enabled / focus /
/// error states).
class AurisChamferInputBorder extends InputBorder {
  /// Creates a chamfered input border cutting the top-left and bottom-right
  /// corners by [cut].
  const AurisChamferInputBorder({
    this.cut = 0,
    super.borderSide = const BorderSide(),
  });

  /// The length of each 45° cut leg, in logical pixels.
  final double cut;

  Path _buildPath(Rect rect, {double inset = 0}) {
    final Rect r = inset == 0 ? rect : rect.deflate(inset);
    return aurisChamferPath(r, cut);
  }

  @override
  bool get isOutline => true;

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(borderSide.strokeInset);

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) =>
      _buildPath(rect);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) =>
      _buildPath(rect, inset: borderSide.width);

  @override
  void paint(
    Canvas canvas,
    Rect rect, {
    double? gapStart,
    double gapExtent = 0.0,
    double gapPercentage = 0.0,
    TextDirection? textDirection,
  }) {
    if (borderSide.style == BorderStyle.none || borderSide.width == 0) {
      return;
    }
    final Paint paint = borderSide.toPaint();

    // No floating label → stroke the whole chamfered outline.
    if (gapStart == null || gapExtent <= 0.0 || gapPercentage == 0.0) {
      canvas.drawPath(
        getOuterPath(rect, textDirection: textDirection),
        paint,
      );
      return;
    }

    // A floating label sits on the top edge: cut a gap there so the border does
    // not draw through the label text (mirrors OutlineInputBorder). The top
    // edge runs from `topStart` (a cut in from the left, after the top-left
    // chamfer) to the square top-right corner at `rect.right`.
    const double gapPadding = 4.0;
    final double c = aurisEffectiveChamferCut(rect, cut);
    final double topStart = rect.left + c;
    final double topEnd = rect.right;
    final double extent =
        lerpDouble(0.0, gapExtent + gapPadding * 2.0, gapPercentage)!;

    double gapLeft;
    double gapRight;
    if (textDirection == TextDirection.rtl) {
      gapRight = gapStart + gapPadding;
      gapLeft = gapRight - extent;
    } else {
      gapLeft = gapStart - gapPadding;
      gapRight = gapLeft + extent;
    }
    gapLeft = gapLeft.clamp(topStart, topEnd);
    gapRight = gapRight.clamp(topStart, topEnd);

    // Open path: trace the full outline but omit the [gapLeft, gapRight] span
    // of the top edge.
    final Path path = Path()
      ..moveTo(gapLeft, rect.top)
      ..lineTo(topStart, rect.top)
      ..lineTo(rect.left, rect.top + c)
      ..lineTo(rect.left, rect.bottom)
      ..lineTo(rect.right - c, rect.bottom)
      ..lineTo(rect.right, rect.bottom - c)
      ..lineTo(rect.right, rect.top)
      ..lineTo(gapRight, rect.top);
    canvas.drawPath(path, paint);
  }

  @override
  AurisChamferInputBorder copyWith({BorderSide? borderSide, double? cut}) {
    return AurisChamferInputBorder(
      cut: cut ?? this.cut,
      borderSide: borderSide ?? this.borderSide,
    );
  }

  @override
  AurisChamferInputBorder scale(double t) {
    return AurisChamferInputBorder(
      cut: cut * t,
      borderSide: borderSide.scale(t),
    );
  }

  @override
  ShapeBorder? lerpFrom(ShapeBorder? a, double t) {
    if (a is AurisChamferInputBorder) {
      return AurisChamferInputBorder(
        cut: lerpDouble(a.cut, cut, t)!,
        borderSide: BorderSide.lerp(a.borderSide, borderSide, t),
      );
    }
    return super.lerpFrom(a, t);
  }

  @override
  ShapeBorder? lerpTo(ShapeBorder? b, double t) {
    if (b is AurisChamferInputBorder) {
      return AurisChamferInputBorder(
        cut: lerpDouble(cut, b.cut, t)!,
        borderSide: BorderSide.lerp(borderSide, b.borderSide, t),
      );
    }
    return super.lerpTo(b, t);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is AurisChamferInputBorder &&
        other.cut == cut &&
        other.borderSide == borderSide;
  }

  @override
  int get hashCode => Object.hash(cut, borderSide);

  @override
  String toString() =>
      'AurisChamferInputBorder(cut: $cut, borderSide: $borderSide)';
}
