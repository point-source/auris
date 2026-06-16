import 'package:flutter/material.dart';

import '../scheme.dart';
import '../tokens.dart';
import 'auris_container.dart';

/// A titled card with a header strip, corner-bracket ornaments flanking the
/// title, an optional status [code], and an [accent] mode (gold border + subtle
/// glow) (§spec:custom-widgets).
///
/// Built on [AurisContainer]: the panel is the chamfered surface; the header is
/// an inset strip separated from the body by a divider. The little bracket
/// glyphs (`[` … `]`) that flank the title are the signature HUD ornament that
/// a plain `Card` header cannot reproduce. Colors / bevel / glow resolve from
/// the [AurisScheme].
class AurisPanel extends StatelessWidget {
  /// Creates a titled panel.
  const AurisPanel({
    super.key,
    required this.title,
    required this.child,
    this.code,
    this.accent = false,
    this.padding = const EdgeInsets.all(16),
  });

  /// The header title (rendered uppercase, display family).
  final String title;

  /// Optional monospace status code shown at the trailing end of the header.
  final String? code;

  /// When true, the panel uses a gold border + subtle active glow to read as
  /// emphasized / selected.
  final bool accent;

  /// The body content.
  final Widget child;

  /// Padding around the body content.
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final AurisScheme scheme = Theme.of(context).extension<AurisScheme>()!;
    final Color titleColor =
        accent ? scheme.primaryActive : scheme.textBright;
    final Color bracketColor =
        accent ? scheme.primaryActive : scheme.primaryDim;

    return AurisContainer(
      cut: scheme.bevel.lg,
      borderColor: accent ? scheme.primaryActive : scheme.borderBright,
      depth: accent ? scheme.depthSubtle : null,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // Header strip — inset surface with corner ticks flanking the title.
          ColoredBox(
            color: scheme.surfaceInset,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
              child: Row(
                children: <Widget>[
                  _CornerTick(color: bracketColor, left: true),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      title.toUpperCase(),
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: AurisTokens.fontDisplay,
                        fontFamilyFallback: AurisTokens.fontDisplayFallback,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        letterSpacing: AurisTokens.trackingHeading,
                        color: titleColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  _CornerTick(color: bracketColor, left: false),
                  if (code != null) ...<Widget>[
                    const Spacer(),
                    Text(
                      code!,
                      style: TextStyle(
                        fontFamily: AurisTokens.fontMono,
                        fontFamilyFallback: AurisTokens.fontMonoFallback,
                        fontSize: 11,
                        letterSpacing: AurisTokens.trackingLabel,
                        color: scheme.textMid,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          Container(height: 1, color: scheme.borderResting),
          // Body.
          Padding(padding: padding, child: child),
        ],
      ),
    );
  }
}

/// A small right-angle corner tick that marks a panel header corner — the
/// `⌐`/`¬` accent the reference uses instead of flanking `[ ]` brackets.
class _CornerTick extends StatelessWidget {
  const _CornerTick({required this.color, required this.left});

  final Color color;

  /// Top-left tick (top + left edges) when true; top-right (top + right) when
  /// false.
  final bool left;

  @override
  Widget build(BuildContext context) {
    final BorderSide side = BorderSide(color: color, width: 1.5);
    return SizedBox(
      width: 7,
      height: 7,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            top: side,
            left: left ? side : BorderSide.none,
            right: left ? BorderSide.none : side,
          ),
        ),
      ),
    );
  }
}
