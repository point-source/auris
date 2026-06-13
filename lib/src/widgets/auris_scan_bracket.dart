import 'package:flutter/material.dart';

import '../scheme.dart';
import '../tokens.dart';

/// Targeting-reticle corner brackets drawn around a [child], with an optional
/// opacity [pulse] on `durationSlow` (§spec:custom-widgets).
///
/// The four L-shaped corner ticks are the HUD "lock-on" reticle that frames
/// content without a full border. The bracket color defaults to the scheme's
/// active primary. When [pulse] is enabled the brackets fade in and out; the
/// pulse respects `MediaQuery.disableAnimations` and renders the steady (full
/// opacity) end state when reduced motion is requested
/// (§spec:motion-performance).
class AurisScanBracket extends StatefulWidget {
  /// Creates a scan-bracket frame around [child].
  const AurisScanBracket({
    super.key,
    required this.child,
    this.color,
    this.bracketLength = 14,
    this.strokeWidth = 2,
    this.padding = const EdgeInsets.all(6),
    this.pulse = false,
  });

  /// The framed content.
  final Widget child;

  /// The bracket color. Defaults to the scheme's active primary.
  final Color? color;

  /// The length of each leg of an L-shaped corner bracket.
  final double bracketLength;

  /// The bracket stroke width.
  final double strokeWidth;

  /// Padding between the brackets and [child].
  final EdgeInsetsGeometry padding;

  /// When true the brackets pulse in opacity (ignored under reduced motion).
  final bool pulse;

  @override
  State<AurisScanBracket> createState() => _AurisScanBracketState();
}

class _AurisScanBracketState extends State<AurisScanBracket>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AurisTokens.durationSlow,
  );
  late final Animation<double> _opacity = Tween<double>(begin: 0.35, end: 1.0)
      .animate(
        CurvedAnimation(parent: _controller, curve: AurisTokens.curveDefault),
      );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _syncAnimation() {
    // Pulse only when requested AND reduced motion is not active; otherwise
    // render the steady full-opacity end state (§spec:motion-performance).
    final bool reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ??
        false;
    final bool shouldPulse = widget.pulse && !reduceMotion;
    if (shouldPulse) {
      if (!_controller.isAnimating) {
        _controller.repeat(reverse: true);
      }
    } else {
      _controller.stop();
      _controller.value = 1.0;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncAnimation();
  }

  @override
  void didUpdateWidget(covariant AurisScanBracket oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pulse != widget.pulse) {
      _syncAnimation();
    }
  }

  @override
  Widget build(BuildContext context) {
    final AurisScheme scheme = Theme.of(context).extension<AurisScheme>()!;
    final Color color = widget.color ?? scheme.primaryActive;

    Widget brackets = CustomPaint(
      foregroundPainter: _ScanBracketPainter(
        color: color,
        bracketLength: widget.bracketLength,
        strokeWidth: widget.strokeWidth,
      ),
      child: Padding(padding: widget.padding, child: widget.child),
    );

    if (widget.pulse) {
      brackets = AnimatedBuilder(
        animation: _opacity,
        builder: (BuildContext context, Widget? child) {
          return Opacity(opacity: _opacity.value, child: child);
        },
        child: brackets,
      );
    }
    return brackets;
  }
}

/// Paints the four L-shaped corner ticks of a scan reticle.
class _ScanBracketPainter extends CustomPainter {
  const _ScanBracketPainter({
    required this.color,
    required this.bracketLength,
    required this.strokeWidth,
  });

  final Color color;
  final double bracketLength;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = color;
    final double l = bracketLength;
    final double w = size.width;
    final double h = size.height;

    // Top-left.
    canvas.drawPath(
      Path()
        ..moveTo(0, l)
        ..lineTo(0, 0)
        ..lineTo(l, 0),
      paint,
    );
    // Top-right.
    canvas.drawPath(
      Path()
        ..moveTo(w - l, 0)
        ..lineTo(w, 0)
        ..lineTo(w, l),
      paint,
    );
    // Bottom-right.
    canvas.drawPath(
      Path()
        ..moveTo(w, h - l)
        ..lineTo(w, h)
        ..lineTo(w - l, h),
      paint,
    );
    // Bottom-left.
    canvas.drawPath(
      Path()
        ..moveTo(l, h)
        ..lineTo(0, h)
        ..lineTo(0, h - l),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _ScanBracketPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.bracketLength != bracketLength ||
      oldDelegate.strokeWidth != strokeWidth;
}
