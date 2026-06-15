import 'package:auris/auris.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Tests for the surface / overlay (§road:surface-overlay-themes), navigation
/// (§road:navigation-themes), and data / feedback (§road:data-feedback-themes)
/// component themes: each is present on the assembled `ThemeData` and carries
/// the expected role colors, chamfered shapes, and flat elevation derived from
/// the resolved [AurisScheme].
void main() {
  final ThemeData theme = AurisTheme.light();
  final AurisScheme scheme = theme.extension<AurisScheme>()!;

  /// True when [shape] is an [AurisChamferBorder] (the chamfered geometry).
  bool isBeveled(ShapeBorder? shape) => shape is AurisChamferBorder;

  group('surface & overlay themes', () {
    test('all surface/overlay component themes are populated', () {
      expect(theme.cardTheme, isNotNull);
      expect(theme.dialogTheme, isNotNull);
      expect(theme.snackBarTheme, isNotNull);
      expect(theme.bottomSheetTheme, isNotNull);
      expect(theme.drawerTheme, isNotNull);
      expect(theme.tooltipTheme, isNotNull);
      expect(theme.popupMenuTheme, isNotNull);
    });

    test('Card is beveled, flat, on the panel surface', () {
      expect(isBeveled(theme.cardTheme.shape), isTrue);
      expect(theme.cardTheme.elevation, 0);
      expect(theme.cardTheme.color, scheme.surfacePanel);
      expect(theme.cardTheme.surfaceTintColor, Colors.transparent);
    });

    test('Dialog is beveled, flat, on the panel surface', () {
      expect(isBeveled(theme.dialogTheme.shape), isTrue);
      expect(theme.dialogTheme.elevation, 0);
      expect(theme.dialogTheme.backgroundColor, scheme.surfacePanel);
    });

    test('SnackBar is beveled, flat, gold action on the inset surface', () {
      expect(isBeveled(theme.snackBarTheme.shape), isTrue);
      expect(theme.snackBarTheme.elevation, 0);
      expect(theme.snackBarTheme.backgroundColor, scheme.surfaceInset);
      expect(theme.snackBarTheme.actionTextColor, scheme.primaryActive);
    });

    test('BottomSheet is beveled and flat', () {
      expect(isBeveled(theme.bottomSheetTheme.shape), isTrue);
      expect(theme.bottomSheetTheme.elevation, 0);
      expect(theme.bottomSheetTheme.modalElevation, 0);
      expect(theme.bottomSheetTheme.backgroundColor, scheme.surfacePanel);
    });

    test('Drawer is beveled, flat, on the panel surface', () {
      expect(isBeveled(theme.drawerTheme.shape), isTrue);
      expect(theme.drawerTheme.elevation, 0);
      expect(theme.drawerTheme.backgroundColor, scheme.surfacePanel);
    });

    test('Tooltip draws on the inset surface with no Material shadow', () {
      final BoxDecoration decoration =
          theme.tooltipTheme.decoration! as BoxDecoration;
      expect(decoration.color, scheme.surfaceInset);
      expect(decoration.boxShadow, anyOf(isNull, isEmpty));
    });

    test('PopupMenu is beveled, flat, on the panel surface', () {
      expect(isBeveled(theme.popupMenuTheme.shape), isTrue);
      expect(theme.popupMenuTheme.elevation, 0);
      expect(theme.popupMenuTheme.color, scheme.surfacePanel);
    });
  });

  group('navigation themes', () {
    test('all navigation component themes are populated', () {
      expect(theme.appBarTheme, isNotNull);
      expect(theme.navigationBarTheme, isNotNull);
      expect(theme.navigationRailTheme, isNotNull);
      expect(theme.tabBarTheme, isNotNull);
    });

    test('AppBar is flat on the panel surface', () {
      expect(theme.appBarTheme.elevation, 0);
      expect(theme.appBarTheme.scrolledUnderElevation, 0);
      expect(theme.appBarTheme.backgroundColor, scheme.surfacePanel);
      expect(theme.appBarTheme.surfaceTintColor, Colors.transparent);
    });

    test('NavigationBar is flat with a beveled selection indicator', () {
      expect(theme.navigationBarTheme.elevation, 0);
      expect(theme.navigationBarTheme.backgroundColor, scheme.surfacePanel);
      expect(isBeveled(theme.navigationBarTheme.indicatorShape), isTrue);
    });

    test('NavigationBar selected label uses the primary role', () {
      final TextStyle? selected = theme.navigationBarTheme.labelTextStyle!
          .resolve(<WidgetState>{WidgetState.selected});
      expect(selected!.color, scheme.primaryActive);
    });

    test('NavigationRail is flat with a beveled indicator', () {
      expect(theme.navigationRailTheme.elevation, 0);
      expect(isBeveled(theme.navigationRailTheme.indicatorShape), isTrue);
      expect(
        theme.navigationRailTheme.selectedLabelTextStyle!.color,
        scheme.primaryActive,
      );
    });

    test('TabBar uses the gold indicator and dim unselected labels', () {
      expect(theme.tabBarTheme.indicatorColor, scheme.primaryActive);
      expect(theme.tabBarTheme.labelColor, scheme.primaryActive);
      expect(theme.tabBarTheme.unselectedLabelColor, scheme.textMid);
      expect(theme.tabBarTheme.splashFactory, NoSplash.splashFactory);
    });
  });

  group('data & feedback themes', () {
    test('all data/feedback component themes are populated', () {
      expect(theme.dataTableTheme, isNotNull);
      expect(theme.listTileTheme, isNotNull);
      expect(theme.expansionTileTheme, isNotNull);
      expect(theme.progressIndicatorTheme, isNotNull);
      expect(theme.dividerTheme, isNotNull);
      expect(theme.badgeTheme, isNotNull);
      expect(theme.searchBarTheme, isNotNull);
      expect(theme.searchViewTheme, isNotNull);
    });

    test('DataTable selected row tints with the primary role', () {
      final Color? selected = theme.dataTableTheme.dataRowColor!
          .resolve(<WidgetState>{WidgetState.selected});
      expect(selected, isNotNull);
      expect(selected!.r, closeTo(scheme.primaryActive.r, 0.001));
    });

    test('ListTile is beveled and selects with the primary role', () {
      expect(isBeveled(theme.listTileTheme.shape), isTrue);
      expect(theme.listTileTheme.selectedColor, scheme.primaryActive);
    });

    test('ExpansionTile is beveled with a gold expanded icon', () {
      expect(isBeveled(theme.expansionTileTheme.shape), isTrue);
      expect(theme.expansionTileTheme.iconColor, scheme.primaryActive);
    });

    test('ProgressIndicator uses the primary value on the inset track', () {
      expect(theme.progressIndicatorTheme.color, scheme.primaryActive);
      expect(
        theme.progressIndicatorTheme.linearTrackColor,
        scheme.surfaceInset,
      );
      expect(theme.progressIndicatorTheme.borderRadius, isNotNull);
    });

    test('Divider uses the resting border color', () {
      expect(theme.dividerTheme.color, scheme.borderResting);
    });

    test('Badge uses the primary fill and near-black label', () {
      expect(theme.badgeTheme.backgroundColor, scheme.primaryActive);
      expect(theme.badgeTheme.textColor, scheme.onPrimary);
    });

    test('SearchBar is beveled, flat, on the inset surface', () {
      expect(
        isBeveled(theme.searchBarTheme.shape!.resolve(<WidgetState>{})),
        isTrue,
      );
      expect(
        theme.searchBarTheme.elevation!.resolve(<WidgetState>{}),
        0,
      );
      expect(
        theme.searchBarTheme.backgroundColor!.resolve(<WidgetState>{}),
        scheme.surfaceInset,
      );
    });

    test('SearchView is beveled, flat, on the panel surface', () {
      expect(isBeveled(theme.searchViewTheme.shape), isTrue);
      expect(theme.searchViewTheme.elevation, 0);
      expect(theme.searchViewTheme.backgroundColor, scheme.surfacePanel);
    });

    test('Stepper colors flow from the ColorScheme primary / error roles', () {
      // Stepper has no ThemeData; it reads the ColorScheme, which is derived
      // from the resolved scheme (§spec:theme-layer "Stepper note").
      expect(theme.colorScheme.primary, scheme.primaryActive);
      expect(theme.colorScheme.error, scheme.dangerBright);
    });
  });

  group('accent override re-skins the new component themes', () {
    test('a non-default accent flows into card / nav / data roles', () {
      const Color accent = Color(0xFF00FF99);
      final ThemeData themed = AurisTheme.light(accent: accent);
      // The light override is contrast-darkened; the component themes carry the
      // resolved ramp, not the raw bright accent.
      final Color active = themed.extension<AurisScheme>()!.primaryActive;
      expect(active, isNot(accent));
      expect(themed.tabBarTheme.indicatorColor, active);
      expect(themed.badgeTheme.backgroundColor, active);
      expect(themed.listTileTheme.selectedColor, active);
    });
  });
}
