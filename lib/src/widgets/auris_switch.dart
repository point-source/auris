import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../painters/slant_clipper.dart';
import '../scheme.dart';
import '../tokens.dart';

/// A toggle with a **true slanted (parallelogram) track and thumb** — the
/// data-control HUD motif (§spec:design-tokens) Material's `Switch` cannot
/// express, since its track is a fixed stadium shape
/// (§spec:custom-widgets, §spec:theme-layer "known limits").
///
/// The track and thumb are both clipped/outlined with the signature
/// right-leaning slant via [AurisSlantBorder] / [SlantClipper].
/// The thumb slides between the two ends and the track color crosses from the
/// resting border to the active primary over the scheme's normal duration; both
/// the position and the color animate together. An optional [label] sits beside
/// the control and optional on/off [statusLabels] read out the state in
/// monospace.
///
/// Animation respects reduced motion: when
/// `MediaQuery.disableAnimations` is set the control renders its end state and
/// the controller does not run (§spec:motion-performance). A disabled switch
/// (null [onChanged]) renders at opacity 0.5 with no hover/focus and a
/// forbidden cursor; an enabled switch shows a gold keyboard-focus outline
/// (§spec:accessibility).
class AurisSwitch extends StatefulWidget {
  /// Creates a slanted switch.
  const AurisSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.statusLabels,
    this.focusNode,
    this.autofocus = false,
  });

  /// Whether the switch is on.
  final bool value;

  /// Called with the requested new value when the user toggles the control.
  /// Null disables the switch.
  final ValueChanged<bool>? onChanged;

  /// Optional descriptive label shown before the control.
  final String? label;

  /// Optional `(off, on)` status words shown after the control in monospace
  /// (e.g. `('OFFLINE', 'ONLINE')`); the active word is highlighted.
  final (String off, String on)? statusLabels;

  /// An optional external focus node.
  final FocusNode? focusNode;

  /// Whether the control should autofocus.
  final bool autofocus;

  @override
  State<AurisSwitch> createState() => _AurisSwitchState();
}

class _AurisSwitchState extends State<AurisSwitch>
    with SingleTickerProviderStateMixin {
  static const double _trackWidth = 48;
  static const double _trackHeight = 24;
  static const double _thumbInset = 4;
  // Space reserved around the track for the focus ring, so focusing never
  // shifts the row layout.
  static const double _focusPad = 6;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AurisTokens.durationNormal,
    value: widget.value ? 1.0 : 0.0,
  );
  late final Animation<double> _position = CurvedAnimation(
    parent: _controller,
    curve: AurisTokens.curveDefault,
  );

  bool _focused = false;

  bool get _enabled => widget.onChanged != null;

  bool get _reduceMotion =>
      MediaQuery.maybeDisableAnimationsOf(context) ?? false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncPosition();
  }

  @override
  void didUpdateWidget(covariant AurisSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _syncPosition();
    }
  }

  void _syncPosition() {
    final double target = widget.value ? 1.0 : 0.0;
    if (_reduceMotion) {
      _controller.value = target;
    } else {
      _controller.animateTo(target);
    }
  }

  void _toggle() {
    if (!_enabled) return;
    widget.onChanged!(!widget.value);
  }

  @override
  Widget build(BuildContext context) {
    final AurisScheme scheme = Theme.of(context).extension<AurisScheme>()!;

    final Widget track = AnimatedBuilder(
      animation: _position,
      builder: (BuildContext context, _) => _buildTrack(scheme),
    );

    final List<Widget> rowChildren = <Widget>[];
    if (widget.label != null) {
      rowChildren.add(
        Flexible(
          child: Text(
            widget.label!,
            style: TextStyle(
              fontFamily: AurisTokens.fontBody,
              fontFamilyFallback: AurisTokens.fontBodyFallback,
              fontSize: 14,
              letterSpacing: AurisTokens.trackingBody,
              color: scheme.textBright,
            ),
          ),
        ),
      );
      rowChildren.add(const SizedBox(width: 12));
    }
    rowChildren.add(track);
    if (widget.statusLabels != null) {
      rowChildren.add(const SizedBox(width: 12));
      rowChildren.add(_buildStatus(scheme));
    }

    // The whole row (label + track + status) is the tap/focus target so the
    // label is interactive too.
    Widget result = Focus(
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
      canRequestFocus: _enabled,
      onFocusChange: (bool f) => setState(() => _focused = f),
      onKeyEvent: (FocusNode node, KeyEvent event) {
        if (event is KeyDownEvent &&
            (event.logicalKey == LogicalKeyboardKey.space ||
                event.logicalKey == LogicalKeyboardKey.enter)) {
          _toggle();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: MouseRegion(
        cursor:
            _enabled ? SystemMouseCursors.click : SystemMouseCursors.forbidden,
        child: GestureDetector(
          onTap: _toggle,
          behavior: HitTestBehavior.opaque,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: rowChildren,
          ),
        ),
      ),
    );

    if (!_enabled) {
      result = Opacity(opacity: 0.5, child: result);
    }
    return result;
  }

  Widget _buildStatus(AurisScheme scheme) {
    final (String off, String on) labels = widget.statusLabels!;
    final String text = widget.value ? labels.$2 : labels.$1;
    final Color color = !_enabled
        ? scheme.textDim
        : (widget.value ? scheme.primaryActive : scheme.textMid);
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontFamily: AurisTokens.fontMono,
        fontFamilyFallback: AurisTokens.fontMonoFallback,
        fontSize: 12,
        letterSpacing: AurisTokens.trackingLabel,
        color: color,
      ),
    );
  }

  Widget _buildTrack(AurisScheme scheme) {
    final double t = _position.value;
    // Track fill and border cross from resting to active as the thumb moves.
    final Color trackFill = Color.lerp(
      scheme.surfaceInset,
      scheme.primaryActive.withValues(alpha: 0.22),
      t,
    )!;
    final Color trackBorder = Color.lerp(
      scheme.borderResting,
      scheme.primaryActive,
      t,
    )!;
    final Color thumbColor = Color.lerp(
      scheme.primaryDim,
      scheme.primaryActive,
      t,
    )!;

    // The slanted (parallelogram) HUD motif. The slant scales with each
    // element's height by a constant ratio so the track border and the thumb
    // edges stay parallel (the same lean angle).
    const double thumbSize = _trackHeight - _thumbInset * 2;
    const double travel = _trackWidth - _thumbInset * 2 - thumbSize;
    final double thumbX = _thumbInset + travel * t;
    const double slantRatio = 4 / _trackHeight;
    const double trackSlant = _trackHeight * slantRatio;
    const double thumbSlant = thumbSize * slantRatio;
    const double focusSlant = (_trackHeight + 6) * slantRatio;

    return SizedBox(
      // Fixed size (track + reserved ring space) so focus never shifts layout.
      width: _trackWidth + _focusPad,
      height: _trackHeight + _focusPad,
      child: Center(
        child: DecoratedBox(
          // The keyboard-focus ring: a gold slanted outline around the track.
          decoration: ShapeDecoration(
            shape: AurisSlantBorder(
              slant: focusSlant,
              side: _focused && _enabled
                  ? BorderSide(color: scheme.primaryActive, width: 1.5)
                  : BorderSide.none,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(3),
            child: SizedBox(
              width: _trackWidth,
              height: _trackHeight,
              // No ClipPath: the track and thumb are both ShapeDecoration fills
              // (anti-aliased) and the thumb stays within the track bounds, so
              // there is nothing to clip — and a clip would re-introduce the
              // jagged diagonal edge.
              child: DecoratedBox(
                decoration: ShapeDecoration(
                  color: trackFill,
                  shape: AurisSlantBorder(
                    slant: trackSlant,
                    side: BorderSide(color: trackBorder),
                  ),
                ),
                child: Stack(
                  children: <Widget>[
                    Positioned(
                      left: thumbX,
                      top: _thumbInset,
                      // The ShapeDecoration fills the slant anti-aliased;
                      // no ClipPath needed (and a clip would re-introduce
                      // the jagged diagonal).
                      child: Container(
                        width: thumbSize,
                        height: thumbSize,
                        decoration: ShapeDecoration(
                          color: thumbColor,
                          shape: const AurisSlantBorder(slant: thumbSlant),
                          shadows: widget.value && t > 0.5
                              ? scheme.depthSubtle.glow
                              : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
