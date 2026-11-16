import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:remotecontrol/controllers/robot_controller.dart';
import 'package:remotecontrol/controllers/settings_controller.dart';
import 'package:remotecontrol/controllers/tilt_steering_controller.dart';
import 'package:remotecontrol/layouts/main_layout.dart';
import 'package:remotecontrol/protocol/robot_protocol.dart';
import 'package:remotecontrol/widgets/hold_button.dart';

class MemorySettingsStore extends SettingsStore {
  bool enabled = false;
  @override
  Future<bool> read() async => enabled;
  @override
  Future<void> write(bool enabled) async {
    this.enabled = enabled;
  }
}

Future<void> selectPage(WidgetTester tester, String name) async {
  await tester.tap(find.byTooltip('Open navigation menu'));
  await tester.pumpAndSettle();
  final page = find.widgetWithText(ListTile, name);
  await tester.ensureVisible(page);
  await tester.tap(page);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Configuración guarda, conserva conexión y cambia ambos modos', (
    tester,
  ) async {
    final store = MemorySettingsStore();
    final settings = SettingsController(store: store);
    await settings.load();
    final robot = RobotController()..connected = true;
    final samples = StreamController<TiltSample>.broadcast(sync: true);
    await tester.pumpWidget(
      MaterialApp(
        home: MainLayout(
          controller: robot,
          settings: settings,
          tiltSamples: samples.stream,
        ),
      ),
    );
    expect(find.text('IZQUIERDA'), findsOneWidget);
    await selectPage(tester, 'Configuraciones');
    expect(robot.connected, isTrue);
    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();
    expect(store.enabled, isTrue);
    await selectPage(tester, 'Control');
    expect(find.text('IZQUIERDA'), findsNothing);
    expect(find.text('DERECHA'), findsNothing);
    expect(samples.hasListener, isTrue);
    samples.add(const TiltSample(0, 9.8, 0));
    await tester.pump();
    robot.status = const RobotStatus(buttons: 9, base: 60, left: 60);
    final finger = await tester.startGesture(
      tester.getCenter(find.text('ACELERAR')),
    );
    for (var i = 0; i < 30; i++) {
      samples.add(const TiltSample(-6.93, 6.93, 0));
    }
    await tester.pump();
    expect(robot.commandPacket, [9, 100]);
    expect(find.text('Avance · 60 % PWM'), findsOneWidget);
    expect(find.text('Giro · Derecha 100 %'), findsOneWidget);
    await tester.tap(find.text('DETENER'));
    samples.add(const TiltSample(-6.93, 6.93, 0));
    expect(robot.buttons, 0);
    await tester.pump();
    expect(find.text('Giro · Recto 0 %'), findsOneWidget);
    await finger.up();
    await selectPage(tester, 'Instrucciones');
    expect(robot.connected, isTrue);
    expect(samples.hasListener, isFalse);
    await selectPage(tester, 'Configuraciones');
    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();
    expect(store.enabled, isFalse);
    await selectPage(tester, 'Control');
    expect(robot.connected, isTrue);
    expect(find.text('IZQUIERDA'), findsOneWidget);
    expect(robot.buttons, 0);
    await tester.pumpWidget(const SizedBox());
    settings.dispose();
    robot.dispose();
    await samples.close();
  });

  testWidgets('Ajuste manual detiene antes de abrir y cambia el paquete', (
    tester,
  ) async {
    final settings = SettingsController(store: MemorySettingsStore())
      ..loaded = true;
    final robot = RobotController()..connected = true;
    await tester.pumpWidget(
      MaterialApp(
        home: MainLayout(controller: robot, settings: settings),
      ),
    );
    final finger = await tester.startGesture(
      tester.getCenter(find.text('ACELERAR')),
    );
    expect(robot.buttons, 1);
    await tester.tap(find.byTooltip('Intensidad de giro: 50 %'));
    await tester.pumpAndSettle();
    expect(robot.buttons, 0);
    await finger.up();
    final slider = tester.widget<Slider>(find.byType(Slider));
    slider.onChanged!(75);
    await tester.pump();
    await tester.tap(find.text('Listo'));
    await tester.pumpAndSettle();
    robot.status = const RobotStatus(buttons: 5, base: 65, left: 16, right: 65);
    final forward = await tester.startGesture(
      tester.getCenter(find.text('ACELERAR')),
      pointer: 2,
    );
    final left = await tester.startGesture(
      tester.getCenter(find.text('IZQUIERDA')),
      pointer: 3,
    );
    expect(robot.commandPacket, [5, 75]);
    await tester.pump();
    expect(find.text('Avance · 65 % PWM'), findsOneWidget);
    expect(find.text('Giro · Izquierda 75 %'), findsOneWidget);
    await left.up();
    await forward.up();
    robot.status = const RobotStatus(
      buttons: 10,
      base: 45,
      left: 45,
      right: 11,
    );
    final reverse = await tester.startGesture(
      tester.getCenter(find.text('RETROCEDER')),
      pointer: 4,
    );
    final right = await tester.startGesture(
      tester.getCenter(find.text('DERECHA')),
      pointer: 5,
    );
    await tester.pump();
    expect(find.text('Retroceso · 45 % PWM'), findsOneWidget);
    expect(find.text('Giro · Derecha 75 %'), findsOneWidget);
    await right.up();
    await reverse.up();
    await robot.disconnect();
    await tester.pump();
    expect(find.text('Detenido · 0 % PWM'), findsOneWidget);
    expect(find.text('Giro · Recto 0 %'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    settings.dispose();
    robot.dispose();
  });

  testWidgets('Segundo plano cancela el volante sin reanudar al volver', (
    tester,
  ) async {
    final settings = SettingsController(store: MemorySettingsStore())
      ..loaded = true
      ..accelerometerEnabled = true;
    final robot = RobotController()..connected = true;
    final samples = StreamController<TiltSample>.broadcast(sync: true);
    await tester.pumpWidget(
      MaterialApp(
        home: MainLayout(
          controller: robot,
          settings: settings,
          tiltSamples: samples.stream,
        ),
      ),
    );
    samples.add(const TiltSample(0, 9.8, 0));
    await tester.pump();
    final finger = await tester.startGesture(
      tester.getCenter(find.text('ACELERAR')),
    );
    expect(robot.buttons, 1);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    await tester.pump();
    expect(robot.buttons, 0);
    expect(samples.hasListener, isFalse);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    samples.add(const TiltSample(-6.93, 6.93, 0));
    await tester.pump();
    expect(robot.buttons, 0);
    await finger.up();
    final next = await tester.startGesture(
      tester.getCenter(find.text('RETROCEDER')),
    );
    expect(robot.buttons, 2);
    await next.up();
    await tester.pumpWidget(const SizedBox());
    settings.dispose();
    robot.dispose();
    await samples.close();
  });

  for (final size in [
    const Size(320, 568),
    const Size(360, 800),
    const Size(800, 360),
    const Size(640, 320),
  ]) {
    for (final scale in [1.0, 2.0]) {
      testWidgets('Volante y parada caben en $size con texto $scale', (
        tester,
      ) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final settings = SettingsController(store: MemorySettingsStore())
          ..loaded = true
          ..accelerometerEnabled = true;
        final robot = RobotController()
          ..connected = true
          ..status = const RobotStatus(
            buttons: 2,
            base: 100,
            left: 100,
            right: 100,
          );
        final samples = StreamController<TiltSample>.broadcast(sync: true);
        await tester.pumpWidget(
          MaterialApp(
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: TextScaler.linear(scale)),
              child: child!,
            ),
            home: MainLayout(
              controller: robot,
              settings: settings,
              tiltSamples: samples.stream,
            ),
          ),
        );
        expect(tester.takeException(), isNull);
        samples.add(const TiltSample(0, 9.8, 0));
        await tester.pump();
        expect(tester.takeException(), isNull);
        if (size.height <= 360 || (size.height < 656 && scale == 2)) {
          expect(
            find.byTooltip('EN MOVIMIENTO · Retroceso · 100 % PWM'),
            findsOneWidget,
          );
          expect(
            find.byTooltip('Giro solicitado · Recto · 0 %'),
            findsOneWidget,
          );
        } else {
          expect(find.text('Retroceso · 100 % PWM'), findsOneWidget);
          expect(find.text('Giro · Recto 0 %'), findsOneWidget);
        }
        for (final element in find.byType(HoldButton).evaluate()) {
          final bounds = tester.getRect(find.byWidget(element.widget));
          expect(bounds.width, greaterThanOrEqualTo(48));
          expect(bounds.height, greaterThanOrEqualTo(48));
          expect(find.byWidget(element.widget).hitTestable(), findsOneWidget);
        }
        expect(find.text('DETENER').hitTestable(), findsOneWidget);
        samples.addError(StateError('sensor'));
        await tester.pump();
        expect(tester.takeException(), isNull);
        expect(find.text('DETENER').hitTestable(), findsOneWidget);
        await tester.pumpWidget(const SizedBox());
        settings.dispose();
        robot.dispose();
        await samples.close();
      });
    }
  }
}
