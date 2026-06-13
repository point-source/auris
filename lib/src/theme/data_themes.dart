import 'package:flutter/material.dart';

import '../painters/chamfer_border.dart';
import '../scheme.dart';
import '../tokens.dart';

/// Builders for the Material data and feedback component themes, all derived
/// from the resolved [AurisScheme] (§spec:scheme) rather than from raw
/// primitives, so a future accent / brightness change re-skins them
/// automatically (§road:data-feedback-themes).
///
/// Covered: [DataTable], [ListTile], [ExpansionTile], [ProgressIndicator],
/// [Divider], [Badge], and [SearchBar] / [SearchView].
///
/// **Stepper note (§spec:theme-layer).** Flutter exposes no `StepperThemeData`
/// on `ThemeData`; `Stepper` derives its connector / step-circle colors from the
/// `ColorScheme` (primary for active, error for failed). Auris's `ColorScheme`
/// is already derived from the resolved scheme in `AurisTheme.light`, so the
/// stepper picks up gold active circles and danger error states without a
/// dedicated theme. The chamfered step marker is offered as the `AurisStepIndicator`
/// custom widget (a later batch) for use with `Stepper.stepIconBuilder`.
///
/// Signature treatments (§spec:theme-layer):
///
/// - **Shape:** the chamfered [AurisChamferBorder] on tiles and the search
///   surfaces; chamfered border radius on the linear progress track.
/// - **Elevation:** `0`; `surfaceTintColor` / `shadowColor` transparent.
/// - **Color roles:** `gold` for active fills / progress, `amber`/dim for
///   inactive, `borderBright` for resting outlines and dividers.
/// - **Typography:** monospace for data-bearing surfaces (table cells, badges).
abstract final class AurisDataThemes {
  const AurisDataThemes._();

  /// A chamfered rectangle border sized from a bevel role.
  static AurisChamferBorder _bevel(double size) =>
      AurisChamferBorder(cut: size);

  /// A chamfered border with a visible resting outline.
  static AurisChamferBorder _bevelOutlined(double size, Color color) =>
      AurisChamferBorder(cut: size, side: BorderSide(color: color));

  // ---------------------------------------------------------------------------
  // DataTable — mono cells, panel surface, gold-tinted selection, bright rules.
  // ---------------------------------------------------------------------------

  /// The [DataTableThemeData]: panel surface, monospace data cells, an
  /// uppercase heading row, gold-tinted selected rows, and bright dividers.
  static DataTableThemeData dataTable(AurisScheme scheme) {
    return DataTableThemeData(
      decoration: BoxDecoration(
        color: scheme.surfacePanel,
        border: Border.all(color: scheme.borderBright),
        borderRadius: BorderRadius.all(Radius.circular(scheme.bevel.md)),
      ),
      dataRowColor: WidgetStateProperty.resolveWith<Color?>(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.selected)) {
            return scheme.primaryActive.withValues(alpha: 0.16);
          }
          if (states.contains(WidgetState.hovered)) {
            return scheme.surfaceInset;
          }
          return null;
        },
      ),
      headingRowColor: WidgetStatePropertyAll<Color>(scheme.surfaceInset),
      dividerThickness: 1,
      headingTextStyle: TextStyle(
        fontFamily: AurisTokens.fontMono,
        fontSize: 12,
        letterSpacing: AurisTokens.trackingLabel,
        color: scheme.primaryActive,
      ),
      dataTextStyle: TextStyle(
        fontFamily: AurisTokens.fontMono,
        fontSize: 13,
        letterSpacing: AurisTokens.trackingBody,
        color: scheme.textBright,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // ListTile — chamfered, gold selected, mono-uppercase title.
  // ---------------------------------------------------------------------------

  /// The [ListTileThemeData]: chamfered tile, gold-active selection, gold
  /// leading / trailing icons, and an uppercase letter-spaced title.
  static ListTileThemeData listTile(AurisScheme scheme) {
    return ListTileThemeData(
      shape: _bevel(scheme.bevel.sm),
      iconColor: scheme.primaryDim,
      textColor: scheme.textBright,
      selectedColor: scheme.primaryActive,
      selectedTileColor: scheme.primaryActive.withValues(alpha: 0.12),
      tileColor: Colors.transparent,
      titleTextStyle: TextStyle(
        fontFamily: AurisTokens.fontBody,
        fontWeight: FontWeight.w600,
        fontSize: 14,
        letterSpacing: AurisTokens.trackingButton,
        color: scheme.textBright,
      ),
      subtitleTextStyle: TextStyle(
        fontFamily: AurisTokens.fontBody,
        fontSize: 12,
        letterSpacing: AurisTokens.trackingBody,
        color: scheme.textMid,
      ),
      leadingAndTrailingTextStyle: TextStyle(
        fontFamily: AurisTokens.fontMono,
        fontSize: 12,
        letterSpacing: AurisTokens.trackingLabel,
        color: scheme.primaryDim,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // ExpansionTile — chamfered, gold icons, panel surface when expanded.
  // ---------------------------------------------------------------------------

  /// The [ExpansionTileThemeData]: chamfered, gold expand icon / title, panel
  /// surface when expanded.
  static ExpansionTileThemeData expansionTile(AurisScheme scheme) {
    return ExpansionTileThemeData(
      backgroundColor: scheme.surfacePanel,
      collapsedBackgroundColor: Colors.transparent,
      iconColor: scheme.primaryActive,
      collapsedIconColor: scheme.primaryDim,
      textColor: scheme.primaryActive,
      collapsedTextColor: scheme.textBright,
      shape: _bevelOutlined(scheme.bevel.md, scheme.borderBright),
      collapsedShape: _bevelOutlined(scheme.bevel.md, scheme.borderResting),
    );
  }

  // ---------------------------------------------------------------------------
  // ProgressIndicator — gold value, inset track, chamfered linear corners.
  // ---------------------------------------------------------------------------

  /// The [ProgressIndicatorThemeData]: gold value on a dim inset track, with a
  /// chamfered linear track radius.
  ///
  /// Material's linear `ProgressIndicator` cannot be *segmented*
  /// (§spec:theme-layer "known limits"); the theme styles it as closely as
  /// possible and `AurisProgressBar` (a later batch) is the preferred segmented
  /// replacement.
  static ProgressIndicatorThemeData progressIndicator(AurisScheme scheme) {
    return ProgressIndicatorThemeData(
      color: scheme.primaryActive,
      linearTrackColor: scheme.surfaceInset,
      circularTrackColor: scheme.surfaceInset,
      linearMinHeight: 6,
      borderRadius: BorderRadius.all(Radius.circular(scheme.bevel.sm)),
    );
  }

  // ---------------------------------------------------------------------------
  // Divider — resting border color, hairline.
  // ---------------------------------------------------------------------------

  /// The [DividerThemeData]: a hairline in the resting border color.
  static DividerThemeData divider(AurisScheme scheme) {
    return DividerThemeData(
      color: scheme.borderResting,
      thickness: 1,
      space: 1,
    );
  }

  // ---------------------------------------------------------------------------
  // Badge — gold fill, near-black mono label.
  // ---------------------------------------------------------------------------

  /// The [BadgeThemeData]: gold fill with a near-black monospace label.
  static BadgeThemeData badge(AurisScheme scheme) {
    return BadgeThemeData(
      backgroundColor: scheme.primaryActive,
      textColor: scheme.onPrimary,
      textStyle: TextStyle(
        fontFamily: AurisTokens.fontMono,
        fontWeight: FontWeight.w600,
        fontSize: 11,
        letterSpacing: AurisTokens.trackingBody,
        color: scheme.onPrimary,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SearchBar — inset surface, chamfered, flat, mono hint.
  // ---------------------------------------------------------------------------

  /// The [SearchBarThemeData]: inset surface, chamfered medium bevel, flat,
  /// bright resting outline, amber overlay, and a monospace hint.
  static SearchBarThemeData searchBar(AurisScheme scheme) {
    return SearchBarThemeData(
      backgroundColor: WidgetStatePropertyAll<Color>(scheme.surfaceInset),
      surfaceTintColor:
          const WidgetStatePropertyAll<Color>(Colors.transparent),
      shadowColor: const WidgetStatePropertyAll<Color>(Colors.transparent),
      overlayColor: WidgetStateProperty.resolveWith<Color?>(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.pressed)) {
            return scheme.primaryActive.withValues(alpha: 0.24);
          }
          if (states.contains(WidgetState.hovered)) {
            return scheme.primaryActive.withValues(alpha: 0.12);
          }
          return null;
        },
      ),
      elevation: const WidgetStatePropertyAll<double>(0),
      side: WidgetStatePropertyAll<BorderSide>(
        BorderSide(color: scheme.borderBright),
      ),
      shape: WidgetStatePropertyAll<OutlinedBorder>(_bevel(scheme.bevel.md)),
      textStyle: WidgetStatePropertyAll<TextStyle>(
        TextStyle(
          fontFamily: AurisTokens.fontBody,
          fontSize: 14,
          letterSpacing: AurisTokens.trackingBody,
          color: scheme.textBright,
        ),
      ),
      hintStyle: WidgetStatePropertyAll<TextStyle>(
        TextStyle(
          fontFamily: AurisTokens.fontMono,
          fontSize: 13,
          letterSpacing: AurisTokens.trackingLabel,
          color: scheme.textDim,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SearchView — panel surface, chamfered, flat, mono header hint.
  // ---------------------------------------------------------------------------

  /// The [SearchViewThemeData]: panel surface, chamfered large bevel, flat,
  /// bright resting outline, with a monospace header hint and a resting divider.
  static SearchViewThemeData searchView(AurisScheme scheme) {
    return SearchViewThemeData(
      backgroundColor: scheme.surfacePanel,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      side: BorderSide(color: scheme.borderBright),
      shape: _bevelOutlined(scheme.bevel.lg, scheme.borderBright),
      dividerColor: scheme.borderResting,
      headerTextStyle: TextStyle(
        fontFamily: AurisTokens.fontBody,
        fontSize: 14,
        letterSpacing: AurisTokens.trackingBody,
        color: scheme.textBright,
      ),
      headerHintStyle: TextStyle(
        fontFamily: AurisTokens.fontMono,
        fontSize: 13,
        letterSpacing: AurisTokens.trackingLabel,
        color: scheme.textDim,
      ),
    );
  }
}
