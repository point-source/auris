import 'package:flutter/material.dart';

import '../scheme.dart';
import '../tokens.dart';
import 'auris_container.dart';

/// A KPI / metric tile: a [label], a large glowing [value] with an optional
/// [unit], and an optional signed [delta] (a success/danger arrow plus the
/// delta text) (§spec:custom-widgets).
///
/// Built on [AurisContainer]; the value glows via the scheme's active depth and
/// the delta's color/arrow are driven by the sign of [delta]. The large glowing
/// metric is the dashboard tile a plain `Card` cannot express. All colors and
/// the glow resolve from the [AurisScheme].
class AurisStatCard extends StatelessWidget {
  /// Creates a stat card.
  const AurisStatCard({
    super.key,
    required this.label,
    required this.value,
    this.unit,
    this.delta,
    this.deltaPositiveIsGood = true,
  });

  /// The metric label (rendered uppercase).
  final String label;

  /// The large primary value.
  final String value;

  /// Optional unit suffix shown after the value (e.g. `%`, `MW`).
  final String? unit;

  /// Optional signed delta (e.g. `+2.4%`, `-0.8`). A leading `-` colors the
  /// delta as the "bad" direction; anything else as the "good" direction.
  final String? delta;

  /// Whether a positive (non-`-`) delta is the favorable direction. When false
  /// the arrow/colors invert (e.g. for a latency metric where lower is better).
  final bool deltaPositiveIsGood;

  @override
  Widget build(BuildContext context) {
    final AurisScheme scheme = Theme.of(context).extension<AurisScheme>()!;

    return AurisContainer(
      cut: scheme.bevel.md,
      borderColor: scheme.borderBright,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            label.toUpperCase(),
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: AurisTokens.fontBody,
              fontSize: 12,
              letterSpacing: AurisTokens.trackingLabel,
              color: scheme.textMid,
            ),
          ),
          const SizedBox(height: 8),
          // Large glowing value with an optional unit baseline suffix.
          DecoratedBox(
            decoration: BoxDecoration(boxShadow: scheme.depthActive.glow),
            child: Text.rich(
              TextSpan(
                children: <InlineSpan>[
                  TextSpan(
                    text: value,
                    style: TextStyle(
                      fontFamily: AurisTokens.fontDisplay,
                      fontWeight: FontWeight.w700,
                      fontSize: 34,
                      height: 1.0,
                      letterSpacing: AurisTokens.trackingHeading,
                      color: scheme.primaryActive,
                    ),
                  ),
                  if (unit != null)
                    TextSpan(
                      text: ' ${unit!}',
                      style: TextStyle(
                        fontFamily: AurisTokens.fontMono,
                        fontSize: 14,
                        color: scheme.textMid,
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (delta != null) ...<Widget>[
            const SizedBox(height: 8),
            _Delta(
              delta: delta!,
              scheme: scheme,
              positiveIsGood: deltaPositiveIsGood,
            ),
          ],
        ],
      ),
    );
  }
}

/// The signed delta line: a directional arrow plus the delta text, colored by
/// whether the change is favorable.
class _Delta extends StatelessWidget {
  const _Delta({
    required this.delta,
    required this.scheme,
    required this.positiveIsGood,
  });

  final String delta;
  final AurisScheme scheme;
  final bool positiveIsGood;

  @override
  Widget build(BuildContext context) {
    final bool isNegative = delta.trimLeft().startsWith('-');
    final bool isGood = isNegative ? !positiveIsGood : positiveIsGood;
    final Color color = isGood ? scheme.successBright : scheme.dangerBright;
    final IconData arrow =
        isNegative ? Icons.arrow_downward : Icons.arrow_upward;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(arrow, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          delta,
          style: TextStyle(
            fontFamily: AurisTokens.fontMono,
            fontSize: 13,
            letterSpacing: AurisTokens.trackingBody,
            color: color,
          ),
        ),
      ],
    );
  }
}
