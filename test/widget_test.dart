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
import 'package:remotecontrol/widgets/device_picker.dart';
import 'package:remotecontrol/widgets/hold_button.dart';

void main() {
  testWidgets('El control inicia desconectado', (WidgetTester tester) async {
    await tester.pumpWidget(const RobotApp());
    expect(find.text('Sin conexión'), findsOneWidget);
    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    expect(find.text('Conectar'), findsOneWidget);
  });

  testWidgets(
    'El tema mantiene contraste y objetivos de navegación accesibles',
    (tester) async {
      final semantics = tester.ensureSemantics();
      try {
        await tester.pumpWidget(const RobotApp());
        await expectLater(tester, meetsGuideline(textContrastGuideline));
        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        await tester.tap(find.byTooltip('Open navigation menu'));
        await tester.pumpAndSettle();
        await expectLater(tester, meetsGuideline(textContrastGuideline));
        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      } finally {
        semantics.dispose();
      }
    },
  );

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

  for (final size in [
    const Size(800, 360),
    const Size(640, 320),
    const Size(360, 800),
    const Size(320, 568),
    const Size(1024, 768),
  ]) {
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
      final reverse = tester.getCenter(find.text('RETROCEDER'));
      expect(left.dy, right.dy);
      expect(left.dx, lessThan(right.dx));
      expect(right.dx, lessThan(forward.dx));
      expect(forward.dy, lessThan(reverse.dy));
      expect(forward.dx, closeTo(reverse.dx, 0.001));
      final stop = tester.getRect(find.widgetWithText(FilledButton, 'DETENER'));
      for (final element in find.byType(HoldButton).evaluate()) {
        final control = tester.getRect(find.byWidget(element.widget));
        expect(control.top, greaterThanOrEqualTo(0));
        expect(control.bottom, lessThanOrEqualTo(stop.top - 12));
        expect(control.left, greaterThanOrEqualTo(0));
        expect(control.right, lessThanOrEqualTo(size.width));
        expect(control.width, greaterThanOrEqualTo(48));
        expect(control.height, greaterThanOrEqualTo(48));
        expect(find.byWidget(element.widget).hitTestable(), findsOneWidget);
      }
      expect(find.text('ACELERAR').hitTestable(), findsOneWidget);
      expect(find.text('RETROCEDER').hitTestable(), findsOneWidget);
      expect(find.text('DETENER').hitTestable(), findsOneWidget);
      await tester.tap(find.byTooltip('Open navigation menu'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }

  for (final size in [
    const Size(320, 800),
    const Size(800, 360),
    const Size(640, 320),
  ]) {
    testWidgets('Texto 2x conserva parada accesible en $size', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final robot = RobotController()..connected = true;
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(2)),
            child: child!,
          ),
          home: MainLayout(controller: robot),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(find.text('DETENER').hitTestable(), findsOneWidget);
      for (final element in find.byType(HoldButton).evaluate()) {
        final size = tester.getSize(find.byWidget(element.widget));
        expect(size.width, greaterThanOrEqualTo(48));
        expect(size.height, greaterThanOrEqualTo(48));
        final bounds = tester.getRect(find.byWidget(element.widget));
        final stop = tester.getRect(
          find.widgetWithText(FilledButton, 'DETENER'),
        );
        expect(bounds.bottom, lessThanOrEqualTo(stop.top - 12));
        expect(find.byWidget(element.widget).hitTestable(), findsOneWidget);
      }
      final finger = await tester.startGesture(
        tester.getCenter(find.text('ACELERAR')),
      );
      await tester.pump();
      expect(robot.buttons, 1);
      await tester.tap(find.text('DETENER'));
      await tester.pump();
      expect(robot.buttons, 0);
      await finger.up();
      await tester.pumpWidget(const SizedBox());
      robot.dispose();
    });
  }

  testWidgets('Selector con error largo permite leer y buscar con texto 2x', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    var searches = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(2)),
          child: Scaffold(
            body: DevicePicker(
              devices: const [],
              scanning: false,
              error: 'No se pudo buscar. Revisa los permisos de Bluetooth del teléfono e inténtalo de nuevo.',
              onSearch: () => searches++,
              onSelected: (_) {},
            ),
          ),
        ),
      ),
    );
    await tester.ensureVisible(find.text('Buscar de nuevo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Buscar de nuevo'));
    expect(searches, 1);
    expect(tester.takeException(), isNull);
  });
}
