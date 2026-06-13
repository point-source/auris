import 'package:flutter/material.dart';

import '../painters/chamfer_border.dart';
import '../painters/chamfer_clipper.dart';
import '../scheme.dart';

/// The semantic intent of an [AurisProgressBar], mapped to a scheme role color
/// and its depth-by-intent glow.
enum AurisProgressVariant {
  /// Active gold — the default.
  primary,

  /// Cool slate secondary.
  secondary,

  /// Danger / over-threshold.
  danger,

  /// Success / complete.
  success,
}

/// A segmented meter: `segments` chamfered cells, of which the leading
/// `value`-fraction are filled in the variant color, the rest dim. The leading
/// filled segment carries the variant's depth glow so the "wavefront" reads as
/// luminous (§spec:custom-widgets — the preferred linear-progress replacement
/// Material's `LinearProgressIndicator` cannot segment).
///
/// Each cell is a true chamfered box ([ChamferClipper] + [AurisChamferBorder]),
/// not a rounded Material bar. All colors and the leading-segment glow resolve
/// from the [AurisScheme]; nothing is read from raw tokens.
///
/// The default constructor renders the value immediately. [AurisProgressBar.animated]
/// tweens segment fills when [value] changes over the scheme's normal duration,
/// honoring reduced motion by snapping to the end state
/// (§spec:motion-performance).
class AurisProgressBar extends StatefulWidget {
  /// Creates a segmented progress meter that renders [value] immediately.
  const AurisProgressBar({
    super.key,
    required this.value,
    this.segments = 12,
    this.variant = AurisProgressVariant.primary,
    this.height = 18,
    this.spacing = 3,
  })  : animated = false,
        assert(value >= 0 && value <= 1, 'value must be in 0..1'),
        assert(segments > 0, 'segments must be positive');

  /// Creates a segmented progress meter that animates fills on [value] change.
  const AurisProgressBar.animated({
    super.key,
    required this.value,
    this.segments = 12,
    this.variant = AurisProgressVariant.primary,
    this.height = 18,
    this.spacing = 3,
  })  : animated = true,
        assert(value >= 0 && value <= 1, 'value must be in 0..1'),
        assert(segments > 0, 'segments must be positive');

  /// The fill fraction in `0..1`.
  final double value;

  /// The number of chamfered cells.
  final int segments;

  /// The semantic color of the filled cells.
  final AurisProgressVariant variant;

  /// The bar height.
  final double height;

  /// The gap between cells.
  final double spacing;

  /// Whether [value] changes tween (`.animated`) or apply immediately.
  final bool animated;

  @override
  State<AurisProgressBar> createState() => _AurisProgressBarState();
}

class _AurisProgressBarState extends State<AurisProgressBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _value = AlwaysStoppedAnimation<double>(widget.value);

  @override
  void initState() {
    super.initState();
    // Created eagerly (not lazily) so the controller always exists by dispose;
    // a lazy `late` field would first build the ticker during dispose, which
    // does an unsafe TickerMode lookup on a deactivated element.
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant AurisProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      final bool reduceMotion =
          MediaQuery.maybeDisableAnimationsOf(context) ?? false;
      if (!widget.animated || reduceMotion) {
        _value = AlwaysStoppedAnimation<double>(widget.value);
        _controller.value = 1.0;
        return;
      }
      _value = Tween<double>(begin: oldWidget.value, end: widget.value).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      );
      _controller.forward(from: 0);
    }
  }

  ({Color filled, AurisDepth depth}) _resolve(AurisScheme scheme) {
    switch (widget.variant) {
      case AurisProgressVariant.primary:
        return (filled: scheme.primaryActive, depth: scheme.depthActive);
      case AurisProgressVariant.secondary:
        return (filled: scheme.secondary, depth: scheme.depthSecondary);
      case AurisProgressVariant.danger:
        return (filled: scheme.dangerBright, depth: scheme.depthDanger);
      case AurisProgressVariant.success:
        return (filled: scheme.successBright, depth: scheme.depthSubtle);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AurisScheme scheme = Theme.of(context).extension<AurisScheme>()!;
    final ({Color filled, AurisDepth depth}) v = _resolve(scheme);

    return AnimatedBuilder(
      animation: _value,
      builder: (BuildContext context, _) {
        // The count of fully filled segments and which one leads (glows).
        final int filledCount =
            (_value.value * widget.segments).round().clamp(0, widget.segments);
        final int leadingIndex = filledCount - 1;
        return SizedBox(
          height: widget.height,
          child: Row(
            children: <Widget>[
              for (int i = 0; i < widget.segments; i++) ...<Widget>[
                if (i > 0) SizedBox(width: widget.spacing),
                Expanded(
                  child: _Segment(
                    filled: i < filledCount,
                    leading: i == leadingIndex,
                    fillColor: v.filled,
                    dimColor: scheme.surfaceInset,
                    borderColor: i < filledCount
                        ? v.filled.withValues(alpha: 0.6)
                        : scheme.borderResting,
                    glow: i == leadingIndex ? v.depth.glow : const <BoxShadow>[],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

/// A single chamfered cell of the meter.
class _Segment extends StatelessWidget {
  const _Segment({
    required this.filled,
    required this.leading,
    required this.fillColor,
    required this.dimColor,
    required this.borderColor,
    required this.glow,
  });

  final bool filled;
  final bool leading;
  final Color fillColor;
  final Color dimColor;
  final Color borderColor;
  final List<BoxShadow> glow;

  static const double _cut = 3;

  @override
  Widget build(BuildContext context) {
    // The glow rides on an outer (unclipped) shape so it can spill past the
    // cell; the fill + border are clipped to the chamfer inside it.
    return DecoratedBox(
      decoration: ShapeDecoration(
        shape: const AurisChamferBorder(cut: _cut),
        shadows: glow.isEmpty ? null : glow,
      ),
      child: ClipPath(
        clipper: const ChamferClipper(cut: _cut),
        child: DecoratedBox(
          decoration: ShapeDecoration(
            color: filled ? fillColor : dimColor.withValues(alpha: 0.6),
            shape: AurisChamferBorder(
              cut: _cut,
              side: BorderSide(color: borderColor),
            ),
          ),
        ),
      ),
    );
  }
}
