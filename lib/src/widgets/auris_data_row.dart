import 'package:flutter/material.dart';

import '../scheme.dart';
import '../tokens.dart';

/// A fixed-height key/value row with a bottom divider: the [label] on the left,
/// a monospace [value] on the right, an optional [trailing] widget, and an
/// optional [highlight] state that brightens the value and glows it
/// (§spec:custom-widgets).
///
/// This is the data-dense list primitive `ListTile` cannot reach: a hairline
/// rule, monospace values, and a gold glow on the highlighted value. Colors,
/// the highlight glow, and text roles resolve from the [AurisScheme].
class AurisDataRow extends StatelessWidget {
  /// Creates a key/value data row.
  const AurisDataRow({
    super.key,
    required this.label,
    this.value,
    this.trailing,
    this.highlight = false,
    this.height = 40,
  }) : assert(
          value != null || trailing != null,
          'Provide a value, a trailing widget, or both.',
        );

  /// The key / label (rendered uppercase).
  final String label;

  /// The monospace value text.
  final String? value;

  /// An optional trailing widget (e.g. a badge) shown after the value.
  final Widget? trailing;

  /// When true the value is brightened and given an active glow.
  final bool highlight;

  /// The fixed row height.
  final double height;

  @override
  Widget build(BuildContext context) {
    final AurisScheme scheme = Theme.of(context).extension<AurisScheme>()!;
    final Color valueColor =
        highlight ? scheme.primaryHighlight : scheme.textBright;

    return Container(
      height: height,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: scheme.borderResting),
        ),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              label.toUpperCase(),
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: AurisTokens.fontBody,
                fontSize: 12,
                letterSpacing: AurisTokens.trackingLabel,
                color: scheme.textMid,
              ),
            ),
          ),
          if (value != null)
            DecoratedBox(
              decoration: BoxDecoration(
                boxShadow: highlight ? scheme.depthActive.glow : null,
              ),
              child: Text(
                value!,
                style: TextStyle(
                  fontFamily: AurisTokens.fontMono,
                  fontSize: 13,
                  fontWeight: highlight ? FontWeight.w600 : FontWeight.w400,
                  letterSpacing: AurisTokens.trackingBody,
                  color: valueColor,
                ),
              ),
            ),
          if (trailing != null) ...<Widget>[
            const SizedBox(width: 10),
            trailing!,
          ],
        ],
      ),
    );
  }
}
