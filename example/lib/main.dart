import 'package:auris/auris.dart';
import 'package:auris/auris_widgets.dart';
import 'package:flutter/material.dart';

void main() => runApp(const AurisExampleApp());

/// The showcase: a scrollable app that applies [AurisTheme.light] and renders
/// the re-skinned Material widgets — buttons, inputs, selection controls and
/// sliders; surfaces and overlays (cards, dialog, snackbar, bottom sheet,
/// tooltip, popup menu); navigation chrome (tab bar, navigation bar); and
/// data / feedback widgets (data table, list / expansion tile, progress, badge,
/// stepper) — each section introduced by a monospace uppercase amber header
/// (§spec:showcase).
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
  int _navIndex = 0;
  int _step = 1;
  bool _showError = true;

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
                DropdownMenu<String>(
                  initialSelection: _dropdown,
                  label: const Text('CHANNEL'),
                  expandedInsets: EdgeInsets.zero,
                  onSelected: (String? v) => setState(() => _dropdown = v),
                  dropdownMenuEntries: const <DropdownMenuEntry<String>>[
                    DropdownMenuEntry<String>(value: 'ALPHA', label: 'ALPHA'),
                    DropdownMenuEntry<String>(value: 'BRAVO', label: 'BRAVO'),
                    DropdownMenuEntry<String>(
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
                const LinearProgressIndicator(value: 0.66),
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
