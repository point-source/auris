import 'dart:math' as math;

import 'package:auris/auris.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Permanent WCAG AA contrast audit for the resolved [AurisScheme]
/// (§spec:accessibility, §road:contrast-and-focus).
///
/// Implements the WCAG 2.x relative-luminance + contrast-ratio formulae and
/// asserts every token pairing used in a PRIMARY text or interactive-control
/// role clears its AA threshold against each surface it can sit on:
///
/// - normal text >= 4.5:1
/// - large text (>=18px, or >=14px bold) and UI component boundaries >= 3:1
///
/// This locks the audit so a regression (e.g. a future selected-state going
/// gold-on-gold, or a dim token creeping into a primary role) fails CI. The
/// intentionally-dim DECORATIVE tokens (`textDim`, the resting/hover borders)
/// are asserted to be BELOW AA on purpose, so their decorative-only status is
/// itself a tested contract — brightening them silently would also fail.
void main() {
  // sRGB channel linearization (WCAG).
  double linearize(double channel) {
    return channel <= 0.03928
        ? channel / 12.92
        : math.pow((channel + 0.055) / 1.055, 2.4).toDouble();
  }

  // WCAG relative luminance of an opaque color.
  double luminance(Color c) {
    return 0.2126 * linearize(c.r) +
        0.7152 * linearize(c.g) +
        0.0722 * linearize(c.b);
  }

  // WCAG contrast ratio of [fg] (composited over [bg] if translucent) on [bg].
  double contrast(Color fg, Color bg) {
    final Color solid = fg.a >= 1.0 ? fg : Color.alphaBlend(fg, bg);
    final double l1 = luminance(solid);
    final double l2 = luminance(bg);
    final double hi = math.max(l1, l2);
    final double lo = math.min(l1, l2);
    return (hi + 0.05) / (lo + 0.05);
  }

  const double aaNormal = 4.5;
  const double aaLargeOrBoundary = 3.0;

  final AurisScheme scheme =
      AurisTheme.light().extension<AurisScheme>()!;

  // The three surfaces a primary foreground can be drawn on.
  final Map<String, Color> surfaces = <String, Color>{
    'page (void_)': scheme.surfacePage,
    'panel': scheme.surfacePanel,
    'inset': scheme.surfaceInset,
  };

  void expectAA(
    String label,
    Color fg,
    Color bg, {
    double threshold = aaNormal,
  }) {
    final double ratio = contrast(fg, bg);
    expect(
      ratio,
      greaterThanOrEqualTo(threshold),
      reason: '$label = ${ratio.toStringAsFixed(2)}:1, '
          'below the $threshold:1 AA threshold',
    );
  }

  group('Primary readable text meets AA on every surface', () {
    surfaces.forEach((String name, Color bg) {
      test('textBright on $name', () {
        expectAA('textBright on $name', scheme.textBright, bg);
      });
      test('textMid (body copy) on $name', () {
        expectAA('textMid on $name', scheme.textMid, bg);
      });
    });
  });

  group('Primary control labels (gold ramp) meet AA on every surface', () {
    surfaces.forEach((String name, Color bg) {
      test('primaryActive on $name', () {
        expectAA('primaryActive on $name', scheme.primaryActive, bg);
      });
      test('primaryDim on $name', () {
        expectAA('primaryDim on $name', scheme.primaryDim, bg);
      });
      test('primaryHighlight on $name', () {
        expectAA('primaryHighlight on $name', scheme.primaryHighlight, bg);
      });
    });
  });

  group('onPrimary clears AA on every rung of the gold fill', () {
    test('onPrimary on primaryActive (gold fill)', () {
      expectAA(
        'onPrimary on primaryActive',
        scheme.onPrimary,
        scheme.primaryActive,
      );
    });
    test('onPrimary on primaryDim (amber fill)', () {
      expectAA('onPrimary on primaryDim', scheme.onPrimary, scheme.primaryDim);
    });
    test('onPrimary on primaryHighlight (bright fill)', () {
      expectAA(
        'onPrimary on primaryHighlight',
        scheme.onPrimary,
        scheme.primaryHighlight,
      );
    });
  });

  group('Semantic status TEXT meets AA on every surface', () {
    surfaces.forEach((String name, Color bg) {
      test('dangerBright (error text) on $name', () {
        expectAA('dangerBright on $name', scheme.dangerBright, bg);
      });
      test('successBright (success text) on $name', () {
        expectAA('successBright on $name', scheme.successBright, bg);
      });
    });
  });

  group('Secondary (slate) accent text meets AA on every surface', () {
    surfaces.forEach((String name, Color bg) {
      test('secondary on $name', () {
        expectAA('secondary on $name', scheme.secondary, bg);
      });
    });
  });

  group('Error boundary (danger outline) meets the 3:1 boundary threshold', () {
    test('danger outline on page', () {
      expectAA(
        'danger on page',
        scheme.danger,
        scheme.surfacePage,
        threshold: aaLargeOrBoundary,
      );
    });
  });

  group('Decorative-only tokens are intentionally below AA (locked contract)',
      () {
    // These tokens are documented decorative-only (§spec:accessibility); they
    // must NOT be used for primary content. Asserting they are below AA locks
    // that intent — if someone "fixes" them by brightening they break this
    // contract test and must instead re-evaluate the role.
    surfaces.forEach((String name, Color bg) {
      test('textDim stays decorative (below AA) on $name', () {
        expect(
          contrast(scheme.textDim, bg),
          lessThan(aaNormal),
          reason: 'textDim is decorative-only; if it now clears AA, confirm '
              'it is not being promoted to a primary text role.',
        );
      });
    });

    test('resting/hover borders are supplementary (below the 3:1 boundary '
        'threshold on page)', () {
      expect(
        contrast(scheme.borderBright, scheme.surfacePage),
        lessThan(aaLargeOrBoundary),
        reason: 'borderBright is a supplementary outline, not the sole control '
            'affordance; the gold focus ring + inset fill carry identification.',
      );
    });
  });

  group('WCAG formula self-check', () {
    test('black-on-white is 21:1 and identical colors are 1:1', () {
      expect(
        contrast(const Color(0xFF000000), const Color(0xFFFFFFFF)),
        closeTo(21.0, 0.01),
      );
      expect(
        contrast(const Color(0xFF808080), const Color(0xFF808080)),
        closeTo(1.0, 0.001),
      );
    });
  });
}
