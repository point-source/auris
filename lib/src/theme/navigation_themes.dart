import 'package:flutter/material.dart';

import '../painters/chamfer_border.dart';
import '../scheme.dart';
import '../tokens.dart';

/// Builders for the Material navigation-chrome component themes, all derived
/// from the resolved [AurisScheme] (§spec:scheme) rather than from raw
/// primitives, so a future accent / brightness change re-skins them
/// automatically (§road:navigation-themes).
///
/// Covered: [AppBar], [BottomAppBar], [NavigationBar], [BottomNavigationBar],
/// [NavigationRail], [NavigationDrawer], and [TabBar].
///
/// Signature treatments (§spec:theme-layer):
///
/// - **Shape:** the chamfered [AurisChamferBorder] on the selection indicators.
/// - **Elevation:** `0` at all states; `surfaceTintColor` / `shadowColor`
///   transparent. Depth is glow, not Material shadow.
/// - **Ripple:** suppressed and replaced with an amber `overlayColor` on
///   hover / focus / press.
/// - **Color roles:** `gold` for the active/selected destination, `amber`/dim
///   for inactive, `borderBright` for resting dividers.
/// - **Typography:** uppercase, letter-spaced labels.
abstract final class AurisNavigationThemes {
  const AurisNavigationThemes._();

  /// The chamfered selection-indicator shape, sized from the small bevel role.
  static AurisChamferBorder _indicator(AurisScheme scheme) =>
      AurisChamferBorder(cut: scheme.bevel.sm);

  /// An amber hover / focus / press overlay tinting [base], replacing the ink
  /// ripple.
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

  // ---------------------------------------------------------------------------
  // AppBar — panel surface, flat, mono-uppercase title, gold icons.
  // ---------------------------------------------------------------------------

  /// The [AppBarThemeData]: panel surface, flat (no scroll-under elevation),
  /// gold icons, and an uppercase letter-spaced title.
  static AppBarThemeData appBar(AurisScheme scheme) {
    return AppBarThemeData(
      backgroundColor: scheme.surfacePanel,
      foregroundColor: scheme.textBright,
      elevation: 0,
      scrolledUnderElevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      centerTitle: false,
      iconTheme: IconThemeData(color: scheme.primaryActive),
      actionsIconTheme: IconThemeData(color: scheme.primaryActive),
      titleTextStyle: TextStyle(
        fontFamily: AurisTokens.fontDisplay,
        fontFamilyFallback: AurisTokens.fontDisplayFallback,
        fontWeight: FontWeight.w600,
        fontSize: 20,
        letterSpacing: AurisTokens.trackingHeading,
        color: scheme.textBright,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // BottomAppBar — panel surface, flat, no drop shadow.
  // ---------------------------------------------------------------------------

  /// The [BottomAppBarTheme]: a flat panel-surface bar with no Material drop
  /// shadow. `BottomAppBarTheme.shape` is a `NotchedShape` (for the FAB cradle),
  /// not an `OutlinedBorder`, so the asymmetric chamfer cannot be applied to its
  /// silhouette; the surface and flat elevation still carry the aesthetic.
  static BottomAppBarThemeData bottomAppBar(AurisScheme scheme) {
    return BottomAppBarThemeData(
      color: scheme.surfacePanel,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      elevation: 0,
    );
  }

  // ---------------------------------------------------------------------------
  // NavigationBar — panel surface, chamfered gold indicator, mono labels.
  // ---------------------------------------------------------------------------

  /// The [NavigationBarThemeData]: panel surface, flat, chamfered gold-tinted
  /// selection indicator, and monospace uppercase labels that brighten when
  /// selected.
  static NavigationBarThemeData navigationBar(AurisScheme scheme) {
    return NavigationBarThemeData(
      backgroundColor: scheme.surfacePanel,
      elevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      indicatorColor: scheme.primaryActive.withValues(alpha: 0.20),
      indicatorShape: _indicator(scheme),
      overlayColor: _overlay(scheme.primaryActive),
      labelTextStyle: WidgetStateProperty.resolveWith<TextStyle?>(
        (Set<WidgetState> states) {
          final Color color = states.contains(WidgetState.selected)
              ? scheme.primaryActive
              : scheme.textMid;
          return TextStyle(
            fontFamily: AurisTokens.fontMono,
            fontFamilyFallback: AurisTokens.fontMonoFallback,
            fontSize: 11,
            letterSpacing: AurisTokens.trackingLabel,
            color: color,
          );
        },
      ),
      iconTheme: WidgetStateProperty.resolveWith<IconThemeData?>(
        (Set<WidgetState> states) {
          final Color color = states.contains(WidgetState.selected)
              ? scheme.primaryActive
              : scheme.primaryDim;
          return IconThemeData(color: color, size: 24);
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // BottomNavigationBar — legacy bottom nav. Panel surface, gold selected,
  // dim unselected, mono labels.
  // ---------------------------------------------------------------------------

  /// The [BottomNavigationBarThemeData] for the legacy `BottomNavigationBar`
  /// (the pre-`NavigationBar` API some apps still use): a flat panel surface
  /// with a gold selected destination, dim unselected, and monospace uppercase
  /// labels. The fixed type keeps every label visible.
  static BottomNavigationBarThemeData bottomNavigationBar(AurisScheme scheme) {
    return BottomNavigationBarThemeData(
      backgroundColor: scheme.surfacePanel,
      elevation: 0,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: scheme.primaryActive,
      unselectedItemColor: scheme.primaryDim,
      selectedIconTheme: IconThemeData(color: scheme.primaryActive, size: 24),
      unselectedIconTheme: IconThemeData(color: scheme.primaryDim, size: 24),
      showUnselectedLabels: true,
      selectedLabelStyle: TextStyle(
        fontFamily: AurisTokens.fontMono,
        fontFamilyFallback: AurisTokens.fontMonoFallback,
        fontSize: 11,
        letterSpacing: AurisTokens.trackingLabel,
        color: scheme.primaryActive,
      ),
      unselectedLabelStyle: TextStyle(
        fontFamily: AurisTokens.fontMono,
        fontFamilyFallback: AurisTokens.fontMonoFallback,
        fontSize: 11,
        letterSpacing: AurisTokens.trackingLabel,
        color: scheme.textMid,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // NavigationDrawer — panel surface, chamfered gold indicator, mono labels.
  // ---------------------------------------------------------------------------

  /// The [NavigationDrawerThemeData]: a flat panel surface with a chamfered
  /// gold-tinted selection indicator and monospace labels that brighten when
  /// selected — the same indicator treatment as [navigationBar] / [navigationRail]
  /// so the three nav surfaces read as one family. (The drawer *container* shape
  /// is set by the [Drawer] theme; this themes the destinations inside it.)
  static NavigationDrawerThemeData navigationDrawer(AurisScheme scheme) {
    return NavigationDrawerThemeData(
      backgroundColor: scheme.surfacePanel,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      elevation: 0,
      indicatorColor: scheme.primaryActive.withValues(alpha: 0.20),
      indicatorShape: _indicator(scheme),
      labelTextStyle: WidgetStateProperty.resolveWith<TextStyle?>(
        (Set<WidgetState> states) {
          final Color color = states.contains(WidgetState.selected)
              ? scheme.primaryActive
              : scheme.textMid;
          return TextStyle(
            fontFamily: AurisTokens.fontMono,
            fontFamilyFallback: AurisTokens.fontMonoFallback,
            fontSize: 13,
            letterSpacing: AurisTokens.trackingLabel,
            color: color,
          );
        },
      ),
      iconTheme: WidgetStateProperty.resolveWith<IconThemeData?>(
        (Set<WidgetState> states) {
          final Color color = states.contains(WidgetState.selected)
              ? scheme.primaryActive
              : scheme.primaryDim;
          return IconThemeData(color: color, size: 24);
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // NavigationRail — panel surface, chamfered gold indicator, mono labels.
  // ---------------------------------------------------------------------------

  /// The [NavigationRailThemeData]: panel surface, flat, chamfered gold-tinted
  /// indicator, with monospace uppercase selected / unselected labels.
  static NavigationRailThemeData navigationRail(AurisScheme scheme) {
    return NavigationRailThemeData(
      backgroundColor: scheme.surfacePanel,
      elevation: 0,
      useIndicator: true,
      indicatorColor: scheme.primaryActive.withValues(alpha: 0.20),
      indicatorShape: _indicator(scheme),
      selectedIconTheme: IconThemeData(color: scheme.primaryActive, size: 24),
      unselectedIconTheme: IconThemeData(color: scheme.primaryDim, size: 24),
      selectedLabelTextStyle: TextStyle(
        fontFamily: AurisTokens.fontMono,
        fontFamilyFallback: AurisTokens.fontMonoFallback,
        fontSize: 11,
        letterSpacing: AurisTokens.trackingLabel,
        color: scheme.primaryActive,
      ),
      unselectedLabelTextStyle: TextStyle(
        fontFamily: AurisTokens.fontMono,
        fontFamilyFallback: AurisTokens.fontMonoFallback,
        fontSize: 11,
        letterSpacing: AurisTokens.trackingLabel,
        color: scheme.textMid,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TabBar — gold underline indicator, mono-uppercase labels, amber overlay.
  // ---------------------------------------------------------------------------

  /// The [TabBarThemeData]: gold underline indicator, monospace uppercase
  /// labels (gold selected, dim unselected), amber overlay, ripple suppressed,
  /// and a resting bright divider.
  static TabBarThemeData tabBar(AurisScheme scheme) {
    return TabBarThemeData(
      indicatorColor: scheme.primaryActive,
      indicatorSize: TabBarIndicatorSize.tab,
      dividerColor: scheme.borderResting,
      labelColor: scheme.primaryActive,
      unselectedLabelColor: scheme.textMid,
      overlayColor: _overlay(scheme.primaryActive),
      splashFactory: NoSplash.splashFactory,
      labelStyle: TextStyle(
        fontFamily: AurisTokens.fontMono,
        fontFamilyFallback: AurisTokens.fontMonoFallback,
        fontSize: 13,
        letterSpacing: AurisTokens.trackingLabel,
        color: scheme.primaryActive,
      ),
      unselectedLabelStyle: TextStyle(
        fontFamily: AurisTokens.fontMono,
        fontFamilyFallback: AurisTokens.fontMonoFallback,
        fontSize: 13,
        letterSpacing: AurisTokens.trackingLabel,
        color: scheme.textMid,
      ),
    );
  }
}
