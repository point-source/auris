import 'package:auris/auris.dart';
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

    test('glowScale scales the depth glow blur radius', () {
      final AurisScheme base = AurisScheme.resolve();
      final AurisScheme bold = AurisScheme.resolve(glowScale: 2.0);

      final double baseBlur = base.depthActive.glow.single.blurRadius;
      final double boldBlur = bold.depthActive.glow.single.blurRadius;
      expect(boldBlur, closeTo(baseBlur * 2, 1e-9));

      // Spread scales too, and the subtle cue scales independently.
      expect(
        bold.depthActive.glow.single.spreadRadius,
        closeTo(base.depthActive.glow.single.spreadRadius * 2, 1e-9),
      );
      expect(
        bold.depthSubtle.glow.single.blurRadius,
        closeTo(base.depthSubtle.glow.single.blurRadius * 2, 1e-9),
      );
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

      expect(theme.colorScheme.primary, kAccent);

      final AurisScheme? ext = theme.extension<AurisScheme>();
      expect(ext, isNotNull);
      expect(ext!.primaryActive, kAccent);
    });

    test(
        'accent reaches the primary-ramp component themes '
        '(filled button background + slider active track)', () {
      final ThemeData themed = AurisTheme.light(accent: kAccent);

      // Filled button background resolves to the accent, not the default gold.
      final Color? buttonBg = themed.filledButtonTheme.style?.backgroundColor
          ?.resolve(<WidgetState>{});
      expect(buttonBg, kAccent);
      expect(buttonBg, isNot(AurisTokens.gold));

      // Slider active track / thumb resolve to the accent too.
      expect(themed.sliderTheme.activeTrackColor, kAccent);
      expect(themed.sliderTheme.thumbColor, kAccent);

      // Progress indicator (data theme on the primary ramp) recolors as well.
      expect(themed.progressIndicatorTheme.color, kAccent);
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
      final ThemeData theme = AurisTheme.light();
      expect(theme.colorScheme.primary, AurisTokens.gold);
      expect(theme.extension<AurisScheme>()!.bevel.md, AurisTokens.bevelMd);
    });
  });
}
