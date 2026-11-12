// Esta es una prueba básica de widgets de Flutter.
// This is a basic Flutter widget test.
//
// Para interactuar con un widget durante la prueba, utiliza WidgetTester del
// paquete flutter_test. Permite enviar gestos de toque y desplazamiento, buscar
// widgets hijos en el árbol, leer texto y comprobar los valores de sus propiedades.
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

import 'package:remotecontrol/app.dart';
import 'package:remotecontrol/controllers/robot_controller.dart';
import 'package:remotecontrol/layouts/main_layout.dart';
import 'package:remotecontrol/screens/control_screen.dart';
import 'package:remotecontrol/screens/instructions_screen.dart';

void main() {
  testWidgets('El control inicia desconectado', (WidgetTester tester) async {
    await tester.pumpWidget(const RobotApp());
    expect(find.text('Sin conexión'), findsOneWidget);
    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    expect(find.text('Conectar'), findsOneWidget);
  });

  testWidgets(
    'El menú libera los controles y conserva la conexión entre pantallas',
    (tester) async {
      final robot = RobotController()..connected = true;
      await tester.pumpWidget(MaterialApp(home: MainLayout(controller: robot)));
      final finger = await tester.startGesture(
        tester.getCenter(find.text('ACELERAR')),
      );
      expect(robot.buttons, 1);
      await tester.tap(find.byTooltip('Open navigation menu'));
      await tester.pumpAndSettle();
      expect(robot.buttons, 0);
      await finger.up();
      await tester.tap(find.text('Instrucciones'));
      await tester.pumpAndSettle();
      expect(find.byType(InstructionsScreen), findsOneWidget);
      expect(robot.connected, isTrue);
      await tester.tap(find.byTooltip('Open navigation menu'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Control'));
      await tester.pumpAndSettle();
      expect(find.byType(ControlScreen), findsOneWidget);
      expect(robot.buttons, 0);
      await tester.pumpWidget(const SizedBox());
      robot.dispose();
    },
  );

  for (final size in [const Size(800, 360), const Size(360, 800)]) {
    testWidgets('Los controles caben y agrupan los giros en $size', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(const RobotApp());
      final left = tester.getCenter(find.text('IZQUIERDA'));
      final right = tester.getCenter(find.text('DERECHA'));
      final forward = tester.getCenter(find.text('ACELERAR'));
      final reverse = tester.getCenter(find.text('ATRÁS'));
      expect(left.dy, right.dy);
      expect(left.dx, lessThan(right.dx));
      expect(right.dx, lessThan(forward.dx));
      expect(forward.dy, lessThan(reverse.dy));
      expect(find.text('ACELERAR').hitTestable(), findsOneWidget);
      expect(find.text('ATRÁS').hitTestable(), findsOneWidget);
      expect(find.text('DETENER').hitTestable(), findsOneWidget);
      await tester.tap(find.byTooltip('Open navigation menu'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
