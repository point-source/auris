import 'package:flutter/material.dart';

import '../scheme.dart';
import '../tokens.dart';
import 'auris_container.dart';

/// The semantic intent of an [AurisNotification].
enum AurisNotificationVariant {
  /// Informational — gold accent.
  info,

  /// Success / confirmation — green accent.
  success,

  /// Warning — amber accent.
  warning,

  /// Error / danger — red accent.
  error,
}

/// An inline alert banner with a left accent bar + matching glow, a variant
/// icon, a [title], and an optional [message] / [code] and [onDismiss] action
/// (§spec:custom-widgets).
///
/// Built on [AurisContainer]; the accent bar and its glow are the depth-by-
/// intent cue rendered as a left edge rather than a full-box shadow. Colors,
/// bevel, and the per-variant depth all resolve from the [AurisScheme].
class AurisNotification extends StatelessWidget {
  /// Creates an inline notification banner.
  const AurisNotification({
    super.key,
    required this.title,
    this.message,
    this.code,
    this.variant = AurisNotificationVariant.info,
    this.onDismiss,
  });

  /// The headline (rendered uppercase).
  final String title;

  /// Optional supporting body text.
  final String? message;

  /// Optional monospace status code shown by the title.
  final String? code;

  /// The semantic color / icon of the banner.
  final AurisNotificationVariant variant;

  /// When non-null, a dismiss (×) button is shown that invokes this.
  final VoidCallback? onDismiss;

  ({Color accent, AurisDepth depth, IconData icon}) _resolve(
    AurisScheme scheme,
  ) {
    switch (variant) {
      case AurisNotificationVariant.info:
        return (
          accent: scheme.primaryActive,
          depth: scheme.depthActive,
          icon: Icons.info_outline,
        );
      case AurisNotificationVariant.success:
        return (
          accent: scheme.successBright,
          depth: scheme.depthSubtle,
          icon: Icons.check_circle_outline,
        );
      case AurisNotificationVariant.warning:
        return (
          accent: scheme.primaryActive,
          depth: scheme.depthSubtle,
          icon: Icons.warning_amber_outlined,
        );
      case AurisNotificationVariant.error:
        return (
          accent: scheme.dangerBright,
          depth: scheme.depthDanger,
          icon: Icons.error_outline,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final AurisScheme scheme = Theme.of(context).extension<AurisScheme>()!;
    final ({Color accent, AurisDepth depth, IconData icon}) v =
        _resolve(scheme);

    return AurisContainer(
      cut: scheme.bevel.md,
      borderColor: v.accent.withValues(alpha: 0.45),
      padding: EdgeInsets.zero,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Left accent bar with a soft edge glow that bleeds into the panel.
            // A dedicated glow (not the tight box depth token) because the bar
            // is only a few px wide — the depth token's negative spread would
            // shrink to nothing here.
            DecoratedBox(
              decoration: BoxDecoration(
                color: v.accent,
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: v.accent.withValues(alpha: 0.45),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: const SizedBox(width: 4),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Icon(v.icon, size: 20, color: v.accent),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Flexible(
                                child: Text(
                                  title.toUpperCase(),
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: AurisTokens.fontDisplay,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    letterSpacing: AurisTokens.trackingLabel,
                                    color: v.accent,
                                  ),
                                ),
                              ),
                              if (code != null) ...<Widget>[
                                const SizedBox(width: 8),
                                Text(
                                  code!,
                                  style: TextStyle(
                                    fontFamily: AurisTokens.fontMono,
                                    fontSize: 11,
                                    letterSpacing: AurisTokens.trackingLabel,
                                    color: scheme.textDim,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          if (message != null) ...<Widget>[
                            const SizedBox(height: 4),
                            Text(
                              message!,
                              style: TextStyle(
                                fontFamily: AurisTokens.fontBody,
                                fontSize: 13,
                                height: 1.3,
                                letterSpacing: AurisTokens.trackingBody,
                                color: scheme.textMid,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (onDismiss != null)
                      _DismissButton(color: scheme.textMid, onTap: onDismiss!),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The × dismiss affordance for a notification.
class _DismissButton extends StatelessWidget {
  const _DismissButton({required this.color, required this.onTap});

  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon: const Icon(Icons.close),
      iconSize: 16,
      color: color,
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
      tooltip: 'Dismiss',
    );
  }
}
