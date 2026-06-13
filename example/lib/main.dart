import 'package:auris/auris.dart';
import 'package:flutter/material.dart';

void main() => runApp(const AurisExampleApp());

/// The core-controls showcase: a scrollable app that applies [AurisTheme.light]
/// and renders every re-skinned core control — buttons (all variants incl.
/// disabled), inputs (text, password, error, dropdown), selection controls
/// (checkbox, radio, switch, chip), and sliders — each section introduced by a
/// monospace uppercase amber header (§spec:showcase).
class AurisExampleApp extends StatelessWidget {
  const AurisExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Auris — Core Controls',
      debugShowCheckedModeBanner: false,
      theme: AurisTheme.light(),
      home: const _ShowcaseScreen(),
    );
  }
}

class _ShowcaseScreen extends StatefulWidget {
  const _ShowcaseScreen();

  @override
  State<_ShowcaseScreen> createState() => _ShowcaseScreenState();
}

class _ShowcaseScreenState extends State<_ShowcaseScreen> {
  bool _checkbox = true;
  bool _checkboxOff = false;
  int _radio = 0;
  bool _switch = true;
  bool _switchOff = false;
  double _slider = 0.4;
  double _sliderStepped = 30;
  final Set<String> _chips = <String>{'CORE'};
  String _segment = 'AUTO';
  String? _dropdown = 'ALPHA';

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
                DropdownButtonFormField<String>(
                  initialValue: _dropdown,
                  decoration: const InputDecoration(labelText: 'CHANNEL'),
                  items: const <DropdownMenuItem<String>>[
                    DropdownMenuItem<String>(
                      value: 'ALPHA',
                      child: Text('ALPHA'),
                    ),
                    DropdownMenuItem<String>(
                      value: 'BRAVO',
                      child: Text('BRAVO'),
                    ),
                    DropdownMenuItem<String>(
                      value: 'CHARLIE',
                      child: Text('CHARLIE'),
                    ),
                  ],
                  onChanged: (String? v) => setState(() => _dropdown = v),
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
                RadioGroup<int>(
                  groupValue: _radio,
                  onChanged: (int? v) => setState(() => _radio = v ?? 0),
                  child: Row(
                    children: <Widget>[
                      const Radio<int>(value: 0),
                      Text('LOW', style: text.bodyMedium),
                      const Radio<int>(value: 1),
                      Text('HIGH', style: text.bodyMedium),
                      const Radio<int>(value: 2, enabled: false),
                      Text('DISABLED', style: text.bodyMedium),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: <Widget>[
                    Switch(
                      value: _switch,
                      onChanged: (bool v) => setState(() => _switch = v),
                    ),
                    Text('SHIELDS', style: text.bodyMedium),
                    const SizedBox(width: 16),
                    Switch(
                      value: _switchOff,
                      onChanged: (bool v) => setState(() => _switchOff = v),
                    ),
                    Text('CLOAK', style: text.bodyMedium),
                    const SizedBox(width: 16),
                    const Switch(value: false, onChanged: null),
                    Text('AUX', style: text.bodyMedium),
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
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
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
