import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:remotecontrol/layouts/main_layout.dart';
import 'package:remotecontrol/controllers/robot_controller.dart';
import 'package:remotecontrol/widgets/hold_button.dart';

void main() {
  testWidgets('Los giros compactos liberan al salir de su superficie', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final robot = RobotController()..connected = true;
    await tester.pumpWidget(MaterialApp(home: MainLayout(controller: robot)));
    final left = find.widgetWithText(HoldButton, 'IZQUIERDA');
    final right = find.widgetWithText(HoldButton, 'DERECHA');
    final forward = find.widgetWithText(HoldButton, 'ACELERAR');
    final bounds = tester.getRect(left);
    expect(bounds.height, lessThan(tester.getSize(forward).height));
    expect(bounds.size, tester.getSize(right));
    expect(bounds.width, greaterThanOrEqualTo(48));
    expect(bounds.height, greaterThanOrEqualTo(48));

    // También responde cerca del borde, fuera del icono y del texto.
    final finger = await tester.startGesture(
      bounds.topLeft + const Offset(8, 8),
    );
    await tester.pump();
    expect(robot.buttons, 4);
    final surface = tester.widget<AnimatedContainer>(
      find.descendant(of: left, matching: find.byType(AnimatedContainer)),
    );
    final background = (surface.decoration! as BoxDecoration).color!;
    final label = tester.widget<Text>(find.text('IZQUIERDA'));
    expect(background.r, greaterThan(background.g));
    expect(background.r, greaterThan(background.b));
    final contrast =
        (label.style!.color!.computeLuminance() + 0.05) /
        (background.computeLuminance() + 0.05);
    expect(contrast, greaterThanOrEqualTo(4.5));
    await finger.moveTo(Offset(bounds.center.dx, bounds.top - 8));
    await tester.pump();
    expect(robot.buttons, 0);
    await finger.up();
    await tester.pumpWidget(const SizedBox());
    robot.dispose();
  });

  testWidgets('Un control deshabilitado no muestra el rojo de pulsación', (
    tester,
  ) async {
    var changes = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HoldButton(
            label: 'IZQUIERDA',
            icon: Icons.west_rounded,
            enabled: false,
            pressed: true,
            onChanged: (_) => changes++,
          ),
        ),
      ),
    );
    final surface = tester.widget<AnimatedContainer>(
      find.byType(AnimatedContainer),
    );
    final background = (surface.decoration! as BoxDecoration).color!;
    expect(background.r, lessThan(background.b));
    await tester.tap(find.text('IZQUIERDA'));
    expect(changes, 0);
  });

  testWidgets('Los controles combinan dedos y liberan direcciones opuestas', (
    tester,
  ) async {
    final robot = RobotController()..connected = true;
    await tester.pumpWidget(MaterialApp(home: MainLayout(controller: robot)));
    await tester.ensureVisible(find.text('ACELERAR'));
    await tester.pumpAndSettle();
    final forward = await tester.startGesture(
      tester.getCenter(find.text('ACELERAR')),
      pointer: 1,
    );
    await tester.pump();
    expect(robot.buttons, 1);

    final left = await tester.startGesture(
      tester.getCenter(find.text('IZQUIERDA')),
      pointer: 2,
    );
    await tester.pump();
    expect(robot.buttons, 5);
    await left.cancel();
    await tester.pump();
    expect(robot.buttons, 1);

    final reverse = await tester.startGesture(
      tester.getCenter(find.text('RETROCEDER')),
      pointer: 3,
    );
    await tester.pump();
    expect(robot.buttons, 0);
    await forward.up();
    await tester.pump();
    expect(robot.buttons, 2);
    await reverse.up();
    await tester.pump();
    expect(robot.buttons, 0);
    await tester.pumpWidget(const SizedBox());
    robot.dispose();
  });

  testWidgets('Al pasar a segundo plano se libera la aceleración', (
    tester,
  ) async {
    final robot = RobotController()..connected = true;
    await tester.pumpWidget(MaterialApp(home: MainLayout(controller: robot)));
    await tester.ensureVisible(find.text('ACELERAR'));
    final finger = await tester.startGesture(
      tester.getCenter(find.text('ACELERAR')),
    );
    expect(robot.buttons, 1);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    await tester.pump();
    expect(robot.buttons, 0);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await finger.up();
    await tester.pumpWidget(const SizedBox());
    robot.dispose();
  });
}
