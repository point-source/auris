import 'package:flutter/material.dart';

import '../scheme.dart';
import '../tokens.dart';

/// Builders for the Material button component themes, all derived from the
/// resolved [AurisScheme] (§spec:scheme) rather than from raw primitives, so a
/// future accent / brightness change re-skins them automatically.
///
/// Signature treatments applied to every button (§spec:theme-layer):
///
/// - **Shape:** [BeveledRectangleBorder] at the scheme's medium bevel — the
///   chamfered (45°) corners that define the look.
/// - **Elevation:** `0` at all states; `surfaceTintColor` transparent. Depth is
///   glow, not Material shadow.
/// - **Ripple:** suppressed (the theme uses [NoSplash]) and replaced with an
///   amber `overlayColor` on hover / focus / press.
/// - **Color roles:** `gold`/active for primary fills, `amber`/dim for
///   inactive, `borderBright` for resting outlines, `bright` for focus.
/// - **Typography:** uppercase, letter-spaced button text.
abstract final class AurisButtonThemes {
  const AurisButtonThemes._();

  /// Disabled-state opacity for foregrounds / borders (§spec:custom-widgets,
  /// §spec:theme-layer "disabled state").
  static const double _disabledOpacity = 0.5;

  /// The chamfered shape shared by every rectangular button, sized from the
  /// scheme's medium bevel role.
  static BeveledRectangleBorder _bevel(AurisScheme scheme) =>
      BeveledRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(scheme.bevel.md)),
      );

  /// The uppercase, letter-spaced button label style.
  static TextStyle _labelStyle(AurisScheme scheme) => TextStyle(
        fontFamily: AurisTokens.fontBody,
        fontWeight: FontWeight.w600,
        fontSize: 14,
        letterSpacing: AurisTokens.trackingButton,
        color: scheme.primaryActive,
      );

  /// An amber hover / focus / press overlay that replaces the ink ripple.
  ///
  /// [base] is the role the overlay tints (the gold/amber primary for most
  /// buttons). Press is the strongest, focus next, hover lightest.
  static WidgetStateProperty<Color?> _overlay(Color base) {
    return WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
      if (states.contains(WidgetState.pressed)) {
        return base.withValues(alpha: 0.24);
      }
      if (states.contains(WidgetState.focused)) {
        return base.withValues(alpha: 0.20);
      }
      if (states.contains(WidgetState.hovered)) {
        return base.withValues(alpha: 0.12);
      }
      return null;
    });
  }

  /// A foreground that dims to [_disabledOpacity] when disabled.
  static WidgetStateProperty<Color?> _foreground(Color enabled) {
    return WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
      if (states.contains(WidgetState.disabled)) {
        return enabled.withValues(alpha: _disabledOpacity);
      }
      return enabled;
    });
  }

  /// A solid background that dims when disabled (for filled-style buttons).
  static WidgetStateProperty<Color?> _background(Color enabled) {
    return WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
      if (states.contains(WidgetState.disabled)) {
        return enabled.withValues(alpha: _disabledOpacity);
      }
      return enabled;
    });
  }

  /// A gold focus / bright-on-hover outline that dims when disabled.
  static WidgetStateProperty<BorderSide?> _side(AurisScheme scheme) {
    return WidgetStateProperty.resolveWith<BorderSide?>(
      (Set<WidgetState> states) {
        if (states.contains(WidgetState.disabled)) {
          return BorderSide(
            color: scheme.borderResting.withValues(alpha: _disabledOpacity),
          );
        }
        if (states.contains(WidgetState.focused)) {
          return BorderSide(color: scheme.primaryHighlight, width: 1.5);
        }
        if (states.contains(WidgetState.hovered) ||
            states.contains(WidgetState.pressed)) {
          return BorderSide(color: scheme.primaryActive);
        }
        return BorderSide(color: scheme.borderBright);
      },
    );
  }

  static const EdgeInsets _padding =
      EdgeInsets.symmetric(horizontal: 20, vertical: 14);

  // ---------------------------------------------------------------------------
  // FilledButton — solid gold fill, near-black foreground.
  // ---------------------------------------------------------------------------

  /// The [FilledButton] theme: solid `gold` fill, near-black foreground.
  static FilledButtonThemeData filled(AurisScheme scheme) {
    return FilledButtonThemeData(
      style: ButtonStyle(
        backgroundColor: _background(scheme.primaryActive),
        foregroundColor: _foreground(scheme.onPrimary),
        overlayColor: _overlay(scheme.surfacePage),
        elevation: const WidgetStatePropertyAll<double>(0),
        shadowColor:
            const WidgetStatePropertyAll<Color>(Colors.transparent),
        surfaceTintColor:
            const WidgetStatePropertyAll<Color>(Colors.transparent),
        splashFactory: NoSplash.splashFactory,
        padding: const WidgetStatePropertyAll<EdgeInsets>(_padding),
        shape: WidgetStatePropertyAll<OutlinedBorder>(_bevel(scheme)),
        textStyle: WidgetStatePropertyAll<TextStyle>(
          _labelStyle(scheme).copyWith(color: scheme.onPrimary),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // ElevatedButton — inset panel surface, gold label, chamfered outline. No
  // Material elevation (depth reads as glow elsewhere).
  // ---------------------------------------------------------------------------

  /// The [ElevatedButton] theme: inset panel surface with a gold label.
  static ElevatedButtonThemeData elevated(AurisScheme scheme) {
    return ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: _background(scheme.surfaceInset),
        foregroundColor: _foreground(scheme.primaryActive),
        overlayColor: _overlay(scheme.primaryActive),
        elevation: const WidgetStatePropertyAll<double>(0),
        shadowColor:
            const WidgetStatePropertyAll<Color>(Colors.transparent),
        surfaceTintColor:
            const WidgetStatePropertyAll<Color>(Colors.transparent),
        splashFactory: NoSplash.splashFactory,
        padding: const WidgetStatePropertyAll<EdgeInsets>(_padding),
        side: _side(scheme),
        shape: WidgetStatePropertyAll<OutlinedBorder>(_bevel(scheme)),
        textStyle: WidgetStatePropertyAll<TextStyle>(_labelStyle(scheme)),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // OutlinedButton — transparent fill, chamfered outline, gold label.
  // ---------------------------------------------------------------------------

  /// The [OutlinedButton] theme: transparent fill with a chamfered outline.
  static OutlinedButtonThemeData outlined(AurisScheme scheme) {
    return OutlinedButtonThemeData(
      style: ButtonStyle(
        backgroundColor:
            const WidgetStatePropertyAll<Color>(Colors.transparent),
        foregroundColor: _foreground(scheme.primaryActive),
        overlayColor: _overlay(scheme.primaryActive),
        elevation: const WidgetStatePropertyAll<double>(0),
        shadowColor:
            const WidgetStatePropertyAll<Color>(Colors.transparent),
        surfaceTintColor:
            const WidgetStatePropertyAll<Color>(Colors.transparent),
        splashFactory: NoSplash.splashFactory,
        padding: const WidgetStatePropertyAll<EdgeInsets>(_padding),
        side: _side(scheme),
        shape: WidgetStatePropertyAll<OutlinedBorder>(_bevel(scheme)),
        textStyle: WidgetStatePropertyAll<TextStyle>(_labelStyle(scheme)),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TextButton — no fill, no outline, gold label with amber overlay.
  // ---------------------------------------------------------------------------

  /// The [TextButton] theme: no fill or outline, gold label.
  static TextButtonThemeData text(AurisScheme scheme) {
    return TextButtonThemeData(
      style: ButtonStyle(
        backgroundColor:
            const WidgetStatePropertyAll<Color>(Colors.transparent),
        foregroundColor: _foreground(scheme.primaryActive),
        overlayColor: _overlay(scheme.primaryActive),
        elevation: const WidgetStatePropertyAll<double>(0),
        shadowColor:
            const WidgetStatePropertyAll<Color>(Colors.transparent),
        surfaceTintColor:
            const WidgetStatePropertyAll<Color>(Colors.transparent),
        splashFactory: NoSplash.splashFactory,
        padding: const WidgetStatePropertyAll<EdgeInsets>(_padding),
        shape: WidgetStatePropertyAll<OutlinedBorder>(_bevel(scheme)),
        textStyle: WidgetStatePropertyAll<TextStyle>(_labelStyle(scheme)),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // IconButton — gold icon, amber overlay, chamfered hit shape.
  // ---------------------------------------------------------------------------

  /// The [IconButton] theme: gold icon with an amber overlay.
  static IconButtonThemeData icon(AurisScheme scheme) {
    return IconButtonThemeData(
      style: ButtonStyle(
        foregroundColor: _foreground(scheme.primaryActive),
        iconColor: _foreground(scheme.primaryActive),
        overlayColor: _overlay(scheme.primaryActive),
        backgroundColor:
            const WidgetStatePropertyAll<Color>(Colors.transparent),
        elevation: const WidgetStatePropertyAll<double>(0),
        shadowColor:
            const WidgetStatePropertyAll<Color>(Colors.transparent),
        surfaceTintColor:
            const WidgetStatePropertyAll<Color>(Colors.transparent),
        splashFactory: NoSplash.splashFactory,
        shape: WidgetStatePropertyAll<OutlinedBorder>(_bevel(scheme)),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // FloatingActionButton — gold fill, chamfered, no elevation.
  // ---------------------------------------------------------------------------

  /// The [FloatingActionButton] theme: solid gold fill, chamfered, flat.
  static FloatingActionButtonThemeData fab(AurisScheme scheme) {
    return FloatingActionButtonThemeData(
      backgroundColor: scheme.primaryActive,
      foregroundColor: scheme.onPrimary,
      splashColor: scheme.surfacePage.withValues(alpha: 0.24),
      focusColor: scheme.surfacePage.withValues(alpha: 0.20),
      hoverColor: scheme.surfacePage.withValues(alpha: 0.12),
      elevation: 0,
      focusElevation: 0,
      hoverElevation: 0,
      highlightElevation: 0,
      disabledElevation: 0,
      enableFeedback: true,
      shape: _bevel(scheme),
    );
  }

  // ---------------------------------------------------------------------------
  // SegmentedButton — chamfered group, gold-filled selected segment.
  // ---------------------------------------------------------------------------

  /// The [SegmentedButton] theme: chamfered group with a gold-filled selected
  /// segment and amber overlay on the rest.
  static SegmentedButtonThemeData segmented(AurisScheme scheme) {
    return SegmentedButtonThemeData(
      selectedIcon: Icon(Icons.check, color: scheme.onPrimary, size: 18),
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith<Color?>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.disabled)) {
              return scheme.surfaceInset.withValues(alpha: _disabledOpacity);
            }
            if (states.contains(WidgetState.selected)) {
              return scheme.primaryActive;
            }
            return scheme.surfaceInset;
          },
        ),
        foregroundColor: WidgetStateProperty.resolveWith<Color?>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.disabled)) {
              return scheme.primaryActive.withValues(alpha: _disabledOpacity);
            }
            if (states.contains(WidgetState.selected)) {
              return scheme.onPrimary;
            }
            return scheme.primaryActive;
          },
        ),
        overlayColor: _overlay(scheme.primaryActive),
        side: _side(scheme),
        elevation: const WidgetStatePropertyAll<double>(0),
        surfaceTintColor:
            const WidgetStatePropertyAll<Color>(Colors.transparent),
        splashFactory: NoSplash.splashFactory,
        shape: WidgetStatePropertyAll<OutlinedBorder>(_bevel(scheme)),
        textStyle: WidgetStatePropertyAll<TextStyle>(_labelStyle(scheme)),
      ),
    );
  }
}
