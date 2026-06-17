// README gallery renderer (NOT a normal test): pumps a rich widget gallery in
// the dark and light variants, plus an accent-customization triptych, and writes
// the PNGs into doc/images/ for the README. Run explicitly:
//   flutter test test/readme_gallery.dart
// Each shot is its own test so the per-test binding is fresh (multiple toImage
// calls in one test deadlock).
import 'dart:io';
import 'dart:ui' as ui;

import 'package:auris/auris.dart';
import 'package:auris/auris_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/font_loader.dart';

// Pump [child] under [theme], let glow/animation settle, capture the tagged
// RepaintBoundary and write it to doc/images/<name>.png.
Future<void> _shoot(
  WidgetTester tester, {
  required String name,
  required Size size,
  required ThemeData theme,
  required Widget Function(BuildContext, AurisScheme) builder,
  double pixelRatio = 2.0,
}) async {
  final Directory outDir = Directory('doc/images')..createSync(recursive: true);
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await loadAurisFonts();

  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: theme,
      home: Builder(
        builder: (BuildContext context) {
          final AurisScheme scheme = Theme.of(
            context,
          ).extension<AurisScheme>()!;
          return Scaffold(
            backgroundColor: scheme.surfacePage,
            body: Center(
              child: RepaintBoundary(
                key: const ValueKey<String>('shot'),
                child: ColoredBox(
                  color: scheme.surfacePage,
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: builder(context, scheme),
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
    final ui.Image image = await boundary.toImage(pixelRatio: pixelRatio);
    final ByteData? bytes = await image.toByteData(
      format: ui.ImageByteFormat.png,
    );
    return bytes!.buffer.asUint8List();
  });
  File('${outDir.path}/$name.png').writeAsBytesSync(png!);
}

// The full showcase gallery — a two-column HUD dashboard touching custom
// widgets and themed Material widgets alike.
Widget _gallery(BuildContext context, AurisScheme scheme) {
  final TextTheme text = Theme.of(context).textTheme;
  return SizedBox(
    width: 1120,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('AURIS', style: text.displaySmall),
        Text('AUGMENTATION-ERA UI KIT FOR FLUTTER', style: text.bodyMedium),
        const SizedBox(height: 20),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(child: _leftColumn(context, text)),
            const SizedBox(width: 28),
            Expanded(child: _rightColumn(context, text)),
          ],
        ),
      ],
    ),
  );
}

Widget _leftColumn(BuildContext context, TextTheme text) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Row(
        children: <Widget>[
          FilledButton(onPressed: () {}, child: const Text('ENGAGE')),
          const SizedBox(width: 10),
          OutlinedButton(onPressed: () {}, child: const Text('STANDBY')),
          const SizedBox(width: 10),
          TextButton(onPressed: () {}, child: const Text('DETAILS')),
        ],
      ),
      const SizedBox(height: 14),
      const Wrap(
        spacing: 8,
        runSpacing: 8,
        children: <Widget>[
          AurisBadge('ONLINE', variant: AurisBadgeVariant.success),
          AurisBadge('ARMED', variant: AurisBadgeVariant.gold),
          AurisBadge('SYNC', variant: AurisBadgeVariant.slate),
          AurisBadge('FAULT', variant: AurisBadgeVariant.danger),
        ],
      ),
      const SizedBox(height: 16),
      const AurisPanel(
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
      const SizedBox(height: 16),
      const Row(
        children: <Widget>[
          Expanded(
            child: AurisStatCard(
              label: 'THROUGHPUT',
              value: '94.2',
              unit: 'GB/s',
              delta: '+12.4%',
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: AurisStatCard(
              label: 'LATENCY',
              value: '12',
              unit: 'ms',
              delta: '-3.1%',
              deltaPositiveIsGood: false,
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),
      const AurisProgressBar(value: 0.72, label: 'POWER'),
      const SizedBox(height: 12),
      Slider(value: 0.4, divisions: 10, onChanged: (_) {}),
    ],
  );
}

Widget _rightColumn(BuildContext context, TextTheme text) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      const AurisNotification(
        variant: AurisNotificationVariant.info,
        title: 'UPLINK ESTABLISHED',
        message: 'Telemetry stream nominal.',
        code: 'NET-200',
      ),
      const SizedBox(height: 14),
      Row(
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
      const SizedBox(height: 14),
      Row(
        children: <Widget>[
          AurisRadio<int>(
            value: 0,
            groupValue: 0,
            onChanged: (_) {},
            label: 'AUTO',
          ),
          const SizedBox(width: 16),
          AurisRadio<int>(
            value: 1,
            groupValue: 0,
            onChanged: (_) {},
            label: 'MANUAL',
          ),
          const SizedBox(width: 24),
          const AurisStepIndicator(step: 1, state: AurisStepState.complete),
          const SizedBox(width: 10),
          const AurisStepIndicator(step: 2, state: AurisStepState.active),
          const SizedBox(width: 10),
          const AurisStepIndicator(step: 3, state: AurisStepState.inactive),
        ],
      ),
      const SizedBox(height: 14),
      AurisSelect<String>(
        value: 'NAV',
        onChanged: (_) {},
        options: const <AurisSelectOption<String>>[
          AurisSelectOption<String>(value: 'NAV', label: 'NAVIGATION'),
          AurisSelectOption<String>(value: 'WPN', label: 'WEAPONS'),
          AurisSelectOption<String>(value: 'COM', label: 'COMMS'),
        ],
      ),
      const SizedBox(height: 12),
      const TextField(decoration: InputDecoration(labelText: 'ACCESS KEY')),
      const SizedBox(height: 14),
      const AurisTerminal(
        title: 'SYSTEM LOG',
        code: 'TTY-1',
        height: 168,
        showCursor: true,
        lines: <AurisTerminalLine>[
          AurisTerminalLine(r'$ auris --boot'),
          AurisTerminalLine(
            'loading scheme ........ ok',
            type: AurisTerminalLineType.ok,
          ),
          AurisTerminalLine(
            'augment online',
            type: AurisTerminalLineType.augment,
          ),
          AurisTerminalLine(
            'cache miss on sector 3',
            type: AurisTerminalLineType.warning,
          ),
          AurisTerminalLine(
            'link lost: node 7',
            type: AurisTerminalLineType.error,
          ),
          AurisTerminalLine('retry ok', type: AurisTerminalLineType.ok),
        ],
      ),
    ],
  );
}

// A compact card used to show one accent at a time in the customization strip.
Widget _accentCard(BuildContext context, String tag) {
  final TextTheme text = Theme.of(context).textTheme;
  return SizedBox(
    width: 360,
    child: AurisPanel(
      title: tag,
      accent: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('SYSTEM ONLINE', style: text.titleMedium),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              FilledButton(onPressed: () {}, child: const Text('GO')),
              const SizedBox(width: 10),
              OutlinedButton(onPressed: () {}, child: const Text('WAIT')),
            ],
          ),
          const SizedBox(height: 12),
          AurisSwitch(
            value: true,
            onChanged: (_) {},
            label: 'POWER',
            statusLabels: const ('OFF', 'ON'),
          ),
          const SizedBox(height: 12),
          const AurisProgressBar(value: 0.66),
          const SizedBox(height: 12),
          const Wrap(
            spacing: 8,
            children: <Widget>[
              AurisBadge('READY', variant: AurisBadgeVariant.gold),
              AurisBadge('LINK', variant: AurisBadgeVariant.slate),
            ],
          ),
        ],
      ),
    ),
  );
}

void main() {
  testWidgets('gallery_dark', (WidgetTester tester) async {
    await _shoot(
      tester,
      name: 'gallery-dark',
      size: const Size(1280, 1100),
      theme: AurisTheme.dark(),
      builder: _gallery,
    );
  });

  testWidgets('gallery_light', (WidgetTester tester) async {
    await _shoot(
      tester,
      name: 'gallery-light',
      size: const Size(1280, 1100),
      theme: AurisTheme.light(),
      builder: _gallery,
    );
  });

  // Same widgets, three accents — the amber default plus two overrides — to show
  // the accent knob re-skins both Material and custom widgets (glow included).
  testWidgets('accents', (WidgetTester tester) async {
    const Color teal = Color(0xFF35E0C0);
    const Color magenta = Color(0xFFE048B0);
    await _shoot(
      tester,
      name: 'accents',
      size: const Size(1280, 560),
      theme: AurisTheme.dark(),
      builder: (BuildContext context, AurisScheme scheme) {
        final ThemeData base = Theme.of(context);
        Widget tile(String tag, Color? accent) {
          final ThemeData t = AurisTheme.dark(accent: accent);
          return Theme(
            data: t,
            child: Builder(builder: (BuildContext c) => _accentCard(c, tag)),
          );
        }

        return DefaultTextStyle(
          style: base.textTheme.bodyMedium!,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              tile('AMBER', null),
              const SizedBox(width: 20),
              tile('TEAL', teal),
              const SizedBox(width: 20),
              tile('MAGENTA', magenta),
            ],
          ),
        );
      },
    );
  });
}
