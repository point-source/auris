import 'dart:math' as math;

import 'package:auris/auris.dart';
import 'package:auris/auris_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Customization-override propagation tests (§spec:customization,
/// §road:customization-api).
///
/// Proves that the three overrides on [AurisScheme.resolve] /
/// [AurisTheme.light] — `accent`, `bevelScale`, `glowScale` — flow through the
/// single resolved [AurisScheme] to the derived `ColorScheme` and the Material
/// component themes (and, by reading the same extension, to the custom widgets).
/// Flipping the accent here doubles as a hardcoded-color audit: any component
/// still baking the gold ramp would fail these assertions.
void main() {
  // A deliberately non-amber accent so a leak (a baked-in gold) stands out.
  const Color kAccent = Color(0xFF35E0C0); // teal

  group('AurisScheme.resolve overrides', () {
    test('accent replaces the active rung and derives dim/highlight', () {
      final AurisScheme base = AurisScheme.resolve();
      final AurisScheme themed = AurisScheme.resolve(accent: kAccent);

      // The active rung is exactly the requested accent.
      expect(themed.primaryActive, kAccent);

      // Dim and highlight are derived (non-null) and differ from both the
      // default ramp and the flat accent.
      expect(themed.primaryDim, isNotNull);
      expect(themed.primaryHighlight, isNotNull);
      expect(themed.primaryDim, isNot(base.primaryDim));
      expect(themed.primaryHighlight, isNot(base.primaryHighlight));
      expect(themed.primaryDim, isNot(kAccent));
      expect(themed.primaryHighlight, isNot(kAccent));

      // The active-depth border-emphasis follows the accent too.
      expect(themed.depthActive.borderColor, kAccent);
    });

    test('bevelScale multiplies every bevel role', () {
      final AurisScheme base = AurisScheme.resolve();
      final AurisScheme bold = AurisScheme.resolve(bevelScale: 2.0);

      expect(bold.bevel.xs, closeTo(base.bevel.xs * 2, 1e-9));
      expect(bold.bevel.sm, closeTo(base.bevel.sm * 2, 1e-9));
      expect(bold.bevel.md, closeTo(base.bevel.md * 2, 1e-9));
      expect(bold.bevel.lg, closeTo(base.bevel.lg * 2, 1e-9));
      expect(bold.bevel.xl, closeTo(base.bevel.xl * 2, 1e-9));
    });

    test('glowScale scales glow alpha but holds blur + spread constant', () {
      final AurisScheme base = AurisScheme.resolve();
      final AurisScheme bold = AurisScheme.resolve(glowScale: 2.0);

      final BoxShadow baseGlow = base.depthActive.glow.single;
      final BoxShadow boldGlow = bold.depthActive.glow.single;

      // Alpha (intensity) grows with the factor…
      expect(
        boldGlow.color.a,
        closeTo((baseGlow.color.a * 2).clamp(0.0, 1.0), 1e-9),
      );

      // …but blur and spread are held constant so a stronger glow gets brighter,
      // not wider — it keeps hugging the element's shape.
      expect(boldGlow.blurRadius, closeTo(baseGlow.blurRadius, 1e-9));
      expect(boldGlow.spreadRadius, closeTo(baseGlow.spreadRadius, 1e-9));

      // The scheme also carries the raw factor for custom glows to honor.
      expect(bold.glowScale, 2.0);
      expect(base.glowScale, 1.0);
    });

    test('defaults reproduce the canonical look exactly', () {
      final AurisScheme base = AurisScheme.resolve();

      expect(base.primaryActive, AurisTokens.gold);
      expect(base.primaryDim, AurisTokens.amber);
      expect(base.primaryHighlight, AurisTokens.bright);

      expect(base.bevel.xs, AurisTokens.bevelXs);
      expect(base.bevel.sm, AurisTokens.bevelSm);
      expect(base.bevel.md, AurisTokens.bevelMd);
      expect(base.bevel.lg, AurisTokens.bevelLg);
      expect(base.bevel.xl, AurisTokens.bevelXl);

      expect(
        base.depthActive.glow.single.blurRadius,
        AurisTokens.glowActive.single.blurRadius,
      );
    });
  });

  group('AurisTheme.light propagates overrides through ThemeData', () {
    test('accent reaches colorScheme.primary and the attached extension', () {
      final ThemeData theme = AurisTheme.light(accent: kAccent);

      final AurisScheme? ext = theme.extension<AurisScheme>();
      expect(ext, isNotNull);
      // The light override is darkened for contrast (not used raw): a bright
      // accent would not clear AA on the light surface.
      expect(ext!.primaryActive, isNot(kAccent));
      expect(
        ext.primaryActive.computeLuminance(),
        lessThan(kAccent.computeLuminance()),
      );
      // The component color scheme tracks that same darkened ramp.
      expect(theme.colorScheme.primary, ext.primaryActive);
    });

    test(
        'accent reaches the primary-ramp component themes '
        '(filled button background + slider active track)', () {
      final ThemeData themed = AurisTheme.light(accent: kAccent);
      // The resolved (contrast-darkened) accent — neither the raw override nor
      // the default gold — is what the component themes must carry.
      final Color active = themed.extension<AurisScheme>()!.primaryActive;
      expect(active, isNot(kAccent));
      expect(active, isNot(AurisTokens.gold));

      // Filled button background resolves to the resolved accent ramp.
      final Color? buttonBg = themed.filledButtonTheme.style?.backgroundColor
          ?.resolve(<WidgetState>{});
      expect(buttonBg, active);

      // Slider active track / thumb resolve to the same ramp.
      expect(themed.sliderTheme.activeTrackColor, active);
      expect(themed.sliderTheme.thumbColor, active);

      // Progress indicator (data theme on the primary ramp) recolors as well.
      expect(themed.progressIndicatorTheme.color, active);
    });

    test('bevelScale reaches a component theme shape (chip border)', () {
      final ThemeData base = AurisTheme.light();
      final ThemeData bold = AurisTheme.light(bevelScale: 2.0);

      final ShapeBorder? baseShape = base.chipTheme.shape;
      final ShapeBorder? boldShape = bold.chipTheme.shape;
      expect(baseShape, isA<AurisChamferBorder>());
      expect(boldShape, isA<AurisChamferBorder>());
      expect(
        (boldShape! as AurisChamferBorder).cut,
        closeTo((baseShape! as AurisChamferBorder).cut * 2, 1e-9),
      );
    });

    test('defaults attach the canonical scheme', () {
      final ThemeData theme = AurisTheme.dark();
      expect(theme.colorScheme.primary, AurisTokens.gold);
      expect(theme.extension<AurisScheme>()!.bevel.md, AurisTokens.bevelMd);
    });
  });

  group('accent carries through to glow and text', () {
    test('the primary-ramp glow recolors to the accent, not amber', () {
      final AurisScheme base = AurisScheme.resolve();
      final AurisScheme themed = AurisScheme.resolve(accent: kAccent);

      // Default keeps the canonical amber active glow untouched.
      expect(base.depthActive.glow.first.color, AurisTokens.glowActive.first.color);

      // Under an accent the active glow takes the accent hue (alpha preserved),
      // so a teal element no longer wears an amber halo.
      final Color glowColor = themed.depthActive.glow.first.color;
      expect(glowColor.r, closeTo(kAccent.r, 1e-6));
      expect(glowColor.g, closeTo(kAccent.g, 1e-6));
      expect(glowColor.b, closeTo(kAccent.b, 1e-6));
      expect(glowColor.a, closeTo(AurisTokens.glowActive.first.color.a, 1e-6));
    });

    test('text tints toward the accent yet primary text stays WCAG AA', () {
      double lin(double c) =>
          c <= 0.03928 ? c / 12.92 : math.pow((c + 0.055) / 1.055, 2.4).toDouble();
      double lum(Color c) =>
          0.2126 * lin(c.r) + 0.7152 * lin(c.g) + 0.0722 * lin(c.b);
      double contrast(Color fg, Color bg) {
        final double hi = math.max(lum(fg), lum(bg));
        final double lo = math.min(lum(fg), lum(bg));
        return (hi + 0.05) / (lo + 0.05);
      }

      // A spread of accents, including the example's three alternates.
      const List<Color> accents = <Color>[
        Color(0xFF35E0C0), // teal
        Color(0xFFE048B0), // magenta
        Color(0xFF6AD050), // green
      ];
      final AurisScheme base = AurisScheme.resolve();
      for (final Color accent in accents) {
        final AurisScheme s = AurisScheme.resolve(accent: accent);
        // The cast actually shifts (cohesion): tinted bright text and the
        // neutral border role differ from the canonical warm tokens.
        expect(s.textBright, isNot(base.textBright));
        expect(s.borderBright, isNot(base.borderBright));
        // …but primary text still clears AA (4.5:1) on the page surface.
        expect(contrast(s.textBright, s.surfacePage), greaterThanOrEqualTo(4.5));
      }
    });

    // Guards the propagation invariant for a widget that synthesizes its OWN
    // glow outside the depth tokens (§spec:customization "Propagation
    // invariant"): the accent bar's glow must honor the glow override, not bake
    // a constant. This is the exact leak the invariant exists to prevent.
    testWidgets('a custom-shaped glow (notification bar) honors glowScale', (
      WidgetTester tester,
    ) async {
      Future<double> barGlowAlpha(double glowScale) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: AurisTheme.light(glowScale: glowScale),
            home: const Scaffold(
              body: AurisNotification(
                variant: AurisNotificationVariant.info,
                title: 'TEST',
              ),
            ),
          ),
        );
        // Let MaterialApp's implicit theme-change animation settle, else a
        // second call samples the previous theme mid-tween.
        await tester.pump(const Duration(milliseconds: 400));
        // Take the strongest glow alpha across the tree so the assertion does
        // not depend on which shadowed box is first in paint order.
        final double maxAlpha = tester
            .widgetList<DecoratedBox>(find.byType(DecoratedBox))
            .map((DecoratedBox b) => b.decoration)
            .whereType<BoxDecoration>()
            .expand((BoxDecoration d) => d.boxShadow ?? const <BoxShadow>[])
            .map((BoxShadow s) => s.color.a)
            .fold(0.0, (double m, double a) => a > m ? a : m);
        return maxAlpha;
      }

      final double dim = await barGlowAlpha(0.5);
      final double bright = await barGlowAlpha(2.0);
      expect(bright, greaterThan(dim));
    });
  });
}
