import 'package:flutter/material.dart';

import '../scheme.dart';
import '../tokens.dart';
import 'auris_container.dart';

/// The semantic intent of an [AurisBadge], mapped to a scheme role color.
enum AurisBadgeVariant {
  /// Dim amber — the resting / informational default.
  amber,

  /// Active gold — emphasized.
  gold,

  /// Cool slate secondary.
  slate,

  /// Danger / error.
  danger,

  /// Success / confirmation.
  success,

  /// Inactive / disabled-looking (dim text, no accent).
  inactive,
}

/// A small text-only status tag in monospace, colored by [variant]
/// (§spec:custom-widgets).
///
/// The badge is a tinted [AurisContainer]: a faint fill and outline in the
/// variant color with an uppercase monospace label, none of which `ThemeData`
/// can express as a reusable tag. All colors resolve from the [AurisScheme].
class AurisBadge extends StatelessWidget {
  /// Creates a status badge labelled [label], colored by [variant].
  const AurisBadge(
    this.label, {
    super.key,
    this.variant = AurisBadgeVariant.amber,
  });

  /// The badge text (rendered uppercase).
  final String label;

  /// The semantic color of the badge.
  final AurisBadgeVariant variant;

  Color _color(AurisScheme scheme) {
    switch (variant) {
      case AurisBadgeVariant.amber:
        return scheme.primaryDim;
      case AurisBadgeVariant.gold:
        return scheme.primaryActive;
      case AurisBadgeVariant.slate:
        return scheme.secondary;
      case AurisBadgeVariant.danger:
        return scheme.dangerBright;
      case AurisBadgeVariant.success:
        return scheme.successBright;
      case AurisBadgeVariant.inactive:
        return scheme.textDim;
    }
  }

  @override
  Widget build(BuildContext context) {
    final AurisScheme scheme = Theme.of(context).extension<AurisScheme>()!;
    final Color color = _color(scheme);
    return AurisContainer(
      cut: scheme.bevel.xs,
      fill: color.withValues(alpha: 0.12),
      borderColor: color.withValues(alpha: 0.55),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontFamily: AurisTokens.fontMono,
          fontFamilyFallback: AurisTokens.fontMonoFallback,
          fontSize: 11,
          height: 1.0,
          letterSpacing: AurisTokens.trackingLabel,
          color: color,
        ),
      ),
    );
  }
}
