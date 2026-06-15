import 'package:auris/auris.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AurisTheme.light', () {
    test('builds a light ThemeData carrying an AurisScheme extension', () {
      final ThemeData theme = AurisTheme.light();

      expect(theme.brightness, Brightness.light);

      final AurisScheme? scheme = theme.extension<AurisScheme>();
      expect(scheme, isNotNull);
      expect(scheme!.brightness, Brightness.light);
    });

    test('derives the ColorScheme from the resolved scheme', () {
      final ThemeData theme = AurisTheme.light();
      final AurisScheme scheme = theme.extension<AurisScheme>()!;

      expect(theme.colorScheme.primary, scheme.primaryActive);
      expect(theme.colorScheme.surface, scheme.surfacePanel);
      // Depth is glow, not shadow: shadows are transparent.
      expect(theme.colorScheme.shadow, Colors.transparent);
      expect(theme.shadowColor, Colors.transparent);
    });

    test('populates the full TextTheme from the scheme', () {
      final ThemeData theme = AurisTheme.light();
      final TextTheme text = theme.textTheme;

      expect(text.displayLarge, isNotNull);
      expect(text.bodyMedium, isNotNull);
      expect(text.labelLarge, isNotNull);
      expect(text.displayLarge!.fontFamily, AurisTokens.fontDisplay);
      expect(text.bodyLarge!.fontFamily, AurisTokens.fontBody);
    });

    test('accent override recolors the primary ramp, darkened for contrast', () {
      const Color accent = Color(0xFF00FF99);
      final ThemeData theme = AurisTheme.light(accent: accent);
      final AurisScheme scheme = theme.extension<AurisScheme>()!;

      // A raw light accent is too bright to clear AA on the light surface, so
      // the override is darkened (same hue, lower lightness) rather than used
      // verbatim — the same contrast correction the canonical amber rung gets.
      expect(scheme.primaryActive, isNot(accent));
      expect(
        scheme.primaryActive.computeLuminance(),
        lessThan(accent.computeLuminance()),
      );
      expect(
        HSLColor.fromColor(scheme.primaryActive).hue,
        closeTo(HSLColor.fromColor(accent).hue, 1.0),
      );
      // The darkened ramp clears WCAG AA (4.5:1) against the panel surface.
      expect(
        _contrast(scheme.primaryActive, scheme.surfacePanel),
        greaterThanOrEqualTo(4.5),
      );
      // The component color scheme tracks the same darkened ramp.
      expect(theme.colorScheme.primary, scheme.primaryActive);
    });
  });

  group('AurisTheme.dark', () {
    test('builds the dark (amber-on-near-black) theme', () {
      final ThemeData theme = AurisTheme.dark();
      expect(theme.brightness, Brightness.dark);
      expect(theme.colorScheme.primary, AurisTokens.gold);
      expect(theme.scaffoldBackgroundColor, AurisTokens.void_);
    });
  });

  group('AurisTheme.light builds the light variant', () {
    test('is a light-brightness theme with light surfaces and dark text', () {
      final ThemeData theme = AurisTheme.light();
      final AurisScheme scheme = theme.extension<AurisScheme>()!;
      expect(theme.brightness, Brightness.light);
      expect(scheme.brightness, Brightness.light);
      // Page is light and text is dark (inverted from the dark variant).
      expect(scheme.surfacePage.computeLuminance(), greaterThan(0.5));
      expect(scheme.textBright.computeLuminance(), lessThan(0.2));
      // Depth on light is an amber glow (a brightened accent): warm, red ≥ green
      // ≫ blue, the kit's identity kept rather than swapped for another hue.
      final Color glowColor = scheme.depthActive.glow.first.color;
      expect(glowColor.r, greaterThan(glowColor.b));
      expect(glowColor.g, greaterThan(glowColor.b));
    });
  });

  group('AurisScheme.resolve', () {
    test('resolves the dark branch', () {
      final AurisScheme scheme =
          AurisScheme.resolve(brightness: Brightness.dark);
      expect(scheme.brightness, Brightness.dark);
      expect(scheme.surfacePage, AurisTokens.void_);
      expect(scheme.primaryActive, AurisTokens.gold);
    });

    test('resolves the light branch', () {
      final AurisScheme scheme =
          AurisScheme.resolve(brightness: Brightness.light);
      expect(scheme.brightness, Brightness.light);
      expect(scheme.surfacePage.computeLuminance(), greaterThan(0.5));
    });

    test('bevel and glow overrides scale the resolved roles', () {
      final AurisScheme scheme = AurisScheme.resolve(
        bevelScale: 2.0,
        glowScale: 2.0,
      );
      expect(scheme.bevel.md, AurisTokens.bevelMd * 2.0);
      // Glow intensity scales alpha (brighter), not blur (wider) — the blur is
      // held constant so the glow keeps hugging the element's shape.
      expect(
        scheme.depthActive.glow.first.color.a,
        (AurisTokens.glowActive.first.color.a * 2.0).clamp(0.0, 1.0),
      );
      expect(
        scheme.depthActive.glow.first.blurRadius,
        AurisTokens.glowActive.first.blurRadius,
      );
    });

    testWidgets('renders a Material widget that reads a scheme role color', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AurisTheme.light(),
          home: Builder(
            builder: (BuildContext context) {
              final AurisScheme scheme =
                  Theme.of(context).extension<AurisScheme>()!;
              return Scaffold(
                body: ColoredBox(color: scheme.surfacePanel),
              );
            },
          ),
        ),
      );

      expect(find.byType(ColoredBox), findsWidgets);
    });
  });
}

/// WCAG contrast ratio between [a] and [b], from their relative luminances.
double _contrast(Color a, Color b) {
  final double la = a.computeLuminance();
  final double lb = b.computeLuminance();
  final double hi = la > lb ? la : lb;
  final double lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}
