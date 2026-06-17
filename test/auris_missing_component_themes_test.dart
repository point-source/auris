import 'package:auris/auris.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Tests for the component themes the census surfaced as missing
/// (§road:add-missing-component-themes): `ToggleButtons`, text selection,
/// `Menu` / `MenuBar`, `MaterialBanner`, `DatePicker`, `TimePicker`,
/// `BottomAppBar`, `BottomNavigationBar`, `NavigationDrawer`, `Scrollbar`, and
/// `CarouselView`. Each must be present on the assembled `ThemeData` and carry
/// the expected role colors / chamfered shapes derived from the resolved
/// [AurisScheme], so the accent / bevel / glow overrides propagate to them
/// (§spec:customization "Propagation invariant").
void main() {
  final ThemeData theme = AurisTheme.light();
  final AurisScheme scheme = theme.extension<AurisScheme>()!;

  /// True when [shape] is an [AurisChamferBorder] (the chamfered geometry).
  bool isBeveled(ShapeBorder? shape) => shape is AurisChamferBorder;

  group('all newly-populated slots are present', () {
    test('every census-surfaced slot is non-null on ThemeData', () {
      expect(theme.toggleButtonsTheme, isNotNull);
      expect(theme.textSelectionTheme, isNotNull);
      expect(theme.menuTheme, isNotNull);
      expect(theme.menuBarTheme, isNotNull);
      expect(theme.bannerTheme, isNotNull);
      expect(theme.datePickerTheme, isNotNull);
      expect(theme.timePickerTheme, isNotNull);
      expect(theme.bottomAppBarTheme, isNotNull);
      expect(theme.bottomNavigationBarTheme, isNotNull);
      expect(theme.navigationDrawerTheme, isNotNull);
      expect(theme.scrollbarTheme, isNotNull);
      expect(theme.carouselViewTheme, isNotNull);
    });
  });

  group('role colors / shapes derive from the scheme', () {
    test('ToggleButtons selects with the primary role', () {
      expect(theme.toggleButtonsTheme.selectedColor, scheme.primaryActive);
      expect(
        theme.toggleButtonsTheme.selectedBorderColor,
        scheme.primaryActive,
      );
    });

    test('text selection uses the gold cursor / handles', () {
      expect(theme.textSelectionTheme.cursorColor, scheme.primaryActive);
      expect(
        theme.textSelectionTheme.selectionHandleColor,
        scheme.primaryActive,
      );
      expect(theme.textSelectionTheme.selectionColor, isNotNull);
    });

    test('Menu and MenuBar surfaces are beveled on the panel surface', () {
      final OutlinedBorder? menuShape = theme.menuTheme.style!.shape!.resolve(
        <WidgetState>{},
      );
      final OutlinedBorder? barShape = theme.menuBarTheme.style!.shape!.resolve(
        <WidgetState>{},
      );
      expect(isBeveled(menuShape), isTrue);
      expect(isBeveled(barShape), isTrue);
      expect(
        theme.menuTheme.style!.backgroundColor!.resolve(<WidgetState>{}),
        scheme.surfacePanel,
      );
    });

    test('MaterialBanner is flat on the inset surface', () {
      expect(theme.bannerTheme.backgroundColor, scheme.surfaceInset);
      expect(theme.bannerTheme.elevation, 0);
      expect(theme.bannerTheme.dividerColor, scheme.borderResting);
    });

    test('DatePicker is beveled with a gold selected day', () {
      expect(isBeveled(theme.datePickerTheme.shape), isTrue);
      expect(theme.datePickerTheme.elevation, 0);
      final Color? selectedBg = theme.datePickerTheme.dayBackgroundColor!
          .resolve(<WidgetState>{WidgetState.selected});
      expect(selectedBg, scheme.primaryActive);
    });

    test('TimePicker is beveled with a gold dial hand', () {
      expect(isBeveled(theme.timePickerTheme.shape), isTrue);
      expect(theme.timePickerTheme.elevation, 0);
      expect(theme.timePickerTheme.dialHandColor, scheme.primaryActive);
    });

    test('BottomAppBar is flat on the panel surface', () {
      expect(theme.bottomAppBarTheme.color, scheme.surfacePanel);
      expect(theme.bottomAppBarTheme.elevation, 0);
    });

    test('BottomNavigationBar selects with the primary role', () {
      expect(
        theme.bottomNavigationBarTheme.selectedItemColor,
        scheme.primaryActive,
      );
      expect(
        theme.bottomNavigationBarTheme.backgroundColor,
        scheme.surfacePanel,
      );
      expect(theme.bottomNavigationBarTheme.elevation, 0);
    });

    test('NavigationDrawer has a beveled gold selection indicator', () {
      expect(isBeveled(theme.navigationDrawerTheme.indicatorShape), isTrue);
      expect(theme.navigationDrawerTheme.backgroundColor, scheme.surfacePanel);
      final TextStyle? selected = theme.navigationDrawerTheme.labelTextStyle!
          .resolve(<WidgetState>{WidgetState.selected});
      expect(selected!.color, scheme.primaryActive);
    });

    test('Scrollbar thumb brightens to the primary role on hover', () {
      final Color? hovered = theme.scrollbarTheme.thumbColor!.resolve(
        <WidgetState>{WidgetState.hovered},
      );
      expect(hovered, scheme.primaryActive);
      expect(
        theme.scrollbarTheme.trackColor!.resolve(<WidgetState>{}),
        scheme.surfaceInset,
      );
    });

    test('CarouselView is beveled on the inset surface', () {
      expect(isBeveled(theme.carouselViewTheme.shape), isTrue);
      expect(theme.carouselViewTheme.backgroundColor, scheme.surfaceInset);
      expect(theme.carouselViewTheme.elevation, 0);
    });
  });

  group('accent override re-skins every new component theme', () {
    test('a non-default accent flows into the new slots', () {
      const Color accent = Color(0xFF00FF99);
      final ThemeData themed = AurisTheme.light(accent: accent);
      // The light override is contrast-darkened; the component themes carry the
      // resolved ramp, not the raw bright accent.
      final Color active = themed.extension<AurisScheme>()!.primaryActive;
      expect(active, isNot(accent));

      expect(themed.toggleButtonsTheme.selectedColor, active);
      expect(themed.textSelectionTheme.cursorColor, active);
      expect(themed.timePickerTheme.dialHandColor, active);
      expect(themed.bottomNavigationBarTheme.selectedItemColor, active);
      expect(
        themed.datePickerTheme.dayBackgroundColor!.resolve(<WidgetState>{
          WidgetState.selected,
        }),
        active,
      );
      expect(
        themed.scrollbarTheme.thumbColor!.resolve(<WidgetState>{
          WidgetState.hovered,
        }),
        active,
      );
    });

    test('the bevel override reaches a chamfered new slot', () {
      final ThemeData tight = AurisTheme.light(bevelScale: 0.5);
      final ThemeData bold = AurisTheme.light(bevelScale: 2.0);
      final AurisChamferBorder tightShape =
          tight.carouselViewTheme.shape! as AurisChamferBorder;
      final AurisChamferBorder boldShape =
          bold.carouselViewTheme.shape! as AurisChamferBorder;
      expect(boldShape.cut, greaterThan(tightShape.cut));
    });
  });
}
