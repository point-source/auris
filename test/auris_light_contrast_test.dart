import 'dart:math' as math;

import 'package:auris/auris.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// WCAG AA contrast for the LIGHT variant (§req:success-criteria #5,
/// §spec:accessibility). Primary text, the active control color, and semantic
/// status text must clear 4.5:1 against their surfaces. Intentionally dim/
/// inactive roles (textDim, the dim accent rung) are decorative and exempt,
/// matching the dark-variant policy.
void main() {
  double linearize(double c) =>
      c <= 0.03928 ? c / 12.92 : math.pow((c + 0.055) / 1.055, 2.4).toDouble();
  double luminance(Color c) =>
      0.2126 * linearize(c.r) +
      0.7152 * linearize(c.g) +
      0.0722 * linearize(c.b);
  double contrast(Color fg, Color bg) {
    final Color solid = fg.a >= 1.0 ? fg : Color.alphaBlend(fg, bg);
    final double hi = math.max(luminance(solid), luminance(bg));
    final double lo = math.min(luminance(solid), luminance(bg));
    return (hi + 0.05) / (lo + 0.05);
  }

  const double aaNormal = 4.5;
  final AurisScheme scheme = AurisTheme.light().extension<AurisScheme>()!;

  final Map<String, Color> surfaces = <String, Color>{
    'page': scheme.surfacePage,
    'panel': scheme.surfacePanel,
    'inset': scheme.surfaceInset,
  };

  void expectAA(String label, Color fg, Color bg) {
    final double ratio = contrast(fg, bg);
    expect(
      ratio,
      greaterThanOrEqualTo(aaNormal),
      reason: '$label = ${ratio.toStringAsFixed(2)}:1, below $aaNormal:1',
    );
  }

  test('the light variant is actually light', () {
    expect(scheme.brightness, Brightness.light);
    expect(luminance(scheme.surfacePage), greaterThan(0.5));
    expect(luminance(scheme.textBright), lessThan(0.2));
  });

  group('primary text meets AA on every surface', () {
    surfaces.forEach((String name, Color bg) {
      test(
        'textBright on $name',
        () => expectAA('textBright/$name', scheme.textBright, bg),
      );
      test(
        'textMid on $name',
        () => expectAA('textMid/$name', scheme.textMid, bg),
      );
    });
  });

  group('the active control color meets AA on every surface', () {
    surfaces.forEach((String name, Color bg) {
      test('primaryActive on $name', () {
        expectAA('primaryActive/$name', scheme.primaryActive, bg);
      });
    });
  });

  test('onPrimary clears AA on the accent fill', () {
    expectAA('onPrimary/primaryActive', scheme.onPrimary, scheme.primaryActive);
  });

  group('semantic status text meets AA', () {
    for (final MapEntry<String, Color> s in surfaces.entries) {
      if (s.key == 'inset') continue;
      test('dangerBright on ${s.key}', () {
        expectAA('dangerBright/${s.key}', scheme.dangerBright, s.value);
      });
      test('successBright on ${s.key}', () {
        expectAA('successBright/${s.key}', scheme.successBright, s.value);
      });
    }
  });
}
