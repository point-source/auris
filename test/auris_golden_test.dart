// Golden-image tests for the geometry- and glow-bearing custom widgets.
//
// The analyzer and behavioral unit tests do not catch visual regressions — a
// zero-height progress segment, an off-screen popup, a too-large chamfer, or a
// runaway glow all pass logic tests while looking wrong. These goldens are the
// automated counterpart to the manual showcase review, failing in CI when the
// rendered look drifts (§spec:showcase "Visual regression", §spec:custom-widgets).
//
// Determinism: every shot pins a fixed surface size, a device pixel ratio of
// 1.0, the canonical `AurisTheme.dark()` accent, and loads the bundled fonts so
// glyphs render as real type rather than Ahem blocks — so the goldens depend
// only on the widget code, not the host. Generate / refresh with:
//   flutter test --update-goldens test/auris_golden_test.dart
//
// Tagged `golden` so platform-sensitive image comparisons can be excluded from
// gates that run on a different host than the goldens were generated on (the
// live-demo deploy runs on Linux; goldens are authored on macOS). Run them
// with `flutter test --tags golden`.
@Tags(<String>['golden'])
library;

import 'package:auris/auris.dart';
import 'package:auris/auris_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/font_loader.dart';

// One golden case: a widget pumped on a fixed surface and matched against
// goldens/<name>.png.
typedef _GoldenCase = ({String name, Size size, Widget child});

// Pump [child] centered under the canonical dark theme on a fixed surface and
// assert it matches goldens/<name>.png.
Future<void> _expectGolden(WidgetTester tester, _GoldenCase c) async {
  tester.view.physicalSize = c.size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await loadAurisFonts();

  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AurisTheme.dark(),
      home: Builder(
        builder: (BuildContext context) {
          final AurisScheme scheme = Theme.of(
            context,
          ).extension<AurisScheme>()!;
          return Scaffold(
            backgroundColor: scheme.surfacePage,
            body: Center(
              child: RepaintBoundary(
                key: const ValueKey<String>('golden'),
                child: ColoredBox(
                  color: scheme.surfacePage,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: c.child,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    ),
  );
  // Settle entrance glow / animations to their resting frame.
  await tester.pump(const Duration(milliseconds: 400));

  await expectLater(
    find.byKey(const ValueKey<String>('golden')),
    matchesGoldenFile('goldens/${c.name}.png'),
  );
}

// The nine geometry/glow-bearing custom widgets, each at a fixed surface size.
// Widgets with `onChanged` callbacks cannot be `const`, so the list is built
// eagerly — harmless for a test.
final List<_GoldenCase> _cases = <_GoldenCase>[
  (
    name: 'auris_container',
    size: const Size(320, 240),
    child: const AurisContainer(
      width: 220,
      height: 140,
      padding: EdgeInsets.all(16),
      child: SizedBox.shrink(),
    ),
  ),
  (
    name: 'auris_panel',
    size: const Size(420, 280),
    child: const SizedBox(
      width: 340,
      child: AurisPanel(
        title: 'REACTOR CORE',
        code: 'RC-09',
        accent: true,
        child: Column(
          children: <Widget>[
            AurisDataRow(label: 'CORE TEMP', value: '612 K'),
            AurisDataRow(label: 'FLUX', value: '8.4 TW'),
            AurisDataRow(label: 'OUTPUT', value: '99.2 %', highlight: true),
          ],
        ),
      ),
    ),
  ),
  (
    name: 'auris_badge',
    size: const Size(360, 160),
    child: const Wrap(
      spacing: 8,
      runSpacing: 8,
      children: <Widget>[
        AurisBadge('ONLINE', variant: AurisBadgeVariant.success),
        AurisBadge('ARMED', variant: AurisBadgeVariant.gold),
        AurisBadge('SYNC', variant: AurisBadgeVariant.slate),
        AurisBadge('FAULT', variant: AurisBadgeVariant.danger),
      ],
    ),
  ),
  (
    name: 'auris_switch',
    size: const Size(420, 180),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        AurisSwitch(
          value: true,
          onChanged: (_) {},
          label: 'SHIELDS',
          statusLabels: const ('OFF', 'ON'),
        ),
        const SizedBox(width: 24),
        AurisSwitch(value: false, onChanged: (_) {}, label: 'CLOAK'),
      ],
    ),
  ),
  (
    name: 'auris_progress_bar',
    size: const Size(420, 140),
    child: const SizedBox(
      width: 360,
      child: AurisProgressBar(value: 0.6, label: 'POWER'),
    ),
  ),
  (
    name: 'auris_select',
    size: const Size(360, 160),
    child: SizedBox(
      width: 280,
      child: AurisSelect<String>(
        value: 'NAV',
        onChanged: (_) {},
        options: const <AurisSelectOption<String>>[
          AurisSelectOption<String>(value: 'NAV', label: 'NAVIGATION'),
          AurisSelectOption<String>(value: 'WPN', label: 'WEAPONS'),
          AurisSelectOption<String>(value: 'COM', label: 'COMMS'),
        ],
      ),
    ),
  ),
  (
    name: 'auris_radio',
    size: const Size(320, 140),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        AurisRadio<int>(
          value: 0,
          groupValue: 0,
          onChanged: (_) {},
          label: 'AUTO',
        ),
        const SizedBox(width: 20),
        AurisRadio<int>(
          value: 1,
          groupValue: 0,
          onChanged: (_) {},
          label: 'MANUAL',
        ),
      ],
    ),
  ),
  (
    name: 'auris_stat_card',
    size: const Size(280, 200),
    child: const SizedBox(
      width: 220,
      child: AurisStatCard(
        label: 'THROUGHPUT',
        value: '94.2',
        unit: 'GB/s',
        delta: '+12.4%',
      ),
    ),
  ),
  (
    name: 'auris_step_indicator',
    size: const Size(360, 160),
    child: const Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        AurisStepIndicator(step: 1, state: AurisStepState.complete, size: 56),
        SizedBox(width: 20),
        AurisStepIndicator(step: 2, state: AurisStepState.active, size: 56),
        SizedBox(width: 20),
        AurisStepIndicator(step: 3, state: AurisStepState.inactive, size: 56),
        SizedBox(width: 20),
        AurisStepIndicator(step: 4, state: AurisStepState.error, size: 56),
      ],
    ),
  ),
];

void main() {
  for (final _GoldenCase c in _cases) {
    testWidgets(c.name, (WidgetTester tester) => _expectGolden(tester, c));
  }
}
