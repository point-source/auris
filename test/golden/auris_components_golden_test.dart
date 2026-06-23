// Golden-image tests for the geometry- and glow-bearing custom widgets.
//
// The analyzer and behavioral unit tests do not catch visual regressions — a
// zero-height progress segment, an off-screen popup, a too-large chamfer, or a
// runaway glow all pass logic tests while looking wrong. These goldens are the
// automated counterpart to the manual showcase review, failing in CI when the
// rendered look drifts (§spec:showcase "Visual regression", §spec:custom-widgets).
//
// Determinism: every shot pins a fixed surface size, a device pixel ratio of
// 1.0, the `AurisTheme.dark()` + `AurisTheme.light()` accent, and loads the bundled fonts so
// glyphs render as real type rather than Ahem blocks — so the goldens depend
// only on the widget code, not the host. Generate / refresh with:
//   flutter test --update-goldens
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
import 'package:golden_matrix/golden_matrix.dart';

MatrixAxes get _axes => MatrixAxes(
  themes: <MatrixTheme>[
    MatrixTheme.custom('dark', AurisTheme.dark()),
    MatrixTheme.custom('light', AurisTheme.light()),
  ],
);

// Thin wrapper over `componentMatrixGolden` that pins the shared theme axis and
// disables report artifacts (no JSON/HTML/Markdown written next to the PNGs);
// stale-golden detection still runs. Keeps each call below to just its name +
// scenarios.
void _golden(
  String name, {
  required List<MatrixScenario> scenarios,
  bool freezeAnimations = false,
}) {
  componentMatrixGolden(
    name,
    scenarios: scenarios,
    axes: _axes,
    freezeAnimations: freezeAnimations,
    reportFormats: const <MatrixReportFormat>{},
  );
}

void main() {
  _golden(
    'AurisContainer',
    scenarios: <MatrixScenario>[
      MatrixScenario(
        'default',
        builder: () => const AurisContainer(
          width: 220,
          height: 140,
          padding: EdgeInsets.all(16),
          child: SizedBox.shrink(),
        ),
      ),
    ],
  );

  _golden(
    'AurisPanel',
    scenarios: <MatrixScenario>[
      MatrixScenario(
        'accent',
        builder: () => const SizedBox(
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
      MatrixScenario(
        'plain',
        builder: () => const SizedBox(
          width: 340,
          child: AurisPanel(
            title: 'DIAGNOSTICS',
            child: Column(
              children: <Widget>[
                AurisDataRow(label: 'UPTIME', value: '142:08'),
                AurisDataRow(label: 'ERRORS', value: '0'),
              ],
            ),
          ),
        ),
      ),
    ],
  );

  _golden(
    'AurisBadge',
    scenarios: <MatrixScenario>[
      MatrixScenario(
        'variants',
        builder: () => const SizedBox(
          width: 360,
          child: Wrap(
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
      ),
    ],
  );

  _golden(
    'AurisSwitch',
    scenarios: <MatrixScenario>[
      MatrixScenario(
        'states',
        builder: () => Row(
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
    ],
  );

  _golden(
    'AurisProgressBar',
    scenarios: <MatrixScenario>[
      MatrixScenario(
        'mid',
        builder: () => const SizedBox(
          width: 360,
          child: AurisProgressBar(value: 0.6, label: 'POWER'),
        ),
      ),
      MatrixScenario(
        'full',
        builder: () => const SizedBox(
          width: 360,
          child: AurisProgressBar(value: 1, label: 'CHARGE'),
        ),
      ),
    ],
  );

  _golden(
    'AurisSelect',
    scenarios: <MatrixScenario>[
      MatrixScenario(
        'closed',
        builder: () => SizedBox(
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
    ],
  );

  _golden(
    'AurisRadio',
    scenarios: <MatrixScenario>[
      MatrixScenario(
        'group',
        builder: () => Row(
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
    ],
  );

  _golden(
    'AurisStatCard',
    scenarios: <MatrixScenario>[
      MatrixScenario(
        'positive',
        builder: () => const SizedBox(
          width: 220,
          child: AurisStatCard(
            label: 'THROUGHPUT',
            value: '94.2',
            unit: 'GB/s',
            delta: '+12.4%',
          ),
        ),
      ),
      MatrixScenario(
        'negative',
        builder: () => const SizedBox(
          width: 220,
          child: AurisStatCard(
            label: 'LATENCY',
            value: '38.1',
            unit: 'ms',
            delta: '-4.2%',
          ),
        ),
      ),
    ],
  );

  _golden(
    'AurisStepIndicator',
    scenarios: <MatrixScenario>[
      MatrixScenario(
        'states',
        builder: () => const Row(
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
    ],
  );

  _golden(
    'AurisDataRow',
    scenarios: <MatrixScenario>[
      MatrixScenario(
        'states',
        builder: () => const SizedBox(
          width: 320,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              AurisDataRow(label: 'SHIELD', value: '88 %'),
              AurisDataRow(label: 'PRIORITY', value: 'CRITICAL', highlight: true),
              AurisDataRow(
                label: 'STATUS',
                trailing: AurisBadge('ONLINE', variant: AurisBadgeVariant.success),
              ),
            ],
          ),
        ),
      ),
    ],
  );

  _golden(
    'AurisNotification',
    scenarios: <MatrixScenario>[
      MatrixScenario(
        'info',
        builder: () => const SizedBox(
          width: 360,
          child: AurisNotification(
            title: 'System sync',
            message: 'Telemetry uplink re-established.',
            code: 'NET-200',
          ),
        ),
      ),
      MatrixScenario(
        'success',
        builder: () => const SizedBox(
          width: 360,
          child: AurisNotification(
            title: 'Calibration complete',
            message: 'All sensors within tolerance.',
            variant: AurisNotificationVariant.success,
          ),
        ),
      ),
      MatrixScenario(
        'warning',
        builder: () => const SizedBox(
          width: 360,
          child: AurisNotification(
            title: 'Thermal margin low',
            message: 'Coolant flow below nominal.',
            variant: AurisNotificationVariant.warning,
          ),
        ),
      ),
      MatrixScenario(
        'error',
        builder: () => SizedBox(
          width: 360,
          child: AurisNotification(
            title: 'Reactor fault',
            message: 'Containment field unstable.',
            code: 'RC-500',
            variant: AurisNotificationVariant.error,
            onDismiss: () {},
          ),
        ),
      ),
    ],
  );

  _golden(
    'AurisHexOrnament',
    scenarios: <MatrixScenario>[
      MatrixScenario(
        'cluster',
        builder: () => const SizedBox(
          width: 180,
          height: 120,
          child: AurisHexOrnament(),
        ),
      ),
    ],
  );

  _golden(
    'AurisScanBracket',
    scenarios: <MatrixScenario>[
      MatrixScenario(
        'framed',
        builder: () => const AurisScanBracket(
          child: SizedBox(
            width: 120,
            height: 72,
            child: Center(
              child: AurisBadge('LOCK', variant: AurisBadgeVariant.gold),
            ),
          ),
        ),
      ),
    ],
  );

  _golden(
    'AurisTerminal',
    scenarios: <MatrixScenario>[
      MatrixScenario(
        'log',
        builder: () => const SizedBox(
          width: 360,
          child: AurisTerminal(
            code: 'SYS-LOG',
            height: 160,
            // Cursor hidden: its blink is an infinite Ticker that would hang the
            // settle; the static log is what the golden guards.
            showCursor: false,
            lines: <AurisTerminalLine>[
              AurisTerminalLine('> boot sequence initiated'),
              AurisTerminalLine('checksum ok', type: AurisTerminalLineType.ok),
              AurisTerminalLine('augment online', type: AurisTerminalLineType.augment),
              AurisTerminalLine('coolant low', type: AurisTerminalLineType.warning),
              AurisTerminalLine('sensor 3 offline', type: AurisTerminalLineType.error),
            ],
          ),
        ),
      ),
    ],
    // Halts the terminal's blink/auto-scroll Tickers so `pumpAndSettle` is
    // stable.
    freezeAnimations: true,
  );
}
