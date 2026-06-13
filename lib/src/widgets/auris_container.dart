import 'package:flutter/material.dart';

import '../painters/chamfer_border.dart';
import '../painters/chamfer_clipper.dart';
import '../scheme.dart';

/// The foundation primitive of the Auris custom-widget library: a chamfered
/// box that paints a [fill], an [AurisChamferBorder] outline, and an optional
/// depth glow, then clips its [child] to the same notched silhouette via a
/// [ChamferClipper] (§spec:custom-widgets).
///
/// Every other display widget (badge, panel, notification, stat card …)
/// composes from this primitive rather than re-deriving the chamfer, so the
/// corner geometry, glow, and clipping behave identically everywhere.
///
/// Design values come from the resolved [AurisScheme] read off the ambient
/// theme, never from raw tokens: [cut] defaults to the medium bevel role,
/// [fill] to the panel surface, and [borderColor] to the resting border. The
/// optional [depth] is an [AurisDepth] (depth-by-intent) whose glow is cast
/// behind the box — Material elevation is never used (§spec:scheme).
class AurisContainer extends StatelessWidget {
  /// Creates a chamfered container.
  ///
  /// Any of [cut], [fill], or [borderColor] left null resolves from the
  /// ambient [AurisScheme] at build time.
  const AurisContainer({
    super.key,
    this.child,
    this.cut,
    this.fill,
    this.borderColor,
    this.borderWidth = 1.0,
    this.depth,
    this.padding,
    this.width,
    this.height,
    this.alignment,
    this.clipChild = true,
  });

  /// The clipped, padded content.
  final Widget? child;

  /// The 45° chamfer leg length. Defaults to the scheme's medium bevel role.
  final double? cut;

  /// The fill color. Defaults to the scheme's panel surface.
  final Color? fill;

  /// The outline color. Defaults to the scheme's resting border. A transparent
  /// color (or [borderWidth] of 0) draws no outline.
  final Color? borderColor;

  /// The outline stroke width.
  final double borderWidth;

  /// Optional depth-by-intent glow cast behind the box (e.g.
  /// `scheme.depthActive`). When null, no glow is drawn.
  final AurisDepth? depth;

  /// Inner padding applied to [child].
  final EdgeInsetsGeometry? padding;

  /// Fixed width, if any.
  final double? width;

  /// Fixed height, if any.
  final double? height;

  /// Optional alignment of [child] within the box.
  final AlignmentGeometry? alignment;

  /// Whether to clip [child] to the chamfered silhouette. Defaults to true so
  /// content never bleeds past the cut corners.
  final bool clipChild;

  @override
  Widget build(BuildContext context) {
    final AurisScheme scheme = Theme.of(context).extension<AurisScheme>()!;
    final double effectiveCut = cut ?? scheme.bevel.md;
    final Color effectiveFill = fill ?? scheme.surfacePanel;
    final Color effectiveBorder = borderColor ?? scheme.borderResting;
    final AurisChamferBorder shape = AurisChamferBorder(
      cut: effectiveCut,
      side: borderWidth <= 0
          ? BorderSide.none
          : BorderSide(color: effectiveBorder, width: borderWidth),
    );

    Widget content = child ?? const SizedBox.shrink();
    if (padding != null) {
      content = Padding(padding: padding!, child: content);
    }
    if (alignment != null) {
      content = Align(alignment: alignment!, child: content);
    }
    if (clipChild) {
      content = ClipPath(
        clipper: ChamferClipper(cut: effectiveCut),
        child: content,
      );
    }

    // Fill + glow ride behind the (clipped) child; the glow's shape matches the
    // chamfer so the cast shadow follows the notched silhouette. The border is
    // drawn in the FOREGROUND so an opaque child (e.g. a panel's inset header
    // strip) can never cover part of it — covering made the outline read as
    // uneven where the header and body shades met it differently.
    Widget box = DecoratedBox(
      decoration: ShapeDecoration(
        color: effectiveFill,
        shape: AurisChamferBorder(cut: effectiveCut),
        shadows: depth?.glow.isEmpty ?? true ? null : depth!.glow,
      ),
      child: DecoratedBox(
        position: DecorationPosition.foreground,
        decoration: ShapeDecoration(shape: shape),
        child: content,
      ),
    );

    if (width != null || height != null) {
      box = SizedBox(width: width, height: height, child: box);
    }
    return box;
  }
}
