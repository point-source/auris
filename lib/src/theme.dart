import 'package:flutter/material.dart';

import 'scheme.dart';
import 'theme/button_themes.dart';
import 'tokens.dart';

/// Factory for the Auris `ThemeData`.
///
/// [AurisTheme.light] returns a fully specified `ThemeData` whose `ColorScheme`
/// and full `TextTheme` are DERIVED FROM the resolved [AurisScheme]
/// (§spec:scheme), with that same scheme attached to `ThemeData.extensions` so
/// the custom widget library shares the exact resolved values (§spec:theme-layer).
///
/// "light" is a historical misnomer — Auris is always dark in v0.1.0. A genuine
/// light-background variant is anticipated (§spec:scope); [AurisTheme.dark] is
/// reserved and throws [UnimplementedError] until it lands.
///
/// This batch populates `ColorScheme`, `TextTheme`, and the button component
/// themes; the remaining component themes are added in later batches. Elevation
/// and shadow defaults already reflect the aesthetic: elevation is `0` and
/// shadows are transparent, so depth reads as glow rather than drop shadow.
abstract final class AurisTheme {
  const AurisTheme._();

  /// The default (and only implemented) Auris theme — always dark in v0.1.0.
  ///
  /// [accent], [bevelScale], and [glowScale] are optional customization
  /// overrides forwarded to [AurisScheme.resolve]; their defaults reproduce the
  /// canonical look exactly (§spec:customization).
  static ThemeData light({
    Color? accent,
    double bevelScale = 1.0,
    double glowScale = 1.0,
  }) {
    final AurisScheme scheme = AurisScheme.resolve(
      brightness: Brightness.dark,
      accent: accent,
      bevelScale: bevelScale,
      glowScale: glowScale,
    );

    final ColorScheme colorScheme = _colorSchemeFrom(scheme);
    final TextTheme textTheme = _textThemeFrom(scheme);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: scheme.surfacePage,
      canvasColor: scheme.surfacePage,
      // Depth is communicated by glow, not Material elevation shadow.
      shadowColor: Colors.transparent,
      splashFactory: NoSplash.splashFactory,
      // Button component themes — chamfered, flat, amber-overlaid, uppercase.
      filledButtonTheme: AurisButtonThemes.filled(scheme),
      elevatedButtonTheme: AurisButtonThemes.elevated(scheme),
      outlinedButtonTheme: AurisButtonThemes.outlined(scheme),
      textButtonTheme: AurisButtonThemes.text(scheme),
      iconButtonTheme: AurisButtonThemes.icon(scheme),
      floatingActionButtonTheme: AurisButtonThemes.fab(scheme),
      segmentedButtonTheme: AurisButtonThemes.segmented(scheme),
      // Carry the resolved scheme so custom widgets read the exact same values.
      extensions: <ThemeExtension<dynamic>>[scheme],
    );
  }

  /// Reserved for the anticipated light-background variant (§spec:scope).
  /// Unimplemented in v0.1.0.
  static ThemeData dark() {
    throw UnimplementedError(
      'AurisTheme.dark() is reserved for the anticipated light-background '
      'variant and is not implemented in v0.1.0 (see §spec:scope).',
    );
  }

  /// Derive a Material `ColorScheme` from the resolved [scheme].
  static ColorScheme _colorSchemeFrom(AurisScheme scheme) {
    return ColorScheme(
      brightness: scheme.brightness,
      primary: scheme.primaryActive,
      onPrimary: scheme.onPrimary,
      primaryContainer: scheme.primaryDim,
      onPrimaryContainer: scheme.textBright,
      secondary: scheme.secondary,
      onSecondary: scheme.surfacePage,
      secondaryContainer: scheme.secondaryDim,
      onSecondaryContainer: scheme.textBright,
      tertiary: scheme.primaryHighlight,
      onTertiary: scheme.surfacePage,
      error: scheme.dangerBright,
      onError: scheme.surfacePage,
      errorContainer: scheme.danger,
      onErrorContainer: scheme.textBright,
      surface: scheme.surfacePanel,
      onSurface: scheme.textBright,
      surfaceContainerLowest: scheme.surfacePage,
      surfaceContainerLow: scheme.surfacePanel,
      surfaceContainer: scheme.surfacePanel,
      surfaceContainerHigh: scheme.surfaceInset,
      surfaceContainerHighest: scheme.surfaceInset,
      onSurfaceVariant: scheme.textMid,
      outline: scheme.borderResting,
      outlineVariant: scheme.borderBright,
      shadow: Colors.transparent,
      surfaceTint: Colors.transparent,
      inverseSurface: scheme.textBright,
      onInverseSurface: scheme.surfacePage,
      inversePrimary: scheme.primaryDim,
    );
  }

  /// Derive the full Material `TextTheme` from the resolved [scheme].
  ///
  /// Display and headline-large roles use the display family (Rajdhani),
  /// uppercase and letter-spaced; body and label roles use the body family
  /// (Exo 2); label roles are uppercase and tracked. Data-bearing roles are not
  /// part of the standard `TextTheme`, so the monospace family is exposed
  /// through the scheme / custom widgets rather than here.
  static TextTheme _textThemeFrom(AurisScheme scheme) {
    final Color bright = scheme.textBright;
    final Color mid = scheme.textMid;

    return TextTheme(
      // Display — Rajdhani, uppercase, wide heading tracking.
      displayLarge: TextStyle(
        fontFamily: AurisTokens.fontDisplay,
        fontWeight: FontWeight.w700,
        fontSize: 57,
        height: 1.12,
        letterSpacing: AurisTokens.trackingHeading,
        color: bright,
      ),
      displayMedium: TextStyle(
        fontFamily: AurisTokens.fontDisplay,
        fontWeight: FontWeight.w700,
        fontSize: 45,
        height: 1.16,
        letterSpacing: AurisTokens.trackingHeading,
        color: bright,
      ),
      displaySmall: TextStyle(
        fontFamily: AurisTokens.fontDisplay,
        fontWeight: FontWeight.w600,
        fontSize: 36,
        height: 1.22,
        letterSpacing: AurisTokens.trackingHeading,
        color: bright,
      ),
      // Headline — Rajdhani. Headline-large is uppercase + tracked.
      headlineLarge: TextStyle(
        fontFamily: AurisTokens.fontDisplay,
        fontWeight: FontWeight.w600,
        fontSize: 32,
        height: 1.25,
        letterSpacing: AurisTokens.trackingHeading,
        color: bright,
      ),
      headlineMedium: TextStyle(
        fontFamily: AurisTokens.fontDisplay,
        fontWeight: FontWeight.w600,
        fontSize: 28,
        height: 1.29,
        letterSpacing: AurisTokens.trackingLabel,
        color: bright,
      ),
      headlineSmall: TextStyle(
        fontFamily: AurisTokens.fontDisplay,
        fontWeight: FontWeight.w600,
        fontSize: 24,
        height: 1.33,
        letterSpacing: AurisTokens.trackingLabel,
        color: bright,
      ),
      // Title — Rajdhani.
      titleLarge: TextStyle(
        fontFamily: AurisTokens.fontDisplay,
        fontWeight: FontWeight.w600,
        fontSize: 22,
        height: 1.27,
        letterSpacing: AurisTokens.trackingLabel,
        color: bright,
      ),
      titleMedium: TextStyle(
        fontFamily: AurisTokens.fontDisplay,
        fontWeight: FontWeight.w500,
        fontSize: 16,
        height: 1.5,
        letterSpacing: AurisTokens.trackingBody,
        color: bright,
      ),
      titleSmall: TextStyle(
        fontFamily: AurisTokens.fontDisplay,
        fontWeight: FontWeight.w500,
        fontSize: 14,
        height: 1.43,
        letterSpacing: AurisTokens.trackingBody,
        color: bright,
      ),
      // Body — Exo 2.
      bodyLarge: TextStyle(
        fontFamily: AurisTokens.fontBody,
        fontWeight: FontWeight.w400,
        fontSize: 16,
        height: 1.5,
        letterSpacing: AurisTokens.trackingBody,
        color: bright,
      ),
      bodyMedium: TextStyle(
        fontFamily: AurisTokens.fontBody,
        fontWeight: FontWeight.w400,
        fontSize: 14,
        height: 1.43,
        letterSpacing: AurisTokens.trackingBody,
        color: mid,
      ),
      bodySmall: TextStyle(
        fontFamily: AurisTokens.fontBody,
        fontWeight: FontWeight.w400,
        fontSize: 12,
        height: 1.33,
        letterSpacing: AurisTokens.trackingBody,
        color: mid,
      ),
      // Label — Exo 2, uppercase, tracked. Button-bearing roles use button
      // tracking.
      labelLarge: TextStyle(
        fontFamily: AurisTokens.fontBody,
        fontWeight: FontWeight.w600,
        fontSize: 14,
        height: 1.43,
        letterSpacing: AurisTokens.trackingButton,
        color: bright,
      ),
      labelMedium: TextStyle(
        fontFamily: AurisTokens.fontBody,
        fontWeight: FontWeight.w600,
        fontSize: 12,
        height: 1.33,
        letterSpacing: AurisTokens.trackingLabel,
        color: mid,
      ),
      labelSmall: TextStyle(
        fontFamily: AurisTokens.fontBody,
        fontWeight: FontWeight.w600,
        fontSize: 11,
        height: 1.45,
        letterSpacing: AurisTokens.trackingLabel,
        color: mid,
      ),
    );
  }
}
