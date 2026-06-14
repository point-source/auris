// Render harness (NOT a normal test): pumps the geometry/glow-bearing widgets
// at chosen accent + glow settings and writes PNGs to /tmp/auris_renders so the
// rendered appearance can be inspected directly. Run explicitly:
//   flutter test test/render_harness.dart
// Each variant is its own test so the per-test binding is fresh (multiple
// toImage calls in one test deadlock).
import 'dart:io';
import 'dart:ui' as ui;

import 'package:auris/auris.dart';
import 'package:auris/auris_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

class _Variant {
  const _Variant(this.name, {this.accent, this.glowScale = 1.0});
  final String name;
  final Color? accent;
  final double glowScale;
}

// Load the bundled fonts so glyphs render for real instead of as Ahem blocks
// (needed to judge a glyph-hugging glow).
Future<void> _loadFonts() async {
  // Multiple files per family so Flutter can pick the right weight (matching the
  // pubspec). Rajdhani ships Medium/SemiBold/Bold; loading only one made every
  // weight render the same, hiding weight changes.
  final Map<String, List<String>> families = <String, List<String>>{
    'packages/auris/ShareTechMono': <String>['fonts/ShareTechMono-Regular.ttf'],
    'packages/auris/Rajdhani': <String>[
      'fonts/Rajdhani-Medium.ttf',
      'fonts/Rajdhani-SemiBold.ttf',
      'fonts/Rajdhani-Bold.ttf',
    ],
    'packages/auris/ExoTwo': <String>['fonts/Exo2-Regular.ttf'],
  };
  for (final MapEntry<String, List<String>> e in families.entries) {
    final FontLoader loader = FontLoader(e.key);
    for (final String path in e.value) {
      final Uint8List bytes = File(path).readAsBytesSync();
      loader.addFont(Future<ByteData>.value(ByteData.view(bytes.buffer)));
    }
    await loader.load();
  }
}

void main() {
  const Color teal = Color(0xFF35E0C0);
  const List<_Variant> variants = <_Variant>[
    _Variant('amber_glow1'),
    _Variant('teal_glow1', accent: teal),
    _Variant('teal_glow0', accent: teal, glowScale: 0.0),
    _Variant('teal_glow3', accent: teal, glowScale: 3.0),
  ];

  for (final _Variant v in variants) {
    testWidgets('render ${v.name}', (WidgetTester tester) async {
      final Directory outDir = Directory('/tmp/auris_renders')
        ..createSync(recursive: true);
      tester.view.physicalSize = const Size(1100, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await _loadFonts();

      await tester.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AurisTheme.light(accent: v.accent, glowScale: v.glowScale),
          home: Builder(
            builder: (BuildContext context) {
              final AurisScheme scheme =
                  Theme.of(context).extension<AurisScheme>()!;
              return Scaffold(
                backgroundColor: scheme.surfacePage,
                body: Center(
                  child: RepaintBoundary(
                    key: const ValueKey<String>('shot'),
                    child: ColoredBox(
                      color: scheme.surfacePage,
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                const AurisStepIndicator(step: 1, state: AurisStepState.complete, size: 64),
                                const SizedBox(width: 28),
                                const AurisStepIndicator(step: 2, state: AurisStepState.active, size: 64),
                                const SizedBox(width: 28),
                                const AurisStepIndicator(step: 3, state: AurisStepState.inactive, size: 64),
                                const SizedBox(width: 28),
                                const AurisStepIndicator(step: 4, state: AurisStepState.error, size: 64),
                                const SizedBox(width: 28),
                                AurisRadio<int>(
                                  value: 0,
                                  groupValue: 0,
                                  onChanged: (_) {},
                                  label: 'SEL',
                                ),
                                const SizedBox(width: 16),
                                AurisRadio<int>(
                                  value: 1,
                                  groupValue: 0,
                                  onChanged: (_) {},
                                  label: 'OFF',
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            const SizedBox(
                              width: 420,
                              child: AurisProgressBar(value: 0.5),
                            ),
                            const SizedBox(height: 24),
                            const SizedBox(
                              width: 420,
                              child: AurisNotification(
                                variant: AurisNotificationVariant.info,
                                title: 'UPLINK',
                                message: 'Telemetry nominal',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 400));

      final RenderRepaintBoundary boundary = tester.renderObject(
        find.byKey(const ValueKey<String>('shot')),
      );
      final Uint8List? png = await tester.runAsync(() async {
        final ui.Image image = await boundary.toImage(pixelRatio: 2.0);
        final ByteData? bytes =
            await image.toByteData(format: ui.ImageByteFormat.png);
        return bytes!.buffer.asUint8List();
      });
      File('${outDir.path}/${v.name}.png').writeAsBytesSync(png!);
    });
  }

  // Side-by-side comparison of active-step glow candidates, overriding
  // depthActive per cell so several tightness options render in one image.
  testWidgets('glow_compare', (WidgetTester tester) async {
    final Directory outDir = Directory('/tmp/auris_renders')
      ..createSync(recursive: true);
    tester.view.physicalSize = const Size(1600, 500);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
      await _loadFonts();

    const Color amber = Color(0xFFF0A500);
    final List<({String label, List<BoxShadow> glow})> candidates =
        <({String label, List<BoxShadow> glow})>[
      (label: 'A none', glow: const <BoxShadow>[]),
      (
        label: 'B b1 s0',
        glow: const <BoxShadow>[
          BoxShadow(color: Color(0x66F0A500), blurRadius: 1),
        ]
      ),
      (
        label: 'C b2 s-1',
        glow: const <BoxShadow>[
          BoxShadow(color: Color(0x4DF0A500), blurRadius: 2, spreadRadius: -1),
        ]
      ),
      (
        label: 'D b3 s-1 (cur~)',
        glow: const <BoxShadow>[
          BoxShadow(color: Color(0x3DF0A500), blurRadius: 3, spreadRadius: -1),
        ]
      ),
      (
        label: 'E b6 s1 (wide)',
        glow: <BoxShadow>[
          BoxShadow(color: amber.withValues(alpha: 0.4), blurRadius: 6, spreadRadius: 1),
        ]
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AurisTheme.light(),
        home: Builder(
          builder: (BuildContext context) {
            final ThemeData base = Theme.of(context);
            final AurisScheme scheme = base.extension<AurisScheme>()!;
            return Scaffold(
              backgroundColor: scheme.surfacePage,
              body: Center(
                child: RepaintBoundary(
                  key: const ValueKey<String>('shot'),
                  child: ColoredBox(
                    color: scheme.surfacePage,
                    child: Padding(
                      padding: const EdgeInsets.all(48),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          for (final ({String label, List<BoxShadow> glow}) c
                              in candidates) ...<Widget>[
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Theme(
                                  data: base.copyWith(
                                    extensions: <ThemeExtension<dynamic>>[
                                      scheme.copyWith(
                                        depthActive:
                                            AurisDepth(glow: c.glow),
                                      ),
                                    ],
                                  ),
                                  child: const AurisStepIndicator(
                                    step: 2,
                                    state: AurisStepState.active,
                                    size: 64,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  c.label,
                                  style: const TextStyle(
                                    color: Color(0xFFF0E8D0),
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 36),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 400));
    final RenderRepaintBoundary boundary = tester.renderObject(
      find.byKey(const ValueKey<String>('shot')),
    );
    final Uint8List? png = await tester.runAsync(() async {
      final ui.Image image = await boundary.toImage(pixelRatio: 2.5);
      final ByteData? bytes =
          await image.toByteData(format: ui.ImageByteFormat.png);
      return bytes!.buffer.asUint8List();
    });
    File('${outDir.path}/glow_compare.png').writeAsBytesSync(png!);
  });

  // Same display word at w700 / w600 / w500 so the weight step is visible.
  testWidgets('weights_compare', (WidgetTester tester) async {
    final Directory outDir = Directory('/tmp/auris_renders')
      ..createSync(recursive: true);
    tester.view.physicalSize = const Size(1400, 600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await _loadFonts();

    Widget sample(String w, FontWeight weight) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Text(
            'SYSTEM ONLINE  ·  94.2  ($w)',
            style: TextStyle(
              fontFamily: 'packages/auris/Rajdhani',
              fontWeight: weight,
              fontSize: 40,
              letterSpacing: 1.8,
              color: const Color(0xFFF0E8D0),
            ),
          ),
        );

    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: ColoredBox(
          color: const Color(0xFF0A0A0C),
          child: RepaintBoundary(
            key: const ValueKey<String>('shot'),
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  sample('w700 Bold', FontWeight.w700),
                  sample('w600 SemiBold', FontWeight.w600),
                  sample('w500 Medium', FontWeight.w500),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 400));
    final RenderRepaintBoundary boundary = tester.renderObject(
      find.byKey(const ValueKey<String>('shot')),
    );
    final Uint8List? png = await tester.runAsync(() async {
      final ui.Image image = await boundary.toImage(pixelRatio: 2.0);
      final ByteData? bytes =
          await image.toByteData(format: ui.ImageByteFormat.png);
      return bytes!.buffer.asUint8List();
    });
    File('${outDir.path}/weights_compare.png').writeAsBytesSync(png!);
  });

  // Title + buttons + segmented control, to judge label text weight.
  testWidgets('typography', (WidgetTester tester) async {
    final Directory outDir = Directory('/tmp/auris_renders')
      ..createSync(recursive: true);
    tester.view.physicalSize = const Size(1200, 700);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await _loadFonts();

    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AurisTheme.light(),
        home: Builder(
          builder: (BuildContext context) {
            final ThemeData theme = Theme.of(context);
            final AurisScheme scheme = theme.extension<AurisScheme>()!;
            return Scaffold(
              backgroundColor: scheme.surfacePage,
              body: RepaintBoundary(
                key: const ValueKey<String>('shot'),
                child: ColoredBox(
                  color: scheme.surfacePage,
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'AURIS // CORE CONTROLS',
                          style: theme.textTheme.titleLarge,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'SYSTEM ONLINE',
                          style: theme.textTheme.displaySmall,
                        ),
                        Text(
                          'REACTOR CORE',
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        const AurisStatCard(
                          label: 'THROUGHPUT',
                          value: '94.2',
                          unit: 'GB/s',
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: <Widget>[
                            FilledButton(
                              onPressed: () {},
                              child: const Text('ENGAGE'),
                            ),
                            const SizedBox(width: 12),
                            OutlinedButton(
                              onPressed: () {},
                              child: const Text('STANDBY'),
                            ),
                            const SizedBox(width: 12),
                            TextButton(
                              onPressed: () {},
                              child: const Text('DETAILS'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        SegmentedButton<int>(
                          showSelectedIcon: false,
                          segments: const <ButtonSegment<int>>[
                            ButtonSegment<int>(value: 0, label: Text('TIGHT')),
                            ButtonSegment<int>(value: 1, label: Text('NORMAL')),
                            ButtonSegment<int>(value: 2, label: Text('BOLD')),
                          ],
                          selected: const <int>{1},
                          onSelectionChanged: (_) {},
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 400));
    final RenderRepaintBoundary boundary = tester.renderObject(
      find.byKey(const ValueKey<String>('shot')),
    );
    final Uint8List? png = await tester.runAsync(() async {
      final ui.Image image = await boundary.toImage(pixelRatio: 2.5);
      final ByteData? bytes =
          await image.toByteData(format: ui.ImageByteFormat.png);
      return bytes!.buffer.asUint8List();
    });
    File('${outDir.path}/typography.png').writeAsBytesSync(png!);
  });

  // Continuous vs stepped (divisions:10) slider — the stepped track should show
  // one cell per step.
  testWidgets('sliders', (WidgetTester tester) async {
    final Directory outDir = Directory('/tmp/auris_renders')
      ..createSync(recursive: true);
    tester.view.physicalSize = const Size(1200, 500);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await _loadFonts();

    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AurisTheme.light(),
        home: Builder(
          builder: (BuildContext context) {
            final AurisScheme scheme =
                Theme.of(context).extension<AurisScheme>()!;
            return Scaffold(
              backgroundColor: scheme.surfacePage,
              body: RepaintBoundary(
                key: const ValueKey<String>('shot'),
                child: ColoredBox(
                  color: scheme.surfacePage,
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Text('CONTINUOUS',
                            style: TextStyle(color: Color(0xFFA09060)),),
                        Slider(value: 0.4, onChanged: (_) {}),
                        const SizedBox(height: 16),
                        const Text('STEPPED divisions:10',
                            style: TextStyle(color: Color(0xFFA09060)),),
                        Slider(
                          value: 0.4,
                          divisions: 10,
                          max: 1,
                          onChanged: (_) {},
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 400));
    final RenderRepaintBoundary boundary = tester.renderObject(
      find.byKey(const ValueKey<String>('shot')),
    );
    final Uint8List? png = await tester.runAsync(() async {
      final ui.Image image = await boundary.toImage(pixelRatio: 2.5);
      final ByteData? bytes =
          await image.toByteData(format: ui.ImageByteFormat.png);
      return bytes!.buffer.asUint8List();
    });
    File('${outDir.path}/sliders.png').writeAsBytesSync(png!);
  });

  // The native Material Stepper's default step icons vs the chamfered
  // AurisStepIndicator, to see whether they are consistent.
  testWidgets('stepper', (WidgetTester tester) async {
    final Directory outDir = Directory('/tmp/auris_renders')
      ..createSync(recursive: true);
    tester.view.physicalSize = const Size(900, 1100);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
      await _loadFonts();

    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AurisTheme.light(),
        home: Builder(
          builder: (BuildContext context) {
            final AurisScheme scheme =
                Theme.of(context).extension<AurisScheme>()!;
            return Scaffold(
              backgroundColor: scheme.surfacePage,
              body: RepaintBoundary(
                key: const ValueKey<String>('shot'),
                child: ColoredBox(
                  color: scheme.surfacePage,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Row(
                          children: <Widget>[
                            AurisStepIndicator(
                              step: 1,
                              state: AurisStepState.complete,
                            ),
                            SizedBox(width: 12),
                            AurisStepIndicator(
                              step: 2,
                              state: AurisStepState.active,
                            ),
                            SizedBox(width: 12),
                            AurisStepIndicator(
                              step: 3,
                              state: AurisStepState.inactive,
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          height: 320,
                          child: Stepper(
                            currentStep: 1,
                            stepIconBuilder: (int i, StepState state) {
                              final AurisStepState s = switch (state) {
                                StepState.complete => AurisStepState.complete,
                                StepState.error => AurisStepState.error,
                                _ => i == 1
                                    ? AurisStepState.active
                                    : AurisStepState.inactive,
                              };
                              return AurisStepIndicator(
                                step: i + 1,
                                state: s,
                                size: 24,
                              );
                            },
                            steps: const <Step>[
                              Step(
                                title: Text('CALIBRATE'),
                                content: Text('Align sensors.'),
                                state: StepState.complete,
                                isActive: true,
                              ),
                              Step(
                                title: Text('PRIME'),
                                content: Text('Spin up.'),
                                isActive: true,
                              ),
                              Step(
                                title: Text('LAUNCH'),
                                content: Text('Go.'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 400));
    final RenderRepaintBoundary boundary = tester.renderObject(
      find.byKey(const ValueKey<String>('shot')),
    );
    final Uint8List? png = await tester.runAsync(() async {
      final ui.Image image = await boundary.toImage(pixelRatio: 2.5);
      final ByteData? bytes =
          await image.toByteData(format: ui.ImageByteFormat.png);
      return bytes!.buffer.asUint8List();
    });
    File('${outDir.path}/stepper.png').writeAsBytesSync(png!);
  });
}
