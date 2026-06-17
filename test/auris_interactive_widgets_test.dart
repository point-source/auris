import 'package:auris/auris.dart';
import 'package:auris/auris_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Widget tests for the interactive HUD widgets (§spec:custom-widgets):
/// AurisSwitch, AurisProgressBar, AurisTerminal, AurisStepIndicator, and
/// AurisSelect. Each renders, composes from the chamfered primitive, reads its
/// design values from the resolved [AurisScheme], and respects reduced motion
/// where it animates.
void main() {
  final ThemeData theme = AurisTheme.light();
  final AurisScheme scheme = theme.extension<AurisScheme>()!;

  Widget host(Widget child, {bool disableAnimations = false}) {
    return MaterialApp(
      theme: theme,
      home: Builder(
        builder: (BuildContext context) {
          final Widget scaffold = Scaffold(body: Center(child: child));
          if (!disableAnimations) {
            return scaffold;
          }
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(disableAnimations: true),
            child: scaffold,
          );
        },
      ),
    );
  }

  group('AurisSwitch', () {
    testWidgets('toggles via tap and reports the new value', (
      WidgetTester tester,
    ) async {
      bool value = false;
      await tester.pumpWidget(
        host(
          StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return AurisSwitch(
                value: value,
                label: 'PWR',
                onChanged: (bool v) => setState(() => value = v),
              );
            },
          ),
        ),
      );
      expect(value, isFalse);
      await tester.tap(find.byType(AurisSwitch));
      await tester.pumpAndSettle();
      expect(value, isTrue);
    });

    testWidgets('renders label and active status label', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(
          AurisSwitch(
            value: true,
            label: 'REACTOR',
            statusLabels: const ('OFFLINE', 'ONLINE'),
            onChanged: (_) {},
          ),
        ),
      );
      expect(find.text('REACTOR'), findsOneWidget);
      expect(find.text('ONLINE'), findsOneWidget);
    });

    testWidgets('disabled (null onChanged) renders at half opacity', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(const AurisSwitch(value: true, onChanged: null)),
      );
      final Opacity opacity = tester.widget<Opacity>(
        find
            .descendant(
              of: find.byType(AurisSwitch),
              matching: find.byType(Opacity),
            )
            .first,
      );
      expect(opacity.opacity, 0.5);
    });

    testWidgets('respects reduced motion: no running animation after toggle', (
      WidgetTester tester,
    ) async {
      bool value = false;
      await tester.pumpWidget(
        host(
          StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return AurisSwitch(
                value: value,
                onChanged: (bool v) => setState(() => value = v),
              );
            },
          ),
          disableAnimations: true,
        ),
      );
      await tester.tap(find.byType(AurisSwitch));
      await tester.pump();
      // Under reduced motion the controller jumps to the end state, so no
      // animation should be in flight.
      expect(tester.hasRunningAnimations, isFalse);
      expect(value, isTrue);
    });
  });

  group('AurisProgressBar', () {
    // A filled cell is a slant-clipped ColoredBox carrying the variant color
    // (the leading cell at full strength, trailing filled cells dimmed);
    // unfilled cells use the dim border color.
    int filledSegments(WidgetTester tester) {
      final Color full = scheme.primaryActive;
      final Color dimmed = scheme.primaryActive.withValues(alpha: 0.72);
      return tester
          .widgetList<DecoratedBox>(find.byType(DecoratedBox))
          .map((DecoratedBox b) => b.decoration)
          .whereType<ShapeDecoration>()
          .where((ShapeDecoration d) => d.shape is AurisSlantBorder)
          .where((ShapeDecoration d) => d.color == full || d.color == dimmed)
          .length;
    }

    testWidgets('fills the correct number of segments', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(
          const SizedBox(
            width: 300,
            child: AurisProgressBar(value: 0.5, segments: 10),
          ),
        ),
      );
      // value 0.5 of 10 segments -> 5 filled cells.
      expect(filledSegments(tester), 5);
    });

    testWidgets('value 1.0 fills every segment', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(
          const SizedBox(
            width: 300,
            child: AurisProgressBar(value: 1.0, segments: 8),
          ),
        ),
      );
      expect(filledSegments(tester), 8);
    });

    testWidgets('.animated tweens between values over time', (
      WidgetTester tester,
    ) async {
      double value = 0.2;
      await tester.pumpWidget(
        host(
          StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                children: <Widget>[
                  SizedBox(
                    width: 300,
                    child: AurisProgressBar.animated(
                      value: value,
                      segments: 10,
                    ),
                  ),
                  TextButton(
                    onPressed: () => setState(() => value = 0.9),
                    child: const Text('GO'),
                  ),
                ],
              );
            },
          ),
        ),
      );
      await tester.tap(find.text('GO'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      expect(tester.hasRunningAnimations, isTrue);
      await tester.pumpAndSettle();
      expect(filledSegments(tester), 9);
    });

    testWidgets(
      '.animated snaps to the end state with no running animation under '
      'reduced motion',
      (WidgetTester tester) async {
        double value = 0.2;
        await tester.pumpWidget(
          host(
            disableAnimations: true,
            StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Column(
                  children: <Widget>[
                    SizedBox(
                      width: 300,
                      child: AurisProgressBar.animated(
                        value: value,
                        segments: 10,
                      ),
                    ),
                    TextButton(
                      onPressed: () => setState(() => value = 0.9),
                      child: const Text('GO'),
                    ),
                  ],
                );
              },
            ),
          ),
        );
        await tester.tap(find.text('GO'));
        await tester.pump();
        // No controller is running; the bar is already at its end state.
        expect(tester.hasRunningAnimations, isFalse);
        expect(filledSegments(tester), 9);
      },
    );
  });

  group('AurisStepIndicator', () {
    testWidgets('inactive/active states render the step number', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(
          const Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              AurisStepIndicator(step: 1, state: AurisStepState.active),
              AurisStepIndicator(step: 2, state: AurisStepState.inactive),
            ],
          ),
        ),
      );
      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('complete shows a check and error shows a warning glyph', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(
          const Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              AurisStepIndicator(step: 1, state: AurisStepState.complete),
              AurisStepIndicator(step: 2, state: AurisStepState.error),
            ],
          ),
        ),
      );
      expect(find.byIcon(Icons.check), findsOneWidget);
      expect(find.byIcon(Icons.priority_high), findsOneWidget);
    });

    testWidgets('active state glows the glyph, not the box', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(const AurisStepIndicator(step: 1, state: AurisStepState.active)),
      );
      final AurisContainer container = tester.widget<AurisContainer>(
        find.byType(AurisContainer),
      );
      expect(container.borderColor, scheme.primaryActive);
      // The glow rides on the number as a tight glyph shadow (so it hugs the
      // digit), not on the box behind a translucent fill (which read as an orb).
      expect(container.depth, isNull);
      final Text label = tester.widget<Text>(find.text('1'));
      expect(label.style?.shadows, scheme.depthActive.glow);
    });
  });

  group('AurisTerminal', () {
    testWidgets('renders lines and colors them by type', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(
          const AurisTerminal(
            title: 'LOG',
            showCursor: false,
            lines: <AurisTerminalLine>[
              AurisTerminalLine('booting', type: AurisTerminalLineType.augment),
              AurisTerminalLine('fault', type: AurisTerminalLineType.error),
            ],
          ),
        ),
      );
      expect(find.text('LOG'), findsOneWidget);
      expect(find.text('booting'), findsOneWidget);
      final Text errorLine = tester.widget<Text>(find.text('fault'));
      expect(errorLine.style!.color, scheme.dangerBright);
      final Text augmentLine = tester.widget<Text>(find.text('booting'));
      expect(augmentLine.style!.color, scheme.primaryActive);
    });

    testWidgets('auto-scrolls to the newest line when lines are appended', (
      WidgetTester tester,
    ) async {
      final List<AurisTerminalLine> lines = <AurisTerminalLine>[
        for (int i = 0; i < 30; i++) AurisTerminalLine('line $i'),
      ];
      await tester.pumpWidget(
        host(
          StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  AurisTerminal(showCursor: false, height: 120, lines: lines),
                  TextButton(
                    onPressed: () => setState(
                      () => lines.add(const AurisTerminalLine('NEWEST')),
                    ),
                    child: const Text('APPEND'),
                  ),
                ],
              );
            },
          ),
        ),
      );
      await tester.pump();
      await tester.tap(find.text('APPEND'));
      await tester.pump();
      // Let the post-frame auto-scroll run to completion.
      await tester.pumpAndSettle();
      expect(find.text('NEWEST'), findsOneWidget);
    });

    testWidgets('blinking cursor does not run under reduced motion', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(
          const AurisTerminal(
            lines: <AurisTerminalLine>[AurisTerminalLine('ready')],
          ),
          disableAnimations: true,
        ),
      );
      await tester.pump();
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('disposes cleanly with no pending timers', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(
          const AurisTerminal(
            lines: <AurisTerminalLine>[AurisTerminalLine('ready')],
          ),
        ),
      );
      await tester.pump();
      // Replacing the tree disposes the terminal; if the blink controller or
      // scroll controller leaked, the test framework would flag it.
      await tester.pumpWidget(host(const SizedBox.shrink()));
      expect(find.byType(AurisTerminal), findsNothing);
    });
  });

  group('AurisSelect', () {
    Widget selectHost({String? value, ValueChanged<String>? onChanged}) {
      return host(
        StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AurisSelect<String>(
              value: value,
              placeholder: 'PICK',
              options: const <AurisSelectOption<String>>[
                AurisSelectOption<String>(value: 'a', label: 'Alpha'),
                AurisSelectOption<String>(value: 'b', label: 'Beta'),
              ],
              onChanged: onChanged ?? (String v) => setState(() => value = v),
            );
          },
        ),
      );
    }

    testWidgets('opens the popup on tap and shows the options', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(selectHost());
      expect(find.text('PICK'), findsOneWidget);
      await tester.tap(find.byType(AurisSelect<String>));
      await tester.pumpAndSettle();
      expect(find.text('ALPHA'), findsOneWidget);
      expect(find.text('BETA'), findsOneWidget);
    });

    testWidgets('selecting a row reports the value and closes the popup', (
      WidgetTester tester,
    ) async {
      String? chosen;
      await tester.pumpWidget(selectHost(onChanged: (String v) => chosen = v));
      await tester.tap(find.byType(AurisSelect<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('BETA'));
      await tester.pumpAndSettle();
      expect(chosen, 'b');
      // Popup closed: the row labels are gone.
      expect(find.text('BETA'), findsNothing);
    });

    testWidgets('tapping outside dismisses the popup', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(selectHost());
      await tester.tap(find.byType(AurisSelect<String>));
      await tester.pumpAndSettle();
      expect(find.text('ALPHA'), findsOneWidget);
      // Tap the top-left corner, away from the popup.
      await tester.tapAt(const Offset(5, 5));
      await tester.pumpAndSettle();
      expect(find.text('ALPHA'), findsNothing);
    });

    testWidgets('disabled select does not open', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(
          const AurisSelect<String>(
            value: 'a',
            onChanged: null,
            options: <AurisSelectOption<String>>[
              AurisSelectOption<String>(value: 'a', label: 'Alpha'),
            ],
          ),
        ),
      );
      await tester.tap(find.byType(AurisSelect<String>));
      await tester.pumpAndSettle();
      // No popup row appears (only the trigger label).
      expect(find.text('ALPHA'), findsOneWidget);
    });

    testWidgets(
      'caret snaps open with no running animation under reduced motion',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            disableAnimations: true,
            const AurisSelect<String>(
              value: 'a',
              onChanged: _noop,
              options: <AurisSelectOption<String>>[
                AurisSelectOption<String>(value: 'a', label: 'Alpha'),
                AurisSelectOption<String>(value: 'b', label: 'Beta'),
              ],
            ),
          ),
        );
        await tester.tap(find.byType(AurisSelect<String>));
        // A single pump (no settle): the caret is already at its end state and
        // no controller is running.
        await tester.pump();
        expect(tester.hasRunningAnimations, isFalse);
        // The popup is open (rows visible) without any tween elapsing.
        expect(find.text('BETA'), findsOneWidget);
        final RotationTransition caret = tester.widget<RotationTransition>(
          find.ancestor(
            of: find.byIcon(Icons.keyboard_arrow_down),
            matching: find.byType(RotationTransition),
          ),
        );
        expect(caret.turns.value, 0.5);
      },
    );
  });
}

/// A const, top-level no-op so an enabled [AurisSelect] can be built `const`.
void _noop(String _) {}
