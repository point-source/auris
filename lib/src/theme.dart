import 'package:flutter/material.dart';

import 'scheme.dart';
import 'theme/button_themes.dart';
import 'theme/data_themes.dart';
import 'theme/input_themes.dart';
import 'theme/navigation_themes.dart';
import 'theme/overlay_themes.dart';
import 'tokens.dart';

/// Factory for the Auris `ThemeData`.
///
/// [AurisTheme.dark] returns the canonical amber-on-near-black variant and
/// [AurisTheme.light] returns the clean technical light-background variant. Both
/// return a fully specified `ThemeData` whose `ColorScheme` and full `TextTheme`
/// are DERIVED FROM the resolved [AurisScheme] (§spec:scheme), with that same
/// scheme attached to `ThemeData.extensions` so the custom widget library shares
/// the exact resolved values (§spec:theme-layer).
///
/// The two variants are one resolution with a different `Brightness` input and
/// accept the same accent / bevel / glow overrides (§spec:customization). The
/// earlier `light()`-returns-dark misnomer is resolved — both are now honestly
/// named (§spec:overview "Variants").
///
/// This populates `ColorScheme`, `TextTheme`, the core-control component themes
/// (buttons including toggle buttons, input / dropdown decoration, text
/// selection, the menu surfaces, and the selection controls —
/// checkbox / radio / switch / slider / chip), the surface + overlay themes
/// (card, dialog, snackbar, material banner, bottom sheet, drawer, tooltip,
/// popup menu, date / time picker), the navigation-chrome themes (app bar,
/// bottom app bar, navigation bar / rail / drawer, bottom navigation bar, tab
/// bar), and the data + feedback themes (data table, list / expansion tile,
/// progress, divider, badge, search bar / view, scrollbar, carousel). The set is
/// defined by a census of every `ThemeData` component-theme slot
/// (`doc/component-theme-census.md`), not by the showcase. Elevation and shadow
/// defaults reflect the aesthetic: elevation is `0` and shadows are transparent,
/// so depth reads as glow rather than drop shadow.
abstract final class AurisTheme {
  const AurisTheme._();

  /// The clean technical light-background variant — light neutral surfaces and
  /// dark warm text, keeping the amber identity adjusted for light
  /// (§spec:overview "Variants"). [AurisTheme.dark] is the canonical variant.
  ///
  /// [accent], [bevelScale], and [glowScale] are optional customization
  /// overrides forwarded to [AurisScheme.resolve]; their defaults reproduce the
  /// canonical look exactly (§spec:customization).
  static ThemeData light({
    Color? accent,
    double bevelScale = 1.0,
    double glowScale = 1.0,
  }) {
    return _buildTheme(
      AurisScheme.resolve(
        brightness: Brightness.light,
        accent: accent,
        bevelScale: bevelScale,
        glowScale: glowScale,
      ),
    );
  }

  /// The canonical amber-on-near-black variant.
  ///
  /// [accent], [bevelScale], and [glowScale] are the same customization
  /// overrides as [light].
  static ThemeData dark({
    Color? accent,
    double bevelScale = 1.0,
    double glowScale = 1.0,
  }) {
    return _buildTheme(
      AurisScheme.resolve(
        brightness: Brightness.dark,
        accent: accent,
        bevelScale: bevelScale,
        glowScale: glowScale,
      ),
    );
  }

  /// Build the fully specified [ThemeData] from a resolved [scheme], for either
  /// brightness — the `ColorScheme`, `TextTheme`, and every component theme are
  /// derived from the same scheme, so the variant flows through one place.
  static ThemeData _buildTheme(AurisScheme scheme) {
    final ColorScheme colorScheme = _colorSchemeFrom(scheme);
    final TextTheme textTheme = _textThemeFrom(scheme);

    return ThemeData(
      useMaterial3: true,
      brightness: scheme.brightness,
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
      toggleButtonsTheme: AurisButtonThemes.toggleButtons(scheme),
      // Input + dropdown decoration + menu themes.
      inputDecorationTheme: AurisInputThemes.inputDecoration(scheme),
      textSelectionTheme: AurisInputThemes.textSelection(scheme),
      dropdownMenuTheme: AurisInputThemes.dropdownMenu(scheme),
      menuButtonTheme: AurisInputThemes.menuButton(scheme),
      menuTheme: AurisInputThemes.menu(scheme),
      menuBarTheme: AurisInputThemes.menuBar(scheme),
      // Selection-control component themes.
      checkboxTheme: AurisInputThemes.checkbox(scheme),
      radioTheme: AurisInputThemes.radio(scheme),
      switchTheme: AurisInputThemes.switchTheme(scheme),
      sliderTheme: AurisInputThemes.slider(scheme),
      chipTheme: AurisInputThemes.chip(scheme),
      // Surface + overlay component themes — chamfered, flat, glow-not-shadow.
      cardTheme: AurisOverlayThemes.card(scheme),
      dialogTheme: AurisOverlayThemes.dialog(scheme),
      snackBarTheme: AurisOverlayThemes.snackBar(scheme),
      bannerTheme: AurisOverlayThemes.banner(scheme),
      bottomSheetTheme: AurisOverlayThemes.bottomSheet(scheme),
      drawerTheme: AurisOverlayThemes.drawer(scheme),
      tooltipTheme: AurisOverlayThemes.tooltip(scheme),
      popupMenuTheme: AurisOverlayThemes.popupMenu(scheme),
      datePickerTheme: AurisOverlayThemes.datePicker(scheme),
      timePickerTheme: AurisOverlayThemes.timePicker(scheme),
      // Navigation-chrome component themes.
      appBarTheme: AurisNavigationThemes.appBar(scheme),
      bottomAppBarTheme: AurisNavigationThemes.bottomAppBar(scheme),
      navigationBarTheme: AurisNavigationThemes.navigationBar(scheme),
      bottomNavigationBarTheme: AurisNavigationThemes.bottomNavigationBar(
        scheme,
      ),
      navigationRailTheme: AurisNavigationThemes.navigationRail(scheme),
      navigationDrawerTheme: AurisNavigationThemes.navigationDrawer(scheme),
      tabBarTheme: AurisNavigationThemes.tabBar(scheme),
      // Data + feedback component themes. (Stepper has no ThemeData; it reads
      // the ColorScheme above — see AurisDataThemes docs.)
      dataTableTheme: AurisDataThemes.dataTable(scheme),
      listTileTheme: AurisDataThemes.listTile(scheme),
      expansionTileTheme: AurisDataThemes.expansionTile(scheme),
      progressIndicatorTheme: AurisDataThemes.progressIndicator(scheme),
      dividerTheme: AurisDataThemes.divider(scheme),
      badgeTheme: AurisDataThemes.badge(scheme),
      searchBarTheme: AurisDataThemes.searchBar(scheme),
      searchViewTheme: AurisDataThemes.searchView(scheme),
      scrollbarTheme: AurisDataThemes.scrollbar(scheme),
      carouselViewTheme: AurisDataThemes.carouselView(scheme),
      // Carry the resolved scheme so custom widgets read the exact same values.
      extensions: <ThemeExtension<dynamic>>[scheme],
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
        fontFamilyFallback: AurisTokens.fontDisplayFallback,
        fontWeight: FontWeight.w600,
        fontSize: 57,
        height: 1.12,
        letterSpacing: AurisTokens.trackingHeading,
        color: bright,
      ),
      displayMedium: TextStyle(
        fontFamily: AurisTokens.fontDisplay,
        fontFamilyFallback: AurisTokens.fontDisplayFallback,
        fontWeight: FontWeight.w600,
        fontSize: 45,
        height: 1.16,
        letterSpacing: AurisTokens.trackingHeading,
        color: bright,
      ),
      displaySmall: TextStyle(
        fontFamily: AurisTokens.fontDisplay,
        fontFamilyFallback: AurisTokens.fontDisplayFallback,
        fontWeight: FontWeight.w500,
        fontSize: 36,
        height: 1.22,
        letterSpacing: AurisTokens.trackingHeading,
        color: bright,
      ),
      // Headline — Rajdhani. Headline-large is uppercase + tracked.
      headlineLarge: TextStyle(
        fontFamily: AurisTokens.fontDisplay,
        fontFamilyFallback: AurisTokens.fontDisplayFallback,
        fontWeight: FontWeight.w500,
        fontSize: 32,
        height: 1.25,
        letterSpacing: AurisTokens.trackingHeading,
        color: bright,
      ),
      headlineMedium: TextStyle(
        fontFamily: AurisTokens.fontDisplay,
        fontFamilyFallback: AurisTokens.fontDisplayFallback,
        fontWeight: FontWeight.w500,
        fontSize: 28,
        height: 1.29,
        letterSpacing: AurisTokens.trackingLabel,
        color: bright,
      ),
      headlineSmall: TextStyle(
        fontFamily: AurisTokens.fontDisplay,
        fontFamilyFallback: AurisTokens.fontDisplayFallback,
        fontWeight: FontWeight.w500,
        fontSize: 24,
        height: 1.33,
        letterSpacing: AurisTokens.trackingLabel,
        color: bright,
      ),
      // Title — Rajdhani.
      titleLarge: TextStyle(
        fontFamily: AurisTokens.fontDisplay,
        fontFamilyFallback: AurisTokens.fontDisplayFallback,
        // w500 (Rajdhani Medium, a real bundled weight) reads a touch lighter
        // than the w600 SemiBold, which felt slightly heavy at this size.
        fontWeight: FontWeight.w500,
        fontSize: 22,
        height: 1.27,
        letterSpacing: AurisTokens.trackingLabel,
        color: bright,
      ),
      titleMedium: TextStyle(
        fontFamily: AurisTokens.fontDisplay,
        fontFamilyFallback: AurisTokens.fontDisplayFallback,
        fontWeight: FontWeight.w500,
        fontSize: 16,
        height: 1.5,
        letterSpacing: AurisTokens.trackingBody,
        color: bright,
      ),
      titleSmall: TextStyle(
        fontFamily: AurisTokens.fontDisplay,
        fontFamilyFallback: AurisTokens.fontDisplayFallback,
        fontWeight: FontWeight.w500,
        fontSize: 14,
        height: 1.43,
        letterSpacing: AurisTokens.trackingBody,
        color: bright,
      ),
      // Body — Exo 2.
      bodyLarge: TextStyle(
        fontFamily: AurisTokens.fontBody,
        fontFamilyFallback: AurisTokens.fontBodyFallback,
        fontWeight: FontWeight.w400,
        fontSize: 16,
        height: 1.5,
        letterSpacing: AurisTokens.trackingBody,
        color: bright,
      ),
      bodyMedium: TextStyle(
        fontFamily: AurisTokens.fontBody,
        fontFamilyFallback: AurisTokens.fontBodyFallback,
        fontWeight: FontWeight.w400,
        fontSize: 14,
        height: 1.43,
        letterSpacing: AurisTokens.trackingBody,
        color: mid,
      ),
      bodySmall: TextStyle(
        fontFamily: AurisTokens.fontBody,
        fontFamilyFallback: AurisTokens.fontBodyFallback,
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
        fontFamilyFallback: AurisTokens.fontBodyFallback,
        fontWeight: FontWeight.w500,
        fontSize: 14,
        height: 1.43,
        letterSpacing: AurisTokens.trackingButton,
        color: bright,
      ),
      labelMedium: TextStyle(
        fontFamily: AurisTokens.fontBody,
        fontFamilyFallback: AurisTokens.fontBodyFallback,
        fontWeight: FontWeight.w500,
        fontSize: 12,
        height: 1.33,
        letterSpacing: AurisTokens.trackingLabel,
        color: mid,
      ),
      labelSmall: TextStyle(
        fontFamily: AurisTokens.fontBody,
        fontFamilyFallback: AurisTokens.fontBodyFallback,
        fontWeight: FontWeight.w500,
        fontSize: 11,
        height: 1.45,
        letterSpacing: AurisTokens.trackingLabel,
        color: mid,
      ),
    );
  }
}
