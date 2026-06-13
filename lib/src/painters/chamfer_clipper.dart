import 'package:flutter/widgets.dart';

import 'chamfer_border.dart';

/// A [CustomClipper] that clips a child to the signature Auris notched
/// silhouette — the **asymmetric** 45° chamfer cutting **only the top-left and
/// bottom-right** corners (§spec:design-tokens "Shape").
///
/// This is the widget-layer counterpart of [AurisChamferBorder]: both build
/// their path from the shared [aurisChamferPath], so a clipped child and the
/// drawn border trace the identical polygon — the chamfered fill never bleeds
/// past the chamfered outline. `AurisContainer` uses it to clip its child to
/// the same corners its border paints.
///
/// The [cut] is the length of each 45° leg in logical pixels, clamped per-size
/// to half the shorter side so a large cut on a small box degrades gracefully
/// (matching the border's clamp rule).
class ChamferClipper extends CustomClipper<Path> {
  /// Creates a chamfer clipper cutting the top-left and bottom-right corners by
  /// [cut].
  const ChamferClipper({this.cut = 0});

  /// The length of each 45° cut leg, in logical pixels.
  final double cut;

  @override
  Path getClip(Size size) => aurisChamferPath(Offset.zero & size, cut);

  @override
  bool shouldReclip(covariant ChamferClipper oldClipper) =>
      oldClipper.cut != cut;
}
