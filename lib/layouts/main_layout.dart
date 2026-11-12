import 'dart:async';

import 'package:flutter/material.dart';

import '../controllers/robot_controller.dart';
import '../screens/control_screen.dart';
import '../screens/instructions_screen.dart';
import '../theme/app_colors.dart';
import '../widgets/connection_status.dart';
import '../widgets/device_picker.dart';

enum _MainPage { control, instructions }

class MainLayout extends StatefulWidget {
  const MainLayout({super.key, this.controller});

  final RobotController? controller;

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> with WidgetsBindingObserver {
  late final robot = widget.controller ?? RobotController();
  var _page = _MainPage.control;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) robot.stop();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
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
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: robot,
    builder: (context, _) => Scaffold(
      appBar: AppBar(
        toolbarHeight: 48,
        title: Text(
          _page == _MainPage.control ? 'agbot · Control' : 'Instrucciones',
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
      ),
      onDrawerChanged: (open) {
        if (open) robot.stop();
      },
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'agbot',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
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
              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: _page == _MainPage.control
            ? ControlScreen(controller: robot)
            : const InstructionsScreen(),
      ),
    ),
  );
}
