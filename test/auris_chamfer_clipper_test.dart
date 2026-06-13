import 'dart:ui' as ui;

import 'package:auris/auris.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Geometry tests for [ChamferClipper] — the widget-layer clip that MUST cut
/// the SAME two corners as [AurisChamferBorder] (top-left + bottom-right;
/// top-right + bottom-left square), since both build from the shared
/// [aurisChamferPath] (§spec:design-tokens "Shape").
void main() {
  // A 100x60 box with a 10px cut. Corners:
  //   TL (0, 0)    — CUT
  //   TR (100, 0)  — SQUARE
  //   BL (0, 60)   — SQUARE
  //   BR (100, 60) — CUT
  const Size size = Size(100, 60);
  const Rect rect = Rect.fromLTWH(0, 0, 100, 60);
  const double cut = 10;
  const ChamferClipper clipper = ChamferClipper(cut: cut);

  group('getClip cuts only top-left and bottom-right', () {
    final ui.Path path = clipper.getClip(size);

    test('top-left corner is cut (point just inside is OUTSIDE)', () {
      expect(path.contains(const Offset(2, 2)), isFalse);
    });

    test('bottom-right corner is cut (point just inside is OUTSIDE)', () {
      expect(path.contains(const Offset(98, 58)), isFalse);
    });

    test('top-right corner stays square (point just inside is INSIDE)', () {
      expect(path.contains(const Offset(98, 2)), isTrue);
    });

    test('bottom-left corner stays square (point just inside is INSIDE)', () {
      expect(path.contains(const Offset(2, 58)), isTrue);
    });

    test('bounds span the full box (cuts are corner notches only)', () {
      expect(path.getBounds(), rect);
    });
  });

  group('shares the silhouette with AurisChamferBorder exactly', () {
    test('clip and border outer path agree at every probe corner', () {
      const AurisChamferBorder border = AurisChamferBorder(cut: cut);
      final ui.Path clip = clipper.getClip(size);
      final ui.Path outline = border.getOuterPath(rect);
      for (final Offset p in <Offset>[
        const Offset(2, 2), // TL cut
        const Offset(98, 58), // BR cut
        const Offset(98, 2), // TR square
        const Offset(2, 58), // BL square
        const Offset(50, 30), // centre
        const Offset(1, 1), // just outside the TL slant
      ]) {
        expect(
          clip.contains(p),
          outline.contains(p),
          reason: 'clip and border disagree at $p',
        );
      }
    });
  });

  group('cut is clamped to half the shorter side', () {
    test('an over-large cut never self-crosses', () {
      const ChamferClipper huge = ChamferClipper(cut: 999);
      final ui.Path path = huge.getClip(size);
      expect(path.getBounds(), rect);
      expect(path.contains(const Offset(50, 30)), isTrue);
    });

    test('a zero cut yields the full rect (all corners square)', () {
      const ChamferClipper none = ChamferClipper();
      final ui.Path path = none.getClip(size);
      expect(path.contains(const Offset(2, 2)), isTrue);
      expect(path.contains(const Offset(98, 58)), isTrue);
    });
  });

  group('shouldReclip', () {
    test('reclips only when the cut changes', () {
      expect(clipper.shouldReclip(const ChamferClipper(cut: cut)), isFalse);
      expect(clipper.shouldReclip(const ChamferClipper(cut: 14)), isTrue);
    });
  });
}
