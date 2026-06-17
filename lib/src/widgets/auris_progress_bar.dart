import 'package:flutter/material.dart';

import '../painters/slant_clipper.dart';
import '../scheme.dart';
import '../tokens.dart';

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

/// A segmented meter: `segments` parallelogram-slanted cells, of which the
/// leading `value`-fraction are filled in the variant color. Trailing filled
/// cells sit slightly dimmed and the leading cell is full-strength with the
/// variant's depth glow, so the "wavefront" reads as luminous
/// (§spec:custom-widgets — the preferred linear-progress replacement Material's
/// `LinearProgressIndicator` cannot segment).
///
/// The slanted cell geometry ([SlantClipper]) is the HUD "data bar" motif,
/// distinct from the corner chamfer used on panels. An optional [label] (shown
/// left) and [valueLabel] (shown right, e.g. `'68 / 100'`) form a header row
/// above the bar. All colors and the leading-cell glow resolve from the
/// [AurisScheme]; nothing is read from raw tokens.
///
/// The default constructor renders the value immediately.
/// [AurisProgressBar.animated] tweens segment fills when [value] changes over
/// the scheme's normal duration, honoring reduced motion by snapping to the end
/// state (§spec:motion-performance).
class AurisProgressBar extends StatefulWidget {
  /// Creates a segmented progress meter that renders [value] immediately.
  const AurisProgressBar({
    super.key,
    required this.value,
    this.label,
    this.valueLabel,
    this.segments = 20,
    this.variant = AurisProgressVariant.primary,
    this.height = 10,
    this.spacing = 2,
  }) : animated = false,
       assert(value >= 0 && value <= 1, 'value must be in 0..1'),
       assert(segments > 0, 'segments must be positive');

  /// Creates a segmented progress meter that animates fills on [value] change.
  const AurisProgressBar.animated({
    super.key,
    required this.value,
    this.label,
    this.valueLabel,
    this.segments = 20,
    this.variant = AurisProgressVariant.primary,
    this.height = 10,
    this.spacing = 2,
  }) : animated = true,
       assert(value >= 0 && value <= 1, 'value must be in 0..1'),
       assert(segments > 0, 'segments must be positive');

  /// The fill fraction in `0..1`.
  final double value;

  /// Optional label shown at the leading end of the header row.
  final String? label;

  /// Optional value readout shown at the trailing end of the header row
  /// (e.g. `'68 / 100'`).
  final String? valueLabel;

  /// The number of slanted cells.
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
      _value = Tween<double>(
        begin: oldWidget.value,
        end: widget.value,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
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

    final Widget bar = AnimatedBuilder(
      animation: _value,
      builder: (BuildContext context, _) {
        // The count of fully filled segments and which one leads (glows).
        final int filledCount = (_value.value * widget.segments).round().clamp(
          0,
          widget.segments,
        );
        final int leadingIndex = filledCount - 1;
        return SizedBox(
          height: widget.height,
          child: Row(
            // Stretch so each segment fills the bar height. Without this the
            // childless segment boxes get a loose height constraint and
            // collapse to zero, leaving only the leading glow as a faint blur.
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              for (int i = 0; i < widget.segments; i++) ...<Widget>[
                if (i > 0) SizedBox(width: widget.spacing),
                Expanded(
                  child: _Segment(
                    filled: i < filledCount,
                    leading: i == leadingIndex,
                    fillColor: v.filled,
                    dimColor: scheme.borderBright,
                    glow: i == leadingIndex
                        ? v.depth.glow
                        : const <BoxShadow>[],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );

    if (widget.label == null && widget.valueLabel == null) {
      return bar;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            children: <Widget>[
              if (widget.label != null)
                Expanded(
                  child: Text(
                    widget.label!.toUpperCase(),
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: AurisTokens.fontMono,
                      fontFamilyFallback: AurisTokens.fontMonoFallback,
                      fontSize: 11,
                      letterSpacing: AurisTokens.trackingLabel,
                      color: scheme.primaryDim,
                    ),
                  ),
                ),
              if (widget.valueLabel != null)
                Text(
                  widget.valueLabel!,
                  style: TextStyle(
                    fontFamily: AurisTokens.fontMono,
                    fontFamilyFallback: AurisTokens.fontMonoFallback,
                    fontSize: 11,
                    letterSpacing: AurisTokens.trackingLabel,
                    color: scheme.textDim,
                  ),
                ),
            ],
          ),
        ),
        bar,
      ],
    );
  }
}

/// A single slanted cell of the meter.
class _Segment extends StatelessWidget {
  const _Segment({
    required this.filled,
    required this.leading,
    required this.fillColor,
    required this.dimColor,
    required this.glow,
  });

  final bool filled;
  final bool leading;
  final Color fillColor;
  final Color dimColor;
  final List<BoxShadow> glow;

  static const double _slant = 3;

  @override
  Widget build(BuildContext context) {
    // Trailing filled cells are dimmed so the leading cell reads as the bright
    // wavefront; unfilled cells use the dim border color.
    final Color color = !filled
        ? dimColor
        : (leading ? fillColor : fillColor.withValues(alpha: 0.72));

    // Fill the slant via ShapeDecoration (anti-aliased) rather than clipping a
    // ColoredBox, which leaves jagged diagonal edges.
    Widget cell = DecoratedBox(
      decoration: ShapeDecoration(
        color: color,
        shape: const AurisSlantBorder(slant: _slant),
      ),
    );
    // The glow rides on an (unclipped) box so it can spill past the cell.
    if (glow.isNotEmpty) {
      cell = DecoratedBox(
        decoration: BoxDecoration(boxShadow: glow),
        child: cell,
      );
    }
    return cell;
  }
}
