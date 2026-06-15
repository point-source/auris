import 'package:auris/auris.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Tests for the core-control component themes (§road:button-themes,
/// §road:input-themes, §road:selection-control-themes): each is present on the
/// assembled `ThemeData` and carries the expected role colors / chamfered
/// shapes derived from the resolved [AurisScheme].
void main() {
  final ThemeData theme = AurisTheme.light();
  final AurisScheme scheme = theme.extension<AurisScheme>()!;

  /// True when [shape] is an [AurisChamferBorder] (the chamfered geometry).
  bool isBeveled(OutlinedBorder? shape) => shape is AurisChamferBorder;

  group('button themes', () {
    test('all button component themes are populated', () {
      expect(theme.filledButtonTheme.style, isNotNull);
      expect(theme.elevatedButtonTheme.style, isNotNull);
      expect(theme.outlinedButtonTheme.style, isNotNull);
      expect(theme.textButtonTheme.style, isNotNull);
      expect(theme.iconButtonTheme.style, isNotNull);
      expect(theme.segmentedButtonTheme.style, isNotNull);
    });

    test('ElevatedButton carries a beveled shape', () {
      final OutlinedBorder? shape = theme.elevatedButtonTheme.style!.shape!
          .resolve(<WidgetState>{});
      expect(isBeveled(shape), isTrue);
    });

    test('FilledButton uses the primary-active role as its fill', () {
      final Color? bg = theme.filledButtonTheme.style!.backgroundColor!
          .resolve(<WidgetState>{});
      expect(bg, scheme.primaryActive);
    });

    test('buttons are flat (elevation 0) at all states', () {
      final double? elev = theme.filledButtonTheme.style!.elevation!
          .resolve(<WidgetState>{WidgetState.pressed});
      expect(elev, 0);
    });

    test('ripple is replaced by an amber overlay on hover/focus/press', () {
      final WidgetStateProperty<Color?> overlay =
          theme.outlinedButtonTheme.style!.overlayColor!;
      expect(overlay.resolve(<WidgetState>{}), isNull);
      expect(
        overlay.resolve(<WidgetState>{WidgetState.hovered}),
        isNotNull,
      );
      expect(
        overlay.resolve(<WidgetState>{WidgetState.pressed}),
        isNotNull,
      );
      expect(
        theme.outlinedButtonTheme.style!.splashFactory,
        NoSplash.splashFactory,
      );
    });

    test('FloatingActionButton is flat with a beveled shape', () {
      expect(theme.floatingActionButtonTheme.elevation, 0);
      expect(
        theme.floatingActionButtonTheme.backgroundColor,
        scheme.primaryActive,
      );
      expect(
        theme.floatingActionButtonTheme.shape,
        isA<AurisChamferBorder>(),
      );
    });

    test('disabled foreground dims to 50% opacity', () {
      final Color enabled = theme.outlinedButtonTheme.style!.foregroundColor!
          .resolve(<WidgetState>{})!;
      final Color disabled = theme.outlinedButtonTheme.style!.foregroundColor!
          .resolve(<WidgetState>{WidgetState.disabled})!;
      expect(disabled.a, closeTo(enabled.a * 0.5, 0.001));
    });
  });

  group('input themes', () {
    test('InputDecorationTheme is filled on the inset surface', () {
      expect(theme.inputDecorationTheme.filled, isTrue);
      expect(theme.inputDecorationTheme.fillColor, scheme.surfaceInset);
    });

    test('focused border uses the gold primary-active role', () {
      final InputBorder? focused = theme.inputDecorationTheme.focusedBorder;
      expect(focused, isA<AurisChamferInputBorder>());
      expect(focused!.borderSide.color, scheme.primaryActive);
    });

    test('enabled input border is beveled (chamfered)', () {
      final AurisChamferInputBorder border =
          theme.inputDecorationTheme.enabledBorder! as AurisChamferInputBorder;
      // The chamfer cut derives from the scheme medium bevel.
      expect(border.cut, scheme.bevel.md);
    });

    test('DropdownMenu renders on a chamfered panel surface', () {
      final MenuStyle? menu = theme.dropdownMenuTheme.menuStyle;
      expect(menu, isNotNull);
      final OutlinedBorder? shape = menu!.shape!.resolve(<WidgetState>{});
      expect(isBeveled(shape), isTrue);
      expect(
        menu.backgroundColor!.resolve(<WidgetState>{}),
        scheme.surfacePanel,
      );
    });
  });

  group('selection control themes', () {
    test('Checkbox fill uses the primary role when selected', () {
      final Color? selected = theme.checkboxTheme.fillColor!
          .resolve(<WidgetState>{WidgetState.selected});
      expect(selected, scheme.primaryActive);
    });

    test('Checkbox has a beveled box and suppressed splash', () {
      expect(theme.checkboxTheme.shape, isA<AurisChamferBorder>());
      expect(theme.checkboxTheme.splashRadius, 0);
    });

    test('Radio fill uses the primary role when selected', () {
      final Color? selected = theme.radioTheme.fillColor!
          .resolve(<WidgetState>{WidgetState.selected});
      expect(selected, scheme.primaryActive);
      expect(theme.radioTheme.splashRadius, 0);
    });

    test('Switch thumb uses the primary role when selected', () {
      final Color? thumb = theme.switchTheme.thumbColor!
          .resolve(<WidgetState>{WidgetState.selected});
      expect(thumb, scheme.primaryActive);
    });

    test('Slider active track uses the primary role', () {
      expect(theme.sliderTheme.activeTrackColor, scheme.primaryActive);
      expect(theme.sliderTheme.thumbColor, scheme.primaryActive);
    });

    test('Chip is beveled and selects with the primary role', () {
      expect(theme.chipTheme.shape, isA<AurisChamferBorder>());
      expect(theme.chipTheme.selectedColor, scheme.primaryActive);
      expect(theme.chipTheme.elevation, 0);
    });
  });

  group('accent override re-skins component themes', () {
    test('a non-default accent flows into the button fill', () {
      const Color accent = Color(0xFF00FF99);
      final ThemeData themed = AurisTheme.light(accent: accent);
      // The light override is contrast-darkened; the components carry the
      // resolved ramp, not the raw bright accent.
      final Color active = themed.extension<AurisScheme>()!.primaryActive;
      expect(active, isNot(accent));

      final Color? bg = themed.filledButtonTheme.style!.backgroundColor!
          .resolve(<WidgetState>{});
      expect(bg, active);
      // And into the checkbox selected fill.
      final Color? checked = themed.checkboxTheme.fillColor!
          .resolve(<WidgetState>{WidgetState.selected});
      expect(checked, active);
    });
  });
}
