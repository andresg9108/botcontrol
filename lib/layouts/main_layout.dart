import 'dart:async';

import 'package:flutter/material.dart';

import '../controllers/robot_controller.dart';
import '../controllers/settings_controller.dart';
import '../controllers/tilt_steering_controller.dart';
import '../screens/control_screen.dart';
import '../screens/instructions_screen.dart';
import '../screens/settings_screen.dart';
import '../theme/app_colors.dart';
import '../widgets/connection_status.dart';
import '../widgets/device_picker.dart';

enum _MainPage { control, instructions, settings }

class MainLayout extends StatefulWidget {
  const MainLayout({
    super.key,
    this.controller,
    this.settings,
    this.tiltSamples,
  });

  final RobotController? controller;
  final SettingsController? settings;
  final Stream<TiltSample>? tiltSamples;

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> with WidgetsBindingObserver {
  late final robot = widget.controller ?? RobotController();
  late final settings = widget.settings ?? SettingsController();
  var _page = _MainPage.control;
  bool _foreground = true;
  bool _drawerOpen = false;
  bool _modalOpen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    settings.addListener(_settingsChanged);
    robot.setAccelerometerEnabled(settings.accelerometerEnabled);
    if (!settings.loaded) unawaited(settings.load());
  }

  void _settingsChanged() {
    robot.setAccelerometerEnabled(settings.accelerometerEnabled);
    if (mounted) setState(() {});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) robot.stop();
    setState(() => _foreground = state == AppLifecycleState.resumed);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    settings.removeListener(_settingsChanged);
    if (widget.settings == null) settings.dispose();
    if (widget.controller == null) {
      robot.dispose();
    } else {
      robot.stop();
    }
    super.dispose();
  }

  void _selectPage(_MainPage page) {
    robot.stop();
    setState(() => _page = page);
    Navigator.pop(context);
  }

  Future<void> _showDevices() async {
    robot.stop();
    setState(() => _modalOpen = true);
    unawaited(robot.search());
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => ListenableBuilder(
        listenable: robot,
        builder: (context, _) => DevicePicker(
          devices: robot.devices,
          scanning: robot.scanning,
          error: robot.error,
          onSearch: robot.search,
          onSelected: (device) {
            Navigator.pop(context);
            unawaited(robot.connect(device));
          },
        ),
      ),
    );
    await robot.stopSearch();
    if (mounted) setState(() => _modalOpen = false);
  }

  Future<void> _showTurnIntensity() async {
    robot.stop();
    setState(() => _modalOpen = true);
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ListenableBuilder(
            listenable: robot,
            builder: (context, _) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Intensidad de giro · ${robot.manualTurnPercent} %',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Se aplica a IZQUIERDA y DERECHA, tanto al avanzar como al retroceder. 0 % sigue recto; 100 % deja sin potencia el lado interior.',
                  style: TextStyle(color: AppColors.muted, height: 1.5),
                ),
                Slider(
                  value: robot.manualTurnPercent.toDouble(),
                  max: 100,
                  divisions: 20,
                  label: '${robot.manualTurnPercent} %',
                  semanticFormatterCallback: (value) =>
                      'Intensidad de giro: ${value.round()} por ciento',
                  onChanged: (value) =>
                      robot.setManualTurnPercent(value.round()),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Listo'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (mounted) setState(() => _modalOpen = false);
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: robot,
    builder: (context, _) => Scaffold(
      appBar: AppBar(
        toolbarHeight: 56,
        actions: [
          if (_page == _MainPage.control && !settings.accelerometerEnabled)
            IconButton(
              tooltip: 'Intensidad de giro: ${robot.manualTurnPercent} %',
              onPressed: _showTurnIntensity,
              icon: const Icon(Icons.tune_rounded),
            ),
        ],
        title: Text(switch (_page) {
          _MainPage.control => 'agbot · Control',
          _MainPage.instructions => 'Instrucciones',
          _MainPage.settings => 'Configuraciones',
        }, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
      ),
      onDrawerChanged: (open) {
        if (open) robot.stop();
        setState(() => _drawerOpen = open);
      },
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: [
              const Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.settings_remote_rounded,
                      color: AppColors.accent,
                      size: 36,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'agbot',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'CONTROL REMOTO · BLE',
                      style: TextStyle(
                        color: AppColors.muted,
                        fontSize: 12,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ConnectionStatus(
                  connected: robot.connected,
                  connecting: robot.connecting,
                  deviceName: robot.deviceName,
                  onConnect: () {
                    Navigator.pop(context);
                    unawaited(_showDevices());
                  },
                  onDisconnect: robot.disconnect,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.sports_esports_outlined),
                title: const Text('Control'),
                selected: _page == _MainPage.control,
                selectedColor: AppColors.accent,
                onTap: () => _selectPage(_MainPage.control),
              ),
              ListTile(
                leading: const Icon(Icons.menu_book_outlined),
                title: const Text('Instrucciones'),
                selected: _page == _MainPage.instructions,
                selectedColor: AppColors.accent,
                onTap: () => _selectPage(_MainPage.instructions),
              ),
              const Divider(indent: 16, endIndent: 16),
              ListTile(
                leading: const Icon(Icons.settings_outlined),
                title: const Text('Configuraciones'),
                selected: _page == _MainPage.settings,
                selectedColor: AppColors.accent,
                onTap: () => _selectPage(_MainPage.settings),
              ),
              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: switch (_page) {
          _MainPage.control => ControlScreen(
            controller: robot,
            accelerometerEnabled: settings.accelerometerEnabled,
            active: _foreground && !_drawerOpen && !_modalOpen,
            tiltSamples: widget.tiltSamples,
          ),
          _MainPage.instructions => const InstructionsScreen(),
          _MainPage.settings => SettingsScreen(
            settings: settings,
            onChanged: (enabled) {
              robot.stop();
              unawaited(settings.setAccelerometerEnabled(enabled));
            },
          ),
        },
      ),
    ),
  );
}
