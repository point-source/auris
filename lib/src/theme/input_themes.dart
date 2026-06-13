import 'package:flutter/material.dart';

import '../painters/chamfer_border.dart';
import '../scheme.dart';
import '../tokens.dart';

/// Builders for the Material input and selection-control component themes, all
/// derived from the resolved [AurisScheme] (§spec:scheme) rather than from raw
/// primitives, so a future accent / brightness change re-skins them
/// automatically.
///
/// This file owns two related workstreams that share its scheme plumbing:
///
/// - **Inputs** (§road:input-themes): [InputDecorationTheme] and
///   [DropdownMenuThemeData] — filled inset surface, chamfered border, gold
///   focused border, mono uppercase labels.
/// - **Selection controls** (§road:selection-control-themes): [Checkbox],
///   [Radio], [Switch], [Slider], and [Chip] — gold checked / active,
///   suppressed splash replaced by an amber overlay, chamfered where the widget
///   allows.
abstract final class AurisInputThemes {
  const AurisInputThemes._();

  /// Disabled-state opacity (§spec:theme-layer "disabled state").
  static const double _disabledOpacity = 0.5;

  /// The chamfered border for input surfaces, sized from the scheme's medium
  /// bevel role.
  static AurisChamferInputBorder _inputBorder(
    AurisScheme scheme,
    Color color, [
    double width = 1,
  ]) {
    return AurisChamferInputBorder(
      cut: scheme.bevel.md,
      borderSide: BorderSide(color: color, width: width),
    );
  }

  /// A monospace, uppercase label style for input labels.
  static TextStyle _labelStyle(AurisScheme scheme, Color color) => TextStyle(
        fontFamily: AurisTokens.fontMono,
        fontSize: 13,
        letterSpacing: AurisTokens.trackingLabel,
        color: color,
      );

  // ---------------------------------------------------------------------------
  // InputDecoration — filled inset surface, chamfered border, gold focus.
  // ---------------------------------------------------------------------------

  /// The [InputDecorationTheme]: filled inset surface, chamfered border, gold
  /// focused border, mono uppercase labels.
  static InputDecorationTheme inputDecoration(AurisScheme scheme) {
    return InputDecorationTheme(
      filled: true,
      fillColor: scheme.surfaceInset,
      isDense: false,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      // Resting / enabled — bright resting outline.
      enabledBorder: _inputBorder(scheme, scheme.borderBright),
      border: _inputBorder(scheme, scheme.borderBright),
      // Focus — gold, slightly heavier.
      focusedBorder: _inputBorder(scheme, scheme.primaryActive, 1.6),
      // Error — danger.
      errorBorder: _inputBorder(scheme, scheme.danger),
      focusedErrorBorder: _inputBorder(scheme, scheme.dangerBright, 1.6),
      disabledBorder: _inputBorder(
        scheme,
        scheme.borderResting.withValues(alpha: _disabledOpacity),
      ),
      labelStyle: _labelStyle(scheme, scheme.textMid),
      floatingLabelStyle: _labelStyle(scheme, scheme.primaryActive),
      hintStyle: TextStyle(
        fontFamily: AurisTokens.fontBody,
        fontSize: 14,
        letterSpacing: AurisTokens.trackingBody,
        color: scheme.textDim,
      ),
      helperStyle: _labelStyle(scheme, scheme.textMid).copyWith(fontSize: 11),
      errorStyle: TextStyle(
        fontFamily: AurisTokens.fontMono,
        fontSize: 11,
        letterSpacing: AurisTokens.trackingLabel,
        color: scheme.dangerBright,
      ),
      prefixIconColor: scheme.primaryDim,
      suffixIconColor: scheme.primaryDim,
    );
  }

  // ---------------------------------------------------------------------------
  // DropdownMenu — chamfered field + chamfered popup menu surface.
  // ---------------------------------------------------------------------------

  /// The [DropdownMenuThemeData]: shares the input decoration and renders its
  /// popup on a chamfered inset surface.
  static DropdownMenuThemeData dropdownMenu(AurisScheme scheme) {
    return DropdownMenuThemeData(
      inputDecorationTheme: inputDecoration(scheme),
      textStyle: TextStyle(
        fontFamily: AurisTokens.fontBody,
        fontSize: 14,
        letterSpacing: AurisTokens.trackingBody,
        color: scheme.textBright,
      ),
      menuStyle: MenuStyle(
        backgroundColor:
            WidgetStatePropertyAll<Color>(scheme.surfacePanel),
        surfaceTintColor:
            const WidgetStatePropertyAll<Color>(Colors.transparent),
        shadowColor: const WidgetStatePropertyAll<Color>(Colors.transparent),
        elevation: const WidgetStatePropertyAll<double>(0),
        side: WidgetStatePropertyAll<BorderSide>(
          BorderSide(color: scheme.borderBright),
        ),
        shape: WidgetStatePropertyAll<OutlinedBorder>(
          AurisChamferBorder(cut: scheme.bevel.md),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Checkbox — gold check fill, suppressed splash, amber overlay, chamfered.
  // ---------------------------------------------------------------------------

  /// An amber hover / focus / press overlay tinting [base].
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

  /// The [CheckboxThemeData]: gold fill when checked, chamfered box, amber
  /// overlay, ripple suppressed.
  static CheckboxThemeData checkbox(AurisScheme scheme) {
    return CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith<Color?>(
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
      checkColor: WidgetStatePropertyAll<Color>(scheme.onPrimary),
      side: BorderSide(color: scheme.borderBright, width: 1.5),
      overlayColor: _overlay(scheme.primaryActive),
      splashRadius: 0,
      shape: AurisChamferBorder(cut: scheme.bevel.sm),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  // ---------------------------------------------------------------------------
  // Radio — gold selected, amber overlay, ripple suppressed.
  // ---------------------------------------------------------------------------

  /// The [RadioThemeData]: gold when selected, amber overlay, ripple
  /// suppressed. (Radio geometry is circular — Flutter exposes no chamfer.)
  static RadioThemeData radio(AurisScheme scheme) {
    return RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith<Color?>(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.disabled)) {
            return scheme.primaryActive.withValues(alpha: _disabledOpacity);
          }
          if (states.contains(WidgetState.selected)) {
            return scheme.primaryActive;
          }
          return scheme.borderBright;
        },
      ),
      overlayColor: _overlay(scheme.primaryActive),
      splashRadius: 0,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  // ---------------------------------------------------------------------------
  // Switch — gold active track + thumb, amber overlay, ripple suppressed.
  // ---------------------------------------------------------------------------

  /// The [SwitchThemeData]: gold active track and thumb, amber overlay, ripple
  /// suppressed.
  ///
  /// Material's `Switch` track cannot be chamfered through `ThemeData`
  /// (§spec:theme-layer "known limits"); the theme styles it as closely as
  /// possible and `AurisSwitch` (a later batch) is the preferred chamfered
  /// replacement.
  static SwitchThemeData switchTheme(AurisScheme scheme) {
    return SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith<Color?>(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.disabled)) {
            return scheme.primaryDim.withValues(alpha: _disabledOpacity);
          }
          if (states.contains(WidgetState.selected)) {
            return scheme.primaryActive;
          }
          return scheme.primaryDim;
        },
      ),
      trackColor: WidgetStateProperty.resolveWith<Color?>(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.disabled)) {
            return scheme.surfaceInset.withValues(alpha: _disabledOpacity);
          }
          if (states.contains(WidgetState.selected)) {
            return scheme.primaryActive.withValues(alpha: 0.35);
          }
          return scheme.surfaceInset;
        },
      ),
      trackOutlineColor: WidgetStateProperty.resolveWith<Color?>(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.selected)) {
            return scheme.primaryActive;
          }
          return scheme.borderBright;
        },
      ),
      overlayColor: _overlay(scheme.primaryActive),
      splashRadius: 0,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  // ---------------------------------------------------------------------------
  // Slider — gold active track + thumb, amber overlay, dim inactive track.
  // ---------------------------------------------------------------------------

  /// The [SliderThemeData]: gold active track and thumb, dim inactive track,
  /// amber overlay, ripple suppressed.
  static SliderThemeData slider(AurisScheme scheme) {
    return SliderThemeData(
      activeTrackColor: scheme.primaryActive,
      inactiveTrackColor: scheme.surfaceInset,
      thumbColor: scheme.primaryActive,
      overlayColor: scheme.primaryActive.withValues(alpha: 0.16),
      valueIndicatorColor: scheme.surfacePanel,
      activeTickMarkColor: scheme.onPrimary,
      inactiveTickMarkColor: scheme.borderBright,
      trackHeight: 4,
      trackShape: const RectangularSliderTrackShape(),
      overlayShape:
          const RoundSliderOverlayShape(overlayRadius: 16),
      valueIndicatorTextStyle: TextStyle(
        fontFamily: AurisTokens.fontMono,
        fontSize: 12,
        letterSpacing: AurisTokens.trackingLabel,
        color: scheme.textBright,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Chip — chamfered, gold selected, amber overlay, mono uppercase labels.
  // ---------------------------------------------------------------------------

  /// The [ChipThemeData]: chamfered, gold-selected, inset surface, mono
  /// uppercase labels, ripple suppressed.
  static ChipThemeData chip(AurisScheme scheme) {
    return ChipThemeData(
      backgroundColor: scheme.surfaceInset,
      selectedColor: scheme.primaryActive,
      disabledColor: scheme.surfaceInset.withValues(alpha: _disabledOpacity),
      checkmarkColor: scheme.onPrimary,
      secondarySelectedColor: scheme.primaryActive,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      elevation: 0,
      pressElevation: 0,
      side: BorderSide(color: scheme.borderBright),
      shape: AurisChamferBorder(cut: scheme.bevel.sm),
      labelStyle: TextStyle(
        fontFamily: AurisTokens.fontMono,
        fontSize: 12,
        letterSpacing: AurisTokens.trackingLabel,
        color: scheme.primaryActive,
      ),
      secondaryLabelStyle: TextStyle(
        fontFamily: AurisTokens.fontMono,
        fontSize: 12,
        letterSpacing: AurisTokens.trackingLabel,
        color: scheme.onPrimary,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    );
  }
}
