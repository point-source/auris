import 'package:auris/auris.dart';
import 'package:auris/auris_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Widget tests for the custom HUD display + ornament widgets
/// (§spec:custom-widgets): each renders, composes from the chamfered
/// primitive, and reads its design values from the resolved [AurisScheme].
void main() {
  final ThemeData theme = AurisTheme.light();
  final AurisScheme scheme = theme.extension<AurisScheme>()!;

  /// Wraps [child] in the Auris theme + a MaterialApp scaffold, optionally
  /// forcing reduced motion via [disableAnimations].
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

  group('AurisContainer', () {
    testWidgets('renders its child and clips via ChamferClipper', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(const AurisContainer(child: Text('CONTENT'))),
      );
      expect(find.text('CONTENT'), findsOneWidget);
      expect(find.byType(ClipPath), findsWidgets);
    });

    testWidgets('clipChild: false omits the ClipPath', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(const AurisContainer(clipChild: false, child: Text('NOCLIP'))),
      );
      expect(find.byType(ClipPath), findsNothing);
    });

    testWidgets('paints the chamfered shape with the scheme fill', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(host(const AurisContainer()));
      final ShapeDecoration decoration = tester
          .widgetList<DecoratedBox>(find.byType(DecoratedBox))
          .map((DecoratedBox b) => b.decoration)
          .whereType<ShapeDecoration>()
          .firstWhere((ShapeDecoration d) => d.shape is AurisChamferBorder);
      expect(decoration.color, scheme.surfacePanel);
      expect((decoration.shape as AurisChamferBorder).cut, scheme.bevel.md);
    });
  });

  group('AurisBadge', () {
    testWidgets('renders the label uppercased', (WidgetTester tester) async {
      await tester.pumpWidget(host(const AurisBadge('online')));
      expect(find.text('ONLINE'), findsOneWidget);
    });

    testWidgets('variant colors the label from the scheme', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(const AurisBadge('FAULT', variant: AurisBadgeVariant.danger)),
      );
      final Text label = tester.widget<Text>(find.text('FAULT'));
      expect(label.style!.color, scheme.dangerBright);
    });

    testWidgets('renders icon when iconData is provided', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(
          const AurisBadge(
            'ACTIVE',
            variant: AurisBadgeVariant.success,
            iconData: Icons.check_circle,
          ),
        ),
      );
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      expect(find.text('ACTIVE'), findsOneWidget);
    });

    testWidgets('does not render icon when iconData is null', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(host(const AurisBadge('PLAIN')));
      expect(find.byType(Icon), findsNothing);
      expect(find.text('PLAIN'), findsOneWidget);
    });
  });

  group('AurisPanel', () {
    testWidgets('renders the uppercased title, code, and body', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(
          const AurisPanel(
            title: 'reactor',
            code: 'SYS-01',
            child: Text('BODY'),
          ),
        ),
      );
      expect(find.text('REACTOR'), findsOneWidget);
      expect(find.text('SYS-01'), findsOneWidget);
      expect(find.text('BODY'), findsOneWidget);
      // The header is marked by corner ticks now, not '[' ']' glyphs.
      expect(find.text('['), findsNothing);
    });

    testWidgets('accent mode adds a subtle-depth glow to the container', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(const AurisPanel(title: 'P', accent: true, child: Text('B'))),
      );
      final AurisContainer container = tester.widget<AurisContainer>(
        find.byType(AurisContainer),
      );
      expect(container.depth, scheme.depthSubtle);
      expect(container.borderColor, scheme.primaryActive);
    });
  });

  group('AurisNotification', () {
    testWidgets('renders title, message, code, and variant icon', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(
          const AurisNotification(
            title: 'breach',
            message: 'isolation failed',
            code: 'E-911',
            variant: AurisNotificationVariant.error,
          ),
        ),
      );
      expect(find.text('BREACH'), findsOneWidget);
      expect(find.text('isolation failed'), findsOneWidget);
      expect(find.text('E-911'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('dismiss button invokes onDismiss', (
      WidgetTester tester,
    ) async {
      int dismissed = 0;
      await tester.pumpWidget(
        host(AurisNotification(title: 'ALERT', onDismiss: () => dismissed++)),
      );
      await tester.tap(find.byIcon(Icons.close));
      expect(dismissed, 1);
    });

    testWidgets('no dismiss button when onDismiss is null', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(host(const AurisNotification(title: 'ALERT')));
      expect(find.byIcon(Icons.close), findsNothing);
    });
  });

  group('AurisDataRow', () {
    testWidgets('renders label, value, and trailing', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(
          const AurisDataRow(
            label: 'core temp',
            value: '412 K',
            trailing: AurisBadge('OK'),
          ),
        ),
      );
      expect(find.text('CORE TEMP'), findsOneWidget);
      expect(find.text('412 K'), findsOneWidget);
      expect(find.text('OK'), findsOneWidget);
    });

    testWidgets('highlight brightens the value to the highlight role', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(const AurisDataRow(label: 'F', value: 'CRIT', highlight: true)),
      );
      final Text value = tester.widget<Text>(find.text('CRIT'));
      expect(value.style!.color, scheme.primaryHighlight);
    });
  });

  group('AurisStatCard', () {
    testWidgets('renders label, value, unit, and delta', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(
          const AurisStatCard(
            label: 'throughput',
            value: '94.2',
            unit: 'GB/s',
            delta: '+2.4%',
          ),
        ),
      );
      expect(find.text('THROUGHPUT'), findsOneWidget);
      expect(find.textContaining('94.2'), findsOneWidget);
      expect(find.text('+2.4%'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_upward), findsOneWidget);
    });

    testWidgets('a negative delta shows the down arrow', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(const AurisStatCard(label: 'L', value: '12', delta: '-3.1%')),
      );
      expect(find.byIcon(Icons.arrow_downward), findsOneWidget);
    });
  });

  group('AurisHexOrnament', () {
    testWidgets('is non-interactive (wrapped in IgnorePointer)', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(const SizedBox(width: 80, height: 80, child: AurisHexOrnament())),
      );
      expect(
        find.descendant(
          of: find.byType(AurisHexOrnament),
          matching: find.byType(IgnorePointer),
        ),
        findsOneWidget,
      );
      expect(find.byType(CustomPaint), findsWidgets);
    });
  });

  group('AurisScanBracket', () {
    testWidgets('frames its child', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(const AurisScanBracket(child: Text('TARGET'))),
      );
      expect(find.text('TARGET'), findsOneWidget);
    });

    testWidgets('pulsing animates opacity over time', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(const AurisScanBracket(pulse: true, child: Text('LOCK'))),
      );
      await tester.pump();
      final double start = tester
          .widget<Opacity>(find.byType(Opacity).first)
          .opacity;
      await tester.pump(const Duration(milliseconds: 175));
      final double mid = tester
          .widget<Opacity>(find.byType(Opacity).first)
          .opacity;
      expect(mid, isNot(start));
      // Settle the repeating animation so the test can dispose cleanly.
      await tester.pumpWidget(host(const SizedBox.shrink()));
    });

    testWidgets('reduced motion renders the steady full-opacity end state', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(
          const AurisScanBracket(pulse: true, child: Text('LOCK')),
          disableAnimations: true,
        ),
      );
      await tester.pump();
      final double opacity = tester
          .widget<Opacity>(find.byType(Opacity).first)
          .opacity;
      expect(opacity, 1.0);
      // No animation should be running under reduced motion.
      expect(tester.hasRunningAnimations, isFalse);
    });
  });

  group('AurisRadio', () {
    testWidgets('reports its value on tap when not already selected', (
      WidgetTester tester,
    ) async {
      int? picked;
      await tester.pumpWidget(
        host(
          AurisRadio<int>(
            value: 1,
            groupValue: 0,
            onChanged: (int v) => picked = v,
            label: 'HIGH',
          ),
        ),
      );
      expect(find.text('HIGH'), findsOneWidget);
      await tester.tap(find.byType(AurisRadio<int>));
      expect(picked, 1);
    });

    testWidgets('a disabled radio does not report', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(
          const AurisRadio<int>(
            value: 2,
            groupValue: 0,
            onChanged: null,
            label: 'LOCKED',
          ),
        ),
      );
      // Tapping a disabled radio is a no-op; it renders at half opacity.
      await tester.tap(find.byType(AurisRadio<int>));
      expect(tester.widget<Opacity>(find.byType(Opacity).first).opacity, 0.5);
    });
  });
}
