import 'package:flutter/material.dart';

import '../scheme.dart';
import '../tokens.dart';
import 'auris_panel.dart';

/// The semantic type of an [AurisTerminalLine], mapped to a scheme role color.
enum AurisTerminalLineType {
  /// Default readout — mid text.
  normal,

  /// Success / OK — green.
  ok,

  /// Error — danger red.
  error,

  /// Augment / system highlight — gold.
  augment,

  /// Warning — amber.
  warning,
}

/// A single terminal log line: its [text] and semantic [type].
@immutable
class AurisTerminalLine {
  /// Creates a terminal line of [type] (default [AurisTerminalLineType.normal]).
  const AurisTerminalLine(
    this.text, {
    this.type = AurisTerminalLineType.normal,
  });

  /// The line text (rendered monospace, as-is).
  final String text;

  /// The semantic type that colors the line.
  final AurisTerminalLineType type;
}

/// An auto-scrolling monospace log that scrolls to the newest line as lines are
/// appended; each line is colored by its [AurisTerminalLineType], and an
/// optional blinking block cursor trails the last line
/// (§spec:custom-widgets). Wraps [AurisPanel] so it shares the titled,
/// chamfered HUD frame.
///
/// All line colors resolve from the [AurisScheme]. The blink respects reduced
/// motion: when `MediaQuery.disableAnimations` is set the cursor is shown solid
/// (steady) rather than blinking (§spec:motion-performance). The auto-scroll
/// jumps (does not animate) under reduced motion.
class AurisTerminal extends StatefulWidget {
  /// Creates a terminal log.
  const AurisTerminal({
    super.key,
    required this.lines,
    this.title = 'TERMINAL',
    this.code,
    this.showCursor = true,
    this.height = 200,
  });

  /// The log lines, oldest first; the newest is at the end.
  final List<AurisTerminalLine> lines;

  /// The panel header title.
  final String title;

  /// Optional monospace status code in the header.
  final String? code;

  /// Whether to show the trailing block cursor.
  final bool showCursor;

  /// The fixed height of the scrolling log area.
  final double height;

  @override
  State<AurisTerminal> createState() => _AurisTerminalState();
}

class _AurisTerminalState extends State<AurisTerminal>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late final AnimationController _blink = AnimationController(
    vsync: this,
    duration: AurisTokens.durationSlow,
  );

  bool get _reduceMotion =>
      MediaQuery.maybeDisableAnimationsOf(context) ?? false;

  @override
  void dispose() {
    _blink.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncBlink();
    _scheduleAutoScroll();
  }

  @override
  void didUpdateWidget(covariant AurisTerminal oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.showCursor != widget.showCursor) {
      _syncBlink();
    }
    if (oldWidget.lines.length != widget.lines.length) {
      _scheduleAutoScroll();
    }
  }

  void _syncBlink() {
    final bool shouldBlink = widget.showCursor && !_reduceMotion;
    if (shouldBlink) {
      if (!_blink.isAnimating) {
        _blink.repeat(reverse: true);
      }
    } else {
      _blink.stop();
      _blink.value = 1.0;
    }
  }

  void _scheduleAutoScroll() {
    // After the new lines lay out, scroll to the bottom (newest line).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      final double max = _scrollController.position.maxScrollExtent;
      if (_reduceMotion) {
        _scrollController.jumpTo(max);
      } else {
        _scrollController.animateTo(
          max,
          duration: AurisTokens.durationNormal,
          curve: AurisTokens.curveDefault,
        );
      }
    });
  }

  Color _lineColor(AurisScheme scheme, AurisTerminalLineType type) {
    switch (type) {
      case AurisTerminalLineType.normal:
        return scheme.textMid;
      case AurisTerminalLineType.ok:
        return scheme.successBright;
      case AurisTerminalLineType.error:
        return scheme.dangerBright;
      case AurisTerminalLineType.augment:
        return scheme.primaryActive;
      case AurisTerminalLineType.warning:
        return scheme.primaryDim;
    }
  }

  @override
  Widget build(BuildContext context) {
    final AurisScheme scheme = Theme.of(context).extension<AurisScheme>()!;
    final int lastIndex = widget.lines.length - 1;

    return AurisPanel(
      title: widget.title,
      code: widget.code,
      padding: EdgeInsets.zero,
      child: ColoredBox(
        color: scheme.surfacePage,
        child: SizedBox(
          height: widget.height,
          child: Scrollbar(
            controller: _scrollController,
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              itemCount: widget.lines.length,
              itemBuilder: (BuildContext context, int index) {
                final AurisTerminalLine line = widget.lines[index];
                final bool isLast = index == lastIndex;
                return _TerminalRow(
                  text: line.text,
                  color: _lineColor(scheme, line.type),
                  cursorColor: scheme.primaryActive,
                  showCursor: isLast && widget.showCursor,
                  blink: _blink,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// One monospace log row, optionally trailed by a blinking block cursor.
class _TerminalRow extends StatelessWidget {
  const _TerminalRow({
    required this.text,
    required this.color,
    required this.cursorColor,
    required this.showCursor,
    required this.blink,
  });

  final String text;
  final Color color;
  final Color cursorColor;
  final bool showCursor;
  final Animation<double> blink;

  @override
  Widget build(BuildContext context) {
    final TextStyle style = TextStyle(
      fontFamily: AurisTokens.fontMono,
      fontFamilyFallback: AurisTokens.fontMonoFallback,
      fontSize: 12.5,
      height: 1.5,
      letterSpacing: 0.5,
      color: color,
    );

    if (!showCursor) {
      return Text(text, style: style);
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Flexible(child: Text(text, style: style)),
        const SizedBox(width: 6),
        AnimatedBuilder(
          animation: blink,
          builder: (BuildContext context, _) {
            return Opacity(
              opacity: blink.value < 0.5 ? 0.0 : 1.0,
              child: Container(width: 8, height: 14, color: cursorColor),
            );
          },
        ),
      ],
    );
  }
}
