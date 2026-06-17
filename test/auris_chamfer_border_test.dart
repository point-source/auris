import 'dart:ui' as ui;

import 'package:auris/auris.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Geometry, scale, lerp, and equality tests for [AurisChamferBorder] — the
/// single owner of the signature asymmetric chamfer (top-left + bottom-right
/// cut; top-right + bottom-left square) (§spec:design-tokens "Shape").
void main() {
  // A 100x60 rect with a 10px cut. The corners are:
  //   TL (0, 0)    — CUT
  //   TR (100, 0)  — SQUARE
  //   BL (0, 60)   — SQUARE
  //   BR (100, 60) — CUT
  const Rect rect = Rect.fromLTWH(0, 0, 100, 60);
  const double cut = 10;
  const AurisChamferBorder border = AurisChamferBorder(cut: cut);

  group('getOuterPath cuts only top-left and bottom-right', () {
    final ui.Path path = border.getOuterPath(rect);

    // A point just inside each corner (2px diagonally in from the corner).
    // Cut corners exclude this point; square corners include it.
    test('top-left corner is cut (point just inside is OUTSIDE the path)', () {
      expect(path.contains(const Offset(2, 2)), isFalse);
    });

    test(
      'bottom-right corner is cut (point just inside is OUTSIDE the path)',
      () {
        expect(path.contains(const Offset(98, 58)), isFalse);
      },
    );

    test('top-right corner stays square (point just inside is INSIDE)', () {
      expect(path.contains(const Offset(98, 2)), isTrue);
    });

    test('bottom-left corner stays square (point just inside is INSIDE)', () {
      expect(path.contains(const Offset(2, 58)), isTrue);
    });

    test('the chamfer vertices sit exactly on the cut diagonals', () {
      // The two slant vertices at the top-left cut and the centre are inside.
      expect(path.contains(const Offset(50, 30)), isTrue);
      // Just outside the TL slant (above the diagonal line) is excluded.
      expect(path.contains(const Offset(1, 1)), isFalse);
    });

    test('bounds still span the full rect (cuts are corner notches only)', () {
      expect(path.getBounds(), rect);
    });
  });

  group('cut is clamped to half the shorter side', () {
    test('an over-large cut never self-crosses', () {
      // Cut 999 on a 60-tall rect clamps to 30; the path is still a valid,
      // bounded polygon spanning the rect.
      const AurisChamferBorder huge = AurisChamferBorder(cut: 999);
      final ui.Path path = huge.getOuterPath(rect);
      expect(path.getBounds(), rect);
      // Centre is still inside.
      expect(path.contains(const Offset(50, 30)), isTrue);
    });
  });

  group('getInnerPath insets by the side width', () {
    test('inner path bounds shrink by the stroke width on each edge', () {
      const AurisChamferBorder withSide = AurisChamferBorder(
        cut: cut,
        side: BorderSide(width: 4),
      );
      final ui.Path inner = withSide.getInnerPath(rect);
      expect(inner.getBounds(), const Rect.fromLTWH(4, 4, 92, 52));
    });
  });

  group('scale', () {
    test('scales both the cut and the side', () {
      const AurisChamferBorder b = AurisChamferBorder(
        cut: 10,
        side: BorderSide(width: 2),
      );
      final AurisChamferBorder scaled = b.scale(2);
      expect(scaled.cut, 20);
      expect(scaled.side.width, 4);
    });
  });

  group('lerp', () {
    const AurisChamferBorder a = AurisChamferBorder(
      cut: 0,
      side: BorderSide(width: 0),
    );
    const AurisChamferBorder b = AurisChamferBorder(
      cut: 20,
      side: BorderSide(width: 4),
    );

    test('lerpFrom interpolates cut and side at the midpoint', () {
      final ShapeBorder? mid = b.lerpFrom(a, 0.5);
      expect(mid, isA<AurisChamferBorder>());
      expect((mid! as AurisChamferBorder).cut, 10);
      expect((mid as AurisChamferBorder).side.width, 2);
    });

    test('lerpTo interpolates cut and side at the midpoint', () {
      final ShapeBorder? mid = a.lerpTo(b, 0.5);
      expect(mid, isA<AurisChamferBorder>());
      expect((mid! as AurisChamferBorder).cut, 10);
    });

    test('lerp endpoints reproduce the inputs', () {
      expect(b.lerpFrom(a, 0), a);
      expect(b.lerpFrom(a, 1), b);
    });

    test('lerp against a non-chamfer border falls back (returns null mid)', () {
      // OutlinedBorder.lerp between unrelated types yields null at the
      // midpoint when neither side knows how to interpolate the other.
      final ShapeBorder? r = border.lerpFrom(
        const RoundedRectangleBorder(),
        0.5,
      );
      expect(r, isNull);
    });
  });

  group('copyWith and equality', () {
    test('copyWith overrides only the given fields', () {
      const AurisChamferBorder b = AurisChamferBorder(cut: 10);
      final AurisChamferBorder c = b.copyWith(cut: 14);
      expect(c.cut, 14);
      expect(c.side, b.side);
    });

    test('== and hashCode are value-based', () {
      const AurisChamferBorder x = AurisChamferBorder(cut: 10);
      const AurisChamferBorder y = AurisChamferBorder(cut: 10);
      const AurisChamferBorder z = AurisChamferBorder(cut: 14);
      expect(x, y);
      expect(x.hashCode, y.hashCode);
      expect(x, isNot(z));
    });
  });

  group('AurisChamferInputBorder shares the silhouette', () {
    const AurisChamferInputBorder input = AurisChamferInputBorder(cut: cut);
    final ui.Path path = input.getOuterPath(rect);

    test('is an outline border', () {
      expect(input.isOutline, isTrue);
    });

    test('cuts only top-left and bottom-right', () {
      expect(path.contains(const Offset(2, 2)), isFalse);
      expect(path.contains(const Offset(98, 58)), isFalse);
      expect(path.contains(const Offset(98, 2)), isTrue);
      expect(path.contains(const Offset(2, 58)), isTrue);
    });

    test('scale and equality behave by value', () {
      expect(input.scale(2).cut, 20);
      expect(
        const AurisChamferInputBorder(cut: cut),
        const AurisChamferInputBorder(cut: cut),
      );
    });
  });
}
