import 'package:auris/auris.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Regression tests for visual-contrast and geometry fixes reported from the
/// showcase. Each locks a specific bug so it cannot silently return:
///
/// - The gold-filled selected SegmentedButton segment must use a near-black
///   (onPrimary) label, not gold-on-gold.
/// - The checkbox chamfer must use the extra-small cut so it does not read as a
///   diamond on its ~18px box.
/// - DropdownMenu rows (MenuButton) must be themed (textMid resting,
///   textBright on hover) so the popup is not unstyled.
/// - The selected FilterChip label must resolve to near-black on its gold fill
///   (FilterChip keeps using labelStyle when selected, unlike ChoiceChip).
void main() {
  final ThemeData theme = AurisTheme.light();
  final AurisScheme scheme = theme.extension<AurisScheme>()!;

  group('SegmentedButton selected-label contrast', () {
    test(
      'selected foreground is onPrimary, unselected is the gold primary',
      () {
        final WidgetStateProperty<Color?> fg =
            theme.segmentedButtonTheme.style!.foregroundColor!;
        expect(
          fg.resolve(<WidgetState>{WidgetState.selected}),
          scheme.onPrimary,
          reason: 'gold-filled selected segment needs near-black text',
        );
        expect(fg.resolve(<WidgetState>{}), scheme.primaryActive);
      },
    );
  });

  group('Checkbox chamfer weight', () {
    test('checkbox uses the extra-small bevel, not small', () {
      final OutlinedBorder? shape = theme.checkboxTheme.shape;
      expect(shape, isA<AurisChamferBorder>());
      expect((shape! as AurisChamferBorder).cut, scheme.bevel.xs);
      expect((shape as AurisChamferBorder).cut, lessThan(scheme.bevel.sm));
    });
  });

  group('DropdownMenu rows are themed', () {
    test('menuButton theme is present and state-resolves its foreground', () {
      final ButtonStyle? style = theme.menuButtonTheme.style;
      expect(style, isNotNull);
      final WidgetStateProperty<Color?> fg = style!.foregroundColor!;
      expect(fg.resolve(<WidgetState>{}), scheme.textMid);
      expect(fg.resolve(<WidgetState>{WidgetState.hovered}), scheme.textBright);
    });
  });

  group('Chip selected-label contrast', () {
    test('label color resolves to onPrimary when selected, gold otherwise', () {
      final Color? color = theme.chipTheme.labelStyle?.color;
      expect(color, isA<WidgetStateColor>());
      final WidgetStateColor resolvable = color! as WidgetStateColor;
      expect(
        resolvable.resolve(<WidgetState>{WidgetState.selected}),
        scheme.onPrimary,
        reason: 'solid gold-filled selected chip needs near-black text',
      );
      expect(resolvable.resolve(<WidgetState>{}), scheme.primaryActive);
    });
  });
}
