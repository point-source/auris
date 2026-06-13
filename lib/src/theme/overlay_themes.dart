import 'package:flutter/material.dart';

import '../painters/chamfer_border.dart';
import '../scheme.dart';
import '../tokens.dart';

/// Builders for the Material surface and overlay component themes, all derived
/// from the resolved [AurisScheme] (§spec:scheme) rather than from raw
/// primitives, so a future accent / brightness change re-skins them
/// automatically (§road:surface-overlay-themes).
///
/// Covered: [Card], [Dialog], [SnackBar], [BottomSheet], [Drawer], [Tooltip],
/// and [PopupMenu].
///
/// Signature treatments applied to every surface (§spec:theme-layer):
///
/// - **Shape:** [AurisChamferBorder] — asymmetric chamfered corners. Panels and
///   dialogs use the extra-large bevel role; smaller overlays use medium.
/// - **Elevation:** `0` at all states; `surfaceTintColor` and `shadowColor`
///   transparent. Depth is communicated by glow, not Material drop shadow.
/// - **Color roles:** `panel` surface fills, `borderBright` resting outlines,
///   gold/amber for accented text.
/// - **Typography:** monospace for data-bearing surfaces (tooltips, menus).
///
/// **Known limit (§spec:theme-layer).** `ThemeData` cannot attach a glow
/// `BoxShadow` to the dialog / popup / snackbar surfaces (they render their own
/// `Material` whose elevation we force to `0`). The chamfered shape and flat
/// elevation are applied here; where a glow matters on these surfaces it is
/// delivered by the consuming custom widget (§spec:custom-widgets), not the
/// theme.
abstract final class AurisOverlayThemes {
  const AurisOverlayThemes._();

  /// A chamfered border with a visible resting outline, for surfaces that read
  /// better with an explicit edge (dialogs, menus, sheets).
  static AurisChamferBorder _bevelOutlined(double size, Color color) =>
      AurisChamferBorder(cut: size, side: BorderSide(color: color));

  // ---------------------------------------------------------------------------
  // Card — panel surface, chamfered, flat, resting outline.
  // ---------------------------------------------------------------------------

  /// The [CardThemeData]: panel surface, chamfered large bevel, flat, with a
  /// resting bright outline in place of a drop shadow.
  static CardThemeData card(AurisScheme scheme) {
    return CardThemeData(
      clipBehavior: Clip.antiAlias,
      color: scheme.surfacePanel,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      margin: const EdgeInsets.all(8),
      shape: _bevelOutlined(scheme.bevel.lg, scheme.borderBright),
    );
  }

  // ---------------------------------------------------------------------------
  // Dialog — panel surface, extra-large bevel, mono-uppercase title.
  // ---------------------------------------------------------------------------

  /// The [DialogThemeData]: panel surface, extra-large chamfer, flat, with a
  /// monospace uppercase title and body text.
  static DialogThemeData dialog(AurisScheme scheme) {
    return DialogThemeData(
      backgroundColor: scheme.surfacePanel,
      elevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      iconColor: scheme.primaryActive,
      shape: _bevelOutlined(scheme.bevel.xl, scheme.borderBright),
      titleTextStyle: TextStyle(
        fontFamily: AurisTokens.fontDisplay,
        fontWeight: FontWeight.w600,
        fontSize: 20,
        letterSpacing: AurisTokens.trackingHeading,
        color: scheme.textBright,
      ),
      contentTextStyle: TextStyle(
        fontFamily: AurisTokens.fontBody,
        fontSize: 14,
        height: 1.43,
        letterSpacing: AurisTokens.trackingBody,
        color: scheme.textMid,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SnackBar — inset surface, chamfered, gold action, mono content.
  // ---------------------------------------------------------------------------

  /// The [SnackBarThemeData]: inset surface, chamfered medium bevel, flat, with
  /// a gold action label and monospace content.
  static SnackBarThemeData snackBar(AurisScheme scheme) {
    return SnackBarThemeData(
      backgroundColor: scheme.surfaceInset,
      actionTextColor: scheme.primaryActive,
      disabledActionTextColor:
          scheme.primaryActive.withValues(alpha: 0.5),
      closeIconColor: scheme.primaryDim,
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      shape: _bevelOutlined(scheme.bevel.md, scheme.borderBright),
      contentTextStyle: TextStyle(
        fontFamily: AurisTokens.fontMono,
        fontSize: 13,
        letterSpacing: AurisTokens.trackingLabel,
        color: scheme.textBright,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // BottomSheet — panel surface, top-chamfered, flat.
  // ---------------------------------------------------------------------------

  /// The [BottomSheetThemeData]: panel surface, chamfered extra-large top
  /// corners, flat, with a gold drag handle.
  static BottomSheetThemeData bottomSheet(AurisScheme scheme) {
    return BottomSheetThemeData(
      backgroundColor: scheme.surfacePanel,
      modalBackgroundColor: scheme.surfacePanel,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      modalBarrierColor: scheme.surfacePage.withValues(alpha: 0.72),
      elevation: 0,
      modalElevation: 0,
      showDragHandle: true,
      dragHandleColor: scheme.primaryDim,
      clipBehavior: Clip.antiAlias,
      shape: AurisChamferBorder(
        cut: scheme.bevel.xl,
        side: BorderSide(color: scheme.borderBright),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Drawer — panel surface, chamfered trailing edge, flat.
  // ---------------------------------------------------------------------------

  /// The [DrawerThemeData]: panel surface, chamfered trailing corners, flat.
  static DrawerThemeData drawer(AurisScheme scheme) {
    return DrawerThemeData(
      backgroundColor: scheme.surfacePanel,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      scrimColor: scheme.surfacePage.withValues(alpha: 0.72),
      elevation: 0,
      shape: AurisChamferBorder(
        cut: scheme.bevel.xl,
        side: BorderSide(color: scheme.borderBright),
      ),
      endShape: AurisChamferBorder(
        cut: scheme.bevel.xl,
        side: BorderSide(color: scheme.borderBright),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Tooltip — inset surface, chamfered, mono uppercase text, no shadow.
  // ---------------------------------------------------------------------------

  /// The [TooltipThemeData]: inset surface, chamfered small bevel, flat, with
  /// monospace uppercase text on a bright resting outline.
  static TooltipThemeData tooltip(AurisScheme scheme) {
    return TooltipThemeData(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: scheme.surfaceInset,
        border: Border.all(color: scheme.borderBright),
        borderRadius: BorderRadius.all(Radius.circular(scheme.bevel.sm)),
      ),
      textStyle: TextStyle(
        fontFamily: AurisTokens.fontMono,
        fontSize: 12,
        letterSpacing: AurisTokens.trackingLabel,
        color: scheme.textBright,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // PopupMenu — panel surface, chamfered, mono labels, flat.
  // ---------------------------------------------------------------------------

  /// The [PopupMenuThemeData]: panel surface, chamfered medium bevel, flat,
  /// with monospace labels and a gold-active selected label.
  static PopupMenuThemeData popupMenu(AurisScheme scheme) {
    return PopupMenuThemeData(
      color: scheme.surfacePanel,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      iconColor: scheme.primaryDim,
      elevation: 0,
      shape: _bevelOutlined(scheme.bevel.md, scheme.borderBright),
      labelTextStyle: WidgetStateProperty.resolveWith<TextStyle?>(
        (Set<WidgetState> states) {
          final Color color = states.contains(WidgetState.disabled)
              ? scheme.textMid.withValues(alpha: 0.5)
              : scheme.textBright;
          return TextStyle(
            fontFamily: AurisTokens.fontMono,
            fontSize: 13,
            letterSpacing: AurisTokens.trackingLabel,
            color: color,
          );
        },
      ),
    );
  }
}
