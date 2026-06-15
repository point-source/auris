import 'dart:async';

import 'package:auris/auris.dart';
import 'package:auris/auris_widgets.dart';
import 'package:flutter/material.dart';

void main() => runApp(const AurisExampleApp());

/// A non-default accent option for the customization control. The example app
/// is not the package, so local `Color` literals are allowed here (the
/// no-raw-literals rule applies to the library, not to consumers).
class _AccentOption {
  const _AccentOption(this.label, this.color);

  /// `null` color means "the canonical default" — no accent override.
  final String label;
  final Color? color;
}

/// The accent palette the showcase can flip between: the default amber/gold
/// ramp plus a cool teal, a magenta, and a green, so flipping the control
/// re-skins every themed Material widget AND every Auris custom widget at once.
const List<_AccentOption> _accentOptions = <_AccentOption>[
  // null = no override → the kit's amber accent: bright gold on dark, the same
  // amber darkened to a bronze on light (same hue, adjusted lightness).
  _AccentOption('AMBER', null),
  _AccentOption('TEAL', Color(0xFF35E0C0)),
  _AccentOption('MAGENTA', Color(0xFFE048B0)),
  _AccentOption('GREEN', Color(0xFF6AD050)),
];

/// Preset steps for the bevel (corner-cut) and glow (depth-intensity) overrides,
/// labelled TIGHT / NORMAL / BOLD so their effect is legible at a glance.
class _ScaleStep {
  const _ScaleStep(this.label, this.value);

  final String label;
  final double value;
}

const List<_ScaleStep> _scaleSteps = <_ScaleStep>[
  _ScaleStep('TIGHT', 0.5),
  _ScaleStep('NORMAL', 1.0),
  _ScaleStep('BOLD', 2.0),
];

/// The showcase: a scrollable app that applies [AurisTheme.light] and renders
/// the re-skinned Material widgets — buttons, inputs, selection controls and
/// sliders; surfaces and overlays (cards, dialog, snackbar, bottom sheet,
/// tooltip, popup menu); navigation chrome (tab bar, navigation bar); and
/// data / feedback widgets (data table, list / expansion tile, progress, badge,
/// stepper) — each section introduced by a monospace uppercase amber header
/// (§spec:showcase).
///
/// It is stateful so the customization control near the top can lift the live
/// accent / bevel / glow overrides up to here; changing any of them rebuilds the
/// `MaterialApp` theme via [AurisTheme.light], and the whole showcase below
/// recolors and re-shapes because every widget reads the resolved scheme — that
/// propagation is the proof (§spec:customization, §road:customization-showcase).
class AurisExampleApp extends StatefulWidget {
  const AurisExampleApp({super.key});

  @override
  State<AurisExampleApp> createState() => _AurisExampleAppState();
}

class _AurisExampleAppState extends State<AurisExampleApp> {
  Color? _accent = _accentOptions.first.color;
  double _bevelScale = 1.0;
  double _glowScale = 1.0;
  Brightness _brightness = Brightness.dark;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = _brightness == Brightness.light
        ? AurisTheme.light(
            accent: _accent,
            bevelScale: _bevelScale,
            glowScale: _glowScale,
          )
        : AurisTheme.dark(
            accent: _accent,
            bevelScale: _bevelScale,
            glowScale: _glowScale,
          );
    return MaterialApp(
      title: 'Auris — Core Controls',
      debugShowCheckedModeBanner: false,
      theme: theme,
      home: _ShowcaseScreen(
        accent: _accent,
        bevelScale: _bevelScale,
        glowScale: _glowScale,
        brightness: _brightness,
        onAccentChanged: (Color? c) => setState(() => _accent = c),
        onBevelChanged: (double v) => setState(() => _bevelScale = v),
        onGlowChanged: (double v) => setState(() => _glowScale = v),
        onBrightnessChanged: (Brightness b) =>
            setState(() => _brightness = b),
      ),
    );
  }
}

class _ShowcaseScreen extends StatefulWidget {
  const _ShowcaseScreen({
    required this.accent,
    required this.bevelScale,
    required this.glowScale,
    required this.brightness,
    required this.onAccentChanged,
    required this.onBevelChanged,
    required this.onGlowChanged,
    required this.onBrightnessChanged,
  });

  final Color? accent;
  final double bevelScale;
  final double glowScale;
  final Brightness brightness;
  final ValueChanged<Color?> onAccentChanged;
  final ValueChanged<double> onBevelChanged;
  final ValueChanged<double> onGlowChanged;
  final ValueChanged<Brightness> onBrightnessChanged;

  @override
  State<_ShowcaseScreen> createState() => _ShowcaseScreenState();
}

class _ShowcaseScreenState extends State<_ShowcaseScreen> {
  bool _checkbox = true;
  bool _checkboxOff = false;
  int _radio = 0;
  bool _switch = true;
  bool _switchOff = false;
  bool _aurisSwitch = true;
  bool _aurisSwitchAlt = false;
  double _progress = 0.45;
  String? _aurisSelect = 'beta';
  double _slider = 0.4;
  double _sliderStepped = 30;
  final Set<String> _chips = <String>{'CORE'};
  String _segment = 'AUTO';
  String? _dropdown = 'ALPHA';
  int _navIndex = 0;
  int _step = 1;
  bool _showError = true;

  // Live-appending terminal: a Timer pushes a new log line periodically.
  final List<AurisTerminalLine> _log = <AurisTerminalLine>[
    const AurisTerminalLine('> boot sequence initiated', type: AurisTerminalLineType.augment),
    const AurisTerminalLine('  loading core modules ... ok', type: AurisTerminalLineType.ok),
  ];
  Timer? _logTimer;
  int _logTick = 0;

  static const List<AurisTerminalLine> _logSamples = <AurisTerminalLine>[
    AurisTerminalLine('  diagnostic pass complete', type: AurisTerminalLineType.ok),
    AurisTerminalLine('  telemetry uplink nominal'),
    AurisTerminalLine('! thermal margin low', type: AurisTerminalLineType.warning),
    AurisTerminalLine('  augment graft synced', type: AurisTerminalLineType.augment),
    AurisTerminalLine('x packet checksum mismatch', type: AurisTerminalLineType.error),
  ];

  @override
  void initState() {
    super.initState();
    _logTimer = Timer.periodic(const Duration(seconds: 2), (Timer _) {
      setState(() {
        final AurisTerminalLine sample =
            _logSamples[_logTick % _logSamples.length];
        _log.add(
          AurisTerminalLine(
            '${sample.text} [${_logTick.toString().padLeft(3, '0')}]',
            type: sample.type,
          ),
        );
        _logTick++;
        // Bound the buffer so the demo does not grow without limit.
        if (_log.length > 40) {
          _log.removeRange(0, _log.length - 40);
        }
      });
    });
  }

  @override
  void dispose() {
    _logTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme text = theme.textTheme;

    // Read the resolved scheme from the ThemeExtension to prove it resolves,
    // and drive the section headers and AppBar from its role colors.
    final AurisScheme scheme = theme.extension<AurisScheme>()!;

    return Scaffold(
      appBar: AppBar(
        title: Text('AURIS // CORE CONTROLS', style: text.titleLarge),
        backgroundColor: scheme.surfacePanel,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text('SYSTEM ONLINE', style: text.displaySmall),
                const SizedBox(height: 8),
                Text(
                  'Augmentation-era interface. Amber-on-near-black, chamfered '
                  'geometry, glow in place of drop shadow.',
                  style: text.bodyLarge,
                ),
                const SizedBox(height: 24),

                // ---- CUSTOMIZATION ------------------------------------------
                // Lifts the accent / bevel / glow overrides into the root theme
                // controller. Flipping any of these rebuilds AurisTheme.light,
                // and every section below recolors / re-shapes because it reads
                // the resolved scheme — no per-widget edits required
                // (§spec:customization, §road:customization-showcase).
                const _SectionHeader('CUSTOMIZATION'),
                _CustomizationControl(
                  accent: widget.accent,
                  bevelScale: widget.bevelScale,
                  glowScale: widget.glowScale,
                  brightness: widget.brightness,
                  onAccentChanged: widget.onAccentChanged,
                  onBevelChanged: widget.onBevelChanged,
                  onGlowChanged: widget.onGlowChanged,
                  onBrightnessChanged: widget.onBrightnessChanged,
                ),
                const SizedBox(height: 32),

                // ---- ACCESSIBILITY ------------------------------------------
                // Surfaces the two cross-cutting a11y behaviors for review:
                // the live reduced-motion state (driven by the OS setting via
                // MediaQuery.disableAnimations) and a prompt to tab through the
                // controls and watch the gold focus ring travel
                // (§spec:accessibility, §road:polish-showcase-verification).
                const _AccessibilityBanner(),
                const SizedBox(height: 32),

                // ---- BUTTONS -------------------------------------------------
                const _SectionHeader('BUTTONS'),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: FilledButton(
                        onPressed: () {},
                        child: const Text('ENGAGE'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {},
                        child: const Text('STANDBY'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {},
                        child: const Text('DIAGNOSTIC'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextButton(
                        onPressed: () {},
                        child: const Text('DETAILS'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: <Widget>[
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.power_settings_new),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.tune),
                    ),
                    const Spacer(),
                    FloatingActionButton(
                      onPressed: () {},
                      child: const Icon(Icons.add),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SegmentedButton<String>(
                  segments: const <ButtonSegment<String>>[
                    ButtonSegment<String>(value: 'AUTO', label: Text('AUTO')),
                    ButtonSegment<String>(value: 'MANUAL', label: Text('MAN')),
                    ButtonSegment<String>(value: 'OFF', label: Text('OFF')),
                  ],
                  selected: <String>{_segment},
                  showSelectedIcon: false,
                  onSelectionChanged: (Set<String> s) =>
                      setState(() => _segment = s.first),
                ),
                const SizedBox(height: 12),
                // Disabled variants — null onPressed dims to 50% with no hover.
                const Row(
                  children: <Widget>[
                    Expanded(
                      child: FilledButton(
                        onPressed: null,
                        child: Text('DISABLED'),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: null,
                        child: Text('DISABLED'),
                      ),
                    ),
                    SizedBox(width: 12),
                    IconButton(
                      onPressed: null,
                      icon: Icon(Icons.block),
                    ),
                  ],
                ),

                // ---- INPUTS --------------------------------------------------
                const _SectionHeader('INPUTS'),
                const TextField(
                  decoration: InputDecoration(
                    labelText: 'CALLSIGN',
                    hintText: 'Enter identifier',
                  ),
                ),
                const SizedBox(height: 16),
                const TextField(
                  obscureText: true,
                  // A hexagon mask glyph ties the obscured field to the kit's
                  // hex-ornament motif instead of a generic bullet.
                  obscuringCharacter: '⬡',
                  decoration: InputDecoration(
                    labelText: 'ACCESS KEY',
                    suffixIcon: Icon(Icons.lock_outline),
                  ),
                ),
                const SizedBox(height: 16),
                const TextField(
                  decoration: InputDecoration(
                    labelText: 'TARGET VECTOR',
                    errorText: 'OUT OF RANGE',
                  ),
                ),
                const SizedBox(height: 16),
                Text('CHANNEL', style: text.labelMedium),
                const SizedBox(height: 6),
                AurisSelect<String>(
                  value: _dropdown,
                  onChanged: (String v) => setState(() => _dropdown = v),
                  options: const <AurisSelectOption<String>>[
                    AurisSelectOption<String>(value: 'ALPHA', label: 'ALPHA'),
                    AurisSelectOption<String>(value: 'BRAVO', label: 'BRAVO'),
                    AurisSelectOption<String>(
                      value: 'CHARLIE',
                      label: 'CHARLIE',
                    ),
                  ],
                ),

                // ---- SELECTION CONTROLS -------------------------------------
                const _SectionHeader('SELECTION CONTROLS'),
                Row(
                  children: <Widget>[
                    Checkbox(
                      value: _checkbox,
                      onChanged: (bool? v) =>
                          setState(() => _checkbox = v ?? false),
                    ),
                    Text('PRIMARY LINK', style: text.bodyMedium),
                    const SizedBox(width: 16),
                    Checkbox(
                      value: _checkboxOff,
                      onChanged: (bool? v) =>
                          setState(() => _checkboxOff = v ?? false),
                    ),
                    Text('BACKUP', style: text.bodyMedium),
                    const SizedBox(width: 16),
                    const Checkbox(value: true, onChanged: null),
                    Text('LOCKED', style: text.bodyMedium),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 20,
                  runSpacing: 8,
                  children: <Widget>[
                    AurisRadio<int>(
                      value: 0,
                      groupValue: _radio,
                      onChanged: (int v) => setState(() => _radio = v),
                      label: 'LOW',
                    ),
                    AurisRadio<int>(
                      value: 1,
                      groupValue: _radio,
                      onChanged: (int v) => setState(() => _radio = v),
                      label: 'HIGH',
                    ),
                    AurisRadio<int>(
                      value: 2,
                      groupValue: _radio,
                      onChanged: null,
                      label: 'DISABLED',
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 20,
                  runSpacing: 8,
                  children: <Widget>[
                    AurisSwitch(
                      value: _switch,
                      onChanged: (bool v) => setState(() => _switch = v),
                      label: 'SHIELDS',
                    ),
                    AurisSwitch(
                      value: _switchOff,
                      onChanged: (bool v) => setState(() => _switchOff = v),
                      label: 'CLOAK',
                    ),
                    const AurisSwitch(value: false, onChanged: null, label: 'AUX'),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: <Widget>[
                    for (final String label in <String>[
                      'CORE',
                      'SENSORS',
                      'COMMS',
                      'NAV',
                    ])
                      FilterChip(
                        label: Text(label),
                        selected: _chips.contains(label),
                        onSelected: (bool on) => setState(() {
                          if (on) {
                            _chips.add(label);
                          } else {
                            _chips.remove(label);
                          }
                        }),
                      ),
                    const Chip(label: Text('OFFLINE')),
                  ],
                ),

                // ---- SLIDERS -------------------------------------------------
                const _SectionHeader('SLIDERS'),
                Text('THROTTLE', style: text.labelMedium),
                Slider(
                  value: _slider,
                  onChanged: (double v) => setState(() => _slider = v),
                ),
                const SizedBox(height: 8),
                Text('POWER ALLOCATION', style: text.labelMedium),
                Slider(
                  value: _sliderStepped,
                  min: 0,
                  max: 100,
                  divisions: 10,
                  label: '${_sliderStepped.round()}%',
                  onChanged: (double v) => setState(() => _sliderStepped = v),
                ),
                const SizedBox(height: 8),
                Text('LOCKED (DISABLED)', style: text.labelMedium),
                const Slider(value: 0.6, onChanged: null),

                // ---- CARDS & PANELS -----------------------------------------
                const _SectionHeader('CARDS & PANELS'),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('REACTOR CORE', style: text.titleMedium),
                        const SizedBox(height: 8),
                        Text(
                          'Chamfered panel surface with a resting outline in '
                          'place of a Material drop shadow.',
                          style: text.bodyMedium,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: <Widget>[
                            const Badge(label: Text('NOMINAL')),
                            const SizedBox(width: 12),
                            Tooltip(
                              message: 'STABLE',
                              child: Icon(
                                Icons.shield_outlined,
                                color: scheme.primaryActive,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // ---- OVERLAYS -----------------------------------------------
                const _SectionHeader('OVERLAYS'),
                Text(
                  'Trigger overlays — none are pre-opened.',
                  style: text.bodyMedium,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: <Widget>[
                    OutlinedButton(
                      onPressed: _showDialog,
                      child: const Text('DIALOG'),
                    ),
                    OutlinedButton(
                      onPressed: _showSnackBar,
                      child: const Text('SNACKBAR'),
                    ),
                    OutlinedButton(
                      onPressed: _showBottomSheet,
                      child: const Text('SHEET'),
                    ),
                    PopupMenuButton<String>(
                      tooltip: 'MENU',
                      icon: const Icon(Icons.more_vert),
                      itemBuilder: (BuildContext context) =>
                          const <PopupMenuEntry<String>>[
                        PopupMenuItem<String>(
                          value: 'ARM',
                          child: Text('ARM'),
                        ),
                        PopupMenuItem<String>(
                          value: 'DISARM',
                          child: Text('DISARM'),
                        ),
                        PopupMenuItem<String>(
                          value: 'RESET',
                          child: Text('RESET'),
                        ),
                      ],
                    ),
                  ],
                ),

                // ---- NAVIGATION ---------------------------------------------
                const _SectionHeader('NAVIGATION'),
                Text('TAB BAR', style: text.labelMedium),
                const SizedBox(height: 8),
                DefaultTabController(
                  length: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      const TabBar(
                        tabs: <Widget>[
                          Tab(text: 'STATUS'),
                          Tab(text: 'POWER'),
                          Tab(text: 'COMMS'),
                        ],
                      ),
                      SizedBox(
                        height: 64,
                        child: TabBarView(
                          children: <Widget>[
                            Center(
                              child: Text('ALL SYSTEMS NOMINAL',
                                  style: text.bodyMedium),
                            ),
                            Center(
                              child: Text('REACTOR AT 82%',
                                  style: text.bodyMedium),
                            ),
                            Center(
                              child: Text('UPLINK ESTABLISHED',
                                  style: text.bodyMedium),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text('NAVIGATION BAR', style: text.labelMedium),
                const SizedBox(height: 8),
                NavigationBar(
                  selectedIndex: _navIndex,
                  onDestinationSelected: (int i) =>
                      setState(() => _navIndex = i),
                  destinations: const <NavigationDestination>[
                    NavigationDestination(
                      icon: Icon(Icons.dashboard_outlined),
                      selectedIcon: Icon(Icons.dashboard),
                      label: 'HUD',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.sensors_outlined),
                      selectedIcon: Icon(Icons.sensors),
                      label: 'SENSORS',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.settings_outlined),
                      selectedIcon: Icon(Icons.settings),
                      label: 'CONFIG',
                    ),
                  ],
                ),

                // ---- DATA ----------------------------------------------------
                const _SectionHeader('DATA'),
                Text('DATA TABLE', style: text.labelMedium),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  // Clip the table to the chamfer so the heading / selected-row
                  // fills don't poke past the cut corners of the frame.
                  child: ClipPath(
                    clipper: ChamferClipper(cut: scheme.bevel.md),
                    child: DataTable(
                      columns: const <DataColumn>[
                        DataColumn(label: Text('NODE')),
                        DataColumn(label: Text('LOAD')),
                        DataColumn(label: Text('STATE')),
                      ],
                      rows: const <DataRow>[
                        DataRow(
                          cells: <DataCell>[
                            DataCell(Text('ALPHA')),
                            DataCell(Text('42%')),
                            DataCell(Text('ONLINE')),
                          ],
                        ),
                        DataRow(
                          cells: <DataCell>[
                            DataCell(Text('BRAVO')),
                            DataCell(Text('77%')),
                            DataCell(Text('ONLINE')),
                          ],
                        ),
                        DataRow(
                          selected: true,
                          cells: <DataCell>[
                            DataCell(Text('CHARLIE')),
                            DataCell(Text('98%')),
                            DataCell(Text('CRITICAL')),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text('LIST TILES', style: text.labelMedium),
                const SizedBox(height: 8),
                ListTile(
                  leading: const Icon(Icons.memory),
                  title: const Text('PRIMARY BUS'),
                  subtitle: const Text('Voltage nominal'),
                  trailing: const Text('12.4V'),
                  onTap: () {},
                ),
                ListTile(
                  selected: true,
                  leading: const Icon(Icons.bolt),
                  title: const Text('AUX BUS'),
                  subtitle: const Text('Selected'),
                  trailing: const Text('5.0V'),
                  onTap: () {},
                ),
                const SizedBox(height: 8),
                ExpansionTile(
                  title: const Text('DIAGNOSTICS'),
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'No faults detected across 14 subsystems.',
                        style: text.bodyMedium,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text('PROGRESS', style: text.labelMedium),
                const SizedBox(height: 8),
                const AurisProgressBar(value: 0.66),
                const SizedBox(height: 12),
                Row(
                  children: <Widget>[
                    const SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(strokeWidth: 3),
                    ),
                    const SizedBox(width: 16),
                    Text('SYNCING…', style: text.bodyMedium),
                  ],
                ),
                const SizedBox(height: 16),
                Text('BADGES', style: text.labelMedium),
                const SizedBox(height: 8),
                Row(
                  children: <Widget>[
                    Badge(
                      label: const Text('3'),
                      child: Icon(
                        Icons.notifications_outlined,
                        color: scheme.primaryActive,
                      ),
                    ),
                    const SizedBox(width: 24),
                    const Badge(
                      label: Text('SYNC'),
                      child: Icon(Icons.cloud_outlined),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text('STEPPER', style: text.labelMedium),
                const SizedBox(height: 8),
                SizedBox(
                  height: 280,
                  child: Stepper(
                    currentStep: _step,
                    // Replace Material's default round step icons with the
                    // chamfered AurisStepIndicator so the stepper matches the
                    // HUD aesthetic (§spec:custom-widgets).
                    stepIconBuilder: (int stepIndex, StepState state) {
                      final AurisStepState s = switch (state) {
                        StepState.complete => AurisStepState.complete,
                        StepState.error => AurisStepState.error,
                        _ => stepIndex == _step
                            ? AurisStepState.active
                            : AurisStepState.inactive,
                      };
                      return AurisStepIndicator(
                        step: stepIndex + 1,
                        state: s,
                        size: 24,
                      );
                    },
                    onStepTapped: (int s) => setState(() => _step = s),
                    controlsBuilder: (BuildContext context,
                        ControlsDetails details) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Row(
                          children: <Widget>[
                            FilledButton(
                              onPressed: details.onStepContinue,
                              child: const Text('NEXT'),
                            ),
                            const SizedBox(width: 8),
                            TextButton(
                              onPressed: details.onStepCancel,
                              child: const Text('BACK'),
                            ),
                          ],
                        ),
                      );
                    },
                    onStepContinue: () => setState(
                        () => _step = (_step + 1).clamp(0, 2)),
                    onStepCancel: () => setState(
                        () => _step = (_step - 1).clamp(0, 2)),
                    steps: const <Step>[
                      Step(
                        title: Text('CALIBRATE'),
                        content: Text('Align sensors.'),
                        state: StepState.complete,
                        isActive: true,
                      ),
                      Step(
                        title: Text('PRIME'),
                        content: Text('Spin up the reactor.'),
                        isActive: true,
                      ),
                      Step(
                        title: Text('ENGAGE'),
                        content: Text('Commit to launch.'),
                      ),
                    ],
                  ),
                ),

                // ---- BADGES (CUSTOM) ----------------------------------------
                const _SectionHeader('BADGES (HUD)'),
                const Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: <Widget>[
                    AurisBadge('ONLINE', variant: AurisBadgeVariant.success),
                    AurisBadge('ARMED', variant: AurisBadgeVariant.gold),
                    AurisBadge('SYNC', variant: AurisBadgeVariant.amber),
                    AurisBadge('LINK', variant: AurisBadgeVariant.slate),
                    AurisBadge('FAULT', variant: AurisBadgeVariant.danger),
                    AurisBadge('OFFLINE', variant: AurisBadgeVariant.inactive),
                  ],
                ),

                // ---- PANELS -------------------------------------------------
                const _SectionHeader('PANELS'),
                const AurisPanel(
                  title: 'Reactor Core',
                  code: 'SYS-01',
                  child: Text(
                    'Chamfered titled panel with bracket-flanked header and a '
                    'status code.',
                  ),
                ),
                const SizedBox(height: 16),
                const AurisPanel(
                  title: 'Priority Channel',
                  code: 'ACCENT',
                  accent: true,
                  child: Text(
                    'Accent mode: gold border and a subtle glow mark this panel '
                    'as emphasized.',
                  ),
                ),

                // ---- NOTIFICATIONS ------------------------------------------
                const _SectionHeader('NOTIFICATIONS'),
                const AurisNotification(
                  title: 'Uplink Established',
                  message: 'Telemetry stream is nominal.',
                  variant: AurisNotificationVariant.info,
                ),
                const SizedBox(height: 12),
                const AurisNotification(
                  title: 'Calibration Complete',
                  message: 'All 14 subsystems passed.',
                  variant: AurisNotificationVariant.success,
                ),
                const SizedBox(height: 12),
                const AurisNotification(
                  title: 'Power Reserve Low',
                  message: 'Auxiliary cells at 18%.',
                  code: 'W-204',
                  variant: AurisNotificationVariant.warning,
                ),
                const SizedBox(height: 12),
                if (_showError)
                  AurisNotification(
                    title: 'Containment Breach',
                    message: 'Sector 7 isolation failed.',
                    code: 'E-911',
                    variant: AurisNotificationVariant.error,
                    onDismiss: () => setState(() => _showError = false),
                  )
                else
                  OutlinedButton(
                    onPressed: () => setState(() => _showError = true),
                    child: const Text('RESTORE ALERT'),
                  ),

                // ---- DATA ROWS ----------------------------------------------
                const _SectionHeader('DATA ROWS'),
                const AurisDataRow(label: 'Core Temp', value: '412 K'),
                const AurisDataRow(label: 'Output', value: '82.4 MW'),
                const AurisDataRow(
                  label: 'Field Strength',
                  value: 'CRITICAL',
                  highlight: true,
                ),
                const AurisDataRow(
                  label: 'Coolant Loop',
                  value: 'NOMINAL',
                  trailing: AurisBadge(
                    'OK',
                    variant: AurisBadgeVariant.success,
                  ),
                ),

                // ---- STAT CARDS ---------------------------------------------
                const _SectionHeader('STAT CARDS'),
                const Row(
                  children: <Widget>[
                    Expanded(
                      child: AurisStatCard(
                        label: 'Throughput',
                        value: '94.2',
                        unit: 'GB/s',
                        delta: '+2.4%',
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: AurisStatCard(
                        label: 'Latency',
                        value: '12',
                        unit: 'ms',
                        delta: '-3.1%',
                        deltaPositiveIsGood: false,
                      ),
                    ),
                  ],
                ),

                // ---- ORNAMENTS ----------------------------------------------
                const _SectionHeader('ORNAMENTS'),
                Text('HEX CLUSTER', style: text.labelMedium),
                const SizedBox(height: 8),
                const SizedBox(
                  height: 96,
                  width: double.infinity,
                  child: AurisHexOrnament(),
                ),
                const SizedBox(height: 16),
                Text('SCAN BRACKET', style: text.labelMedium),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    AurisScanBracket(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text('TARGET', style: text.bodyMedium),
                      ),
                    ),
                    AurisScanBracket(
                      pulse: true,
                      color: scheme.dangerBright,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text('LOCK', style: text.bodyMedium),
                      ),
                    ),
                  ],
                ),

                // ---- SWITCHES -----------------------------------------------
                const _SectionHeader('SWITCHES'),
                AurisSwitch(
                  value: _aurisSwitch,
                  label: 'Primary reactor',
                  statusLabels: const ('OFFLINE', 'ONLINE'),
                  onChanged: (bool v) => setState(() => _aurisSwitch = v),
                ),
                const SizedBox(height: 16),
                AurisSwitch(
                  value: _aurisSwitchAlt,
                  label: 'Auto-stabilizer',
                  statusLabels: const ('MANUAL', 'AUTO'),
                  onChanged: (bool v) => setState(() => _aurisSwitchAlt = v),
                ),
                const SizedBox(height: 16),
                const AurisSwitch(
                  value: true,
                  label: 'Locked override',
                  statusLabels: ('OFF', 'ON'),
                  onChanged: null,
                ),

                // ---- PROGRESS -----------------------------------------------
                const _SectionHeader('PROGRESS'),
                AurisProgressBar.animated(
                  value: _progress,
                  label: 'SHIELD INTEGRITY',
                  valueLabel: '${(_progress * 100).round()} / 100',
                ),
                const SizedBox(height: 16),
                const AurisProgressBar(
                  value: 0.7,
                  label: 'COOLANT (SECONDARY)',
                  valueLabel: '70 / 100',
                  variant: AurisProgressVariant.secondary,
                ),
                const SizedBox(height: 16),
                const AurisProgressBar(
                  value: 0.92,
                  label: 'CORE TEMP (CRITICAL)',
                  valueLabel: '92 / 100',
                  variant: AurisProgressVariant.danger,
                ),
                const SizedBox(height: 12),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Slider(
                        value: _progress,
                        onChanged: (double v) =>
                            setState(() => _progress = v),
                      ),
                    ),
                  ],
                ),

                // ---- TERMINAL -----------------------------------------------
                const _SectionHeader('TERMINAL'),
                AurisTerminal(
                  title: 'SYSTEM LOG',
                  code: 'LIVE',
                  lines: _log,
                ),

                // ---- SELECT -------------------------------------------------
                const _SectionHeader('SELECT'),
                AurisSelect<String>(
                  value: _aurisSelect,
                  placeholder: 'CHOOSE CHANNEL',
                  options: const <AurisSelectOption<String>>[
                    AurisSelectOption<String>(value: 'alpha', label: 'Alpha'),
                    AurisSelectOption<String>(value: 'beta', label: 'Beta'),
                    AurisSelectOption<String>(value: 'gamma', label: 'Gamma'),
                    AurisSelectOption<String>(value: 'delta', label: 'Delta'),
                  ],
                  onChanged: (String v) => setState(() => _aurisSelect = v),
                ),

                // ---- STEP INDICATOR -----------------------------------------
                const _SectionHeader('STEP INDICATOR'),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    AurisStepIndicator(
                      step: 1,
                      state: AurisStepState.complete,
                    ),
                    AurisStepIndicator(step: 2, state: AurisStepState.active),
                    AurisStepIndicator(step: 3, state: AurisStepState.inactive),
                    AurisStepIndicator(step: 4, state: AurisStepState.error),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Open a chamfered, flat dialog (theme-driven; no per-call styling).
  Future<void> _showDialog() {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('CONFIRM LAUNCH'),
          content: const Text(
            'This commits the sequence and cannot be aborted.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('CANCEL'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('LAUNCH'),
            ),
          ],
        );
      },
    );
  }

  /// Show a chamfered, flat snackbar with a gold action.
  void _showSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('SEQUENCE ARMED'),
        action: SnackBarAction(label: 'UNDO', onPressed: () {}),
      ),
    );
  }

  /// Open a chamfered, flat modal bottom sheet.
  Future<void> _showBottomSheet() {
    return showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        final TextTheme text = Theme.of(context).textTheme;
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('TELEMETRY', style: text.titleMedium),
              const SizedBox(height: 12),
              Text(
                'A chamfered modal sheet on the panel surface.',
                style: text.bodyMedium,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('CLOSE'),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// The on-theme control that drives the live accent / bevel / glow overrides.
///
/// Accent is a row of chamfered swatch chips (default amber plus three
/// alternates); bevel and glow are TIGHT / NORMAL / BOLD segmented toggles.
/// The control itself is built from themed widgets, so it re-skins along with
/// everything else when the accent flips. It reports changes upward — it holds
/// no theme state of its own.
class _CustomizationControl extends StatelessWidget {
  const _CustomizationControl({
    required this.accent,
    required this.bevelScale,
    required this.glowScale,
    required this.brightness,
    required this.onAccentChanged,
    required this.onBevelChanged,
    required this.onGlowChanged,
    required this.onBrightnessChanged,
  });

  final Color? accent;
  final double bevelScale;
  final double glowScale;
  final Brightness brightness;
  final ValueChanged<Color?> onAccentChanged;
  final ValueChanged<double> onBevelChanged;
  final ValueChanged<double> onGlowChanged;
  final ValueChanged<Brightness> onBrightnessChanged;

  @override
  Widget build(BuildContext context) {
    final AurisScheme scheme = Theme.of(context).extension<AurisScheme>()!;
    final TextTheme text = Theme.of(context).textTheme;

    Widget label(String s) => Text(s, style: text.labelMedium);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        label('MODE'),
        const SizedBox(height: 8),
        SegmentedButton<Brightness>(
          showSelectedIcon: false,
          segments: const <ButtonSegment<Brightness>>[
            ButtonSegment<Brightness>(
              value: Brightness.dark,
              label: Text('DARK'),
            ),
            ButtonSegment<Brightness>(
              value: Brightness.light,
              label: Text('LIGHT'),
            ),
          ],
          selected: <Brightness>{brightness},
          onSelectionChanged: (Set<Brightness> s) =>
              onBrightnessChanged(s.first),
        ),
        const SizedBox(height: 16),
        label('ACCENT'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            for (final _AccentOption option in _accentOptions)
              _AccentSwatch(
                option: option,
                selected: option.color == accent,
                onTap: () => onAccentChanged(option.color),
              ),
          ],
        ),
        const SizedBox(height: 16),
        label('BEVEL'),
        const SizedBox(height: 8),
        _ScalePicker(
          value: bevelScale,
          onChanged: onBevelChanged,
        ),
        const SizedBox(height: 16),
        Row(
          children: <Widget>[
            label('GLOW'),
            const SizedBox(width: 12),
            Text(
              '${glowScale.toStringAsFixed(1)}×',
              style: TextStyle(
                fontFamily: AurisTokens.fontMono,
                fontSize: 12,
                color: scheme.primaryActive,
              ),
            ),
          ],
        ),
        // Glow is a continuous scalar (0 = none, 3 = strong), unlike the stepped
        // bevel control, so its effect can be dialled and watched on the tile.
        Slider(
          value: glowScale,
          max: 3,
          onChanged: onGlowChanged,
        ),
        const SizedBox(height: 8),
        // A live preview tile so the three knobs are legible on their own,
        // without scrolling to find a glowing/chamfered element: its corner cut
        // tracks BEVEL, its fill + glow tint track ACCENT, and the halo size
        // tracks GLOW. The tile is a solid accent fill with NO border so the
        // glow halo is not visually swallowed by a same-coloured outline.
        Row(
          children: <Widget>[
            AurisContainer(
              cut: scheme.bevel.lg,
              width: 96,
              height: 56,
              fill: scheme.primaryActive,
              borderWidth: 0,
              depth: scheme.depthActive,
              alignment: Alignment.center,
              child: Text(
                'PREVIEW',
                style: TextStyle(
                  fontFamily: AurisTokens.fontMono,
                  fontSize: 11,
                  letterSpacing: AurisTokens.trackingLabel,
                  color: scheme.onPrimary,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Flip any control — the tile and every section below recolor '
                'and re-shape from the resolved scheme.',
                style: text.bodySmall?.copyWith(color: scheme.textMid),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// A single chamfered accent swatch: a colored chip that selects its accent.
class _AccentSwatch extends StatelessWidget {
  const _AccentSwatch({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final _AccentOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AurisScheme scheme = Theme.of(context).extension<AurisScheme>()!;
    // The swatch shows the accent it actually selects — the RESOLVED active
    // rung, not the raw literal. Resolving each option's accent fresh for the
    // current brightness means the chip reflects the same correction the kit
    // applies on selection: bright on dark, but darkened-for-AA on light (so a
    // teal/magenta/green chip shows the deep variant it really becomes, and AMBER
    // shows the canonical bronze). Without this the chips advertise the bright
    // literals while selecting them yields the deeper contrast-corrected color.
    final Color swatch = AurisScheme.resolve(
      brightness: Theme.of(context).brightness,
      accent: option.color,
    ).primaryActive;

    return GestureDetector(
      onTap: onTap,
      child: AurisContainer(
        cut: scheme.bevel.sm,
        fill: scheme.surfaceInset,
        borderColor: selected ? scheme.primaryActive : scheme.borderBright,
        depth: selected ? scheme.depthActive : null,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            AurisContainer(
              cut: 2,
              width: 14,
              height: 14,
              fill: swatch,
            ),
            const SizedBox(width: 8),
            Text(
              option.label,
              style: TextStyle(
                fontFamily: AurisTokens.fontMono,
                fontSize: 12,
                letterSpacing: AurisTokens.trackingLabel,
                color: selected ? scheme.textBright : scheme.textMid,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A TIGHT / NORMAL / BOLD segmented toggle for a scale override.
class _ScalePicker extends StatelessWidget {
  const _ScalePicker({required this.value, required this.onChanged});

  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<double>(
      showSelectedIcon: false,
      segments: <ButtonSegment<double>>[
        for (final _ScaleStep step in _scaleSteps)
          ButtonSegment<double>(value: step.value, label: Text(step.label)),
      ],
      selected: <double>{value},
      onSelectionChanged: (Set<double> s) => onChanged(s.first),
    );
  }
}

/// A monospace, uppercase, amber section header per §spec:showcase. Reads its
/// color from the resolved [AurisScheme] so it tracks accent / brightness.
class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final AurisScheme scheme =
        Theme.of(context).extension<AurisScheme>()!;
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontFamily: AurisTokens.fontMono,
              fontSize: 13,
              letterSpacing: AurisTokens.trackingLabel,
              color: scheme.primaryDim,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 1,
              color: scheme.borderResting,
            ),
          ),
        ],
      ),
    );
  }
}

/// An on-theme banner that makes the two cross-cutting accessibility behaviors
/// demonstrable in the showcase (§road:polish-showcase-verification):
///
/// - It reads the live `MediaQuery.disableAnimations` (the OS reduce-motion
///   setting) and reports the current state, so a reviewer can toggle the OS
///   setting, reload, and see the showcase honor it (animated widgets render
///   their end state).
/// - It prompts the reviewer to Tab through the controls and watch the gold
///   focus ring travel across every interactive element.
class _AccessibilityBanner extends StatelessWidget {
  const _AccessibilityBanner();

  @override
  Widget build(BuildContext context) {
    final bool reduceMotion = MediaQuery.disableAnimationsOf(context);
    return AurisNotification(
      title: 'ACCESSIBILITY',
      code: reduceMotion ? 'MOTION:REDUCED' : 'MOTION:FULL',
      variant: reduceMotion
          ? AurisNotificationVariant.success
          : AurisNotificationVariant.info,
      message: reduceMotion
          ? 'Reduced motion is ON (OS setting): animations render their end '
              'state with no running controllers. Press Tab to move the gold '
              'focus ring across the controls below.'
          : 'Reduced motion is OFF. Enable your OS reduce-motion setting and '
              'reload to see animations snap to their end state. Press Tab to '
              'move the gold focus ring across the controls below.',
    );
  }
}
