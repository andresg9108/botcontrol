import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:remotecontrol/layouts/main_layout.dart';
import 'package:remotecontrol/controllers/robot_controller.dart';

void main() {
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
      tester.getCenter(find.text('ATRÁS')),
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
