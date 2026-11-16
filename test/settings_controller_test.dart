import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:remotecontrol/controllers/settings_controller.dart';

void main() {
  late Directory directory;
  late SettingsStore store;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('agbot_settings_test_');
    store = SettingsStore(directory: () async => directory);
  });
  tearDown(() async => directory.delete(recursive: true));

  test(
    'Predeterminado apagado y cada cambio persiste entre instancias',
    () async {
      final settings = SettingsController(store: store);
      await settings.load();
      expect(settings.accelerometerEnabled, isFalse);
      for (final enabled in [true, false]) {
        await settings.setAccelerometerEnabled(enabled);
        final data = jsonDecode(
          await File('${directory.path}/settings.json').readAsString(),
        );
        expect(data['accelerometerEnabled'], enabled);
        final restored = SettingsController(store: store);
        await restored.load();
        expect(restored.accelerometerEnabled, enabled);
        expect(restored.error, isNull);
        restored.dispose();
      }
      settings.dispose();
    },
  );

  test(
    'Archivo corrupto usa manual y permite guardar una configuración válida',
    () async {
      await File('${directory.path}/settings.json').writeAsString('{');
      final settings = SettingsController(store: store);
      await settings.load();
      expect(settings.accelerometerEnabled, isFalse);
      expect(settings.error, isNotNull);
      await settings.setAccelerometerEnabled(true);
      expect(await store.read(), isTrue);
      expect(settings.error, isNull);
      settings.dispose();
    },
  );

  test('Un fallo al escribir no cambia el valor confirmado', () async {
    final settings = SettingsController(store: store);
    await settings.load();
    await directory.delete();
    await File(directory.path).writeAsString('bloqueado');
    try {
      await settings.setAccelerometerEnabled(true);
      expect(settings.accelerometerEnabled, isFalse);
      expect(settings.error, isNotNull);
      expect(settings.saving, isFalse);
    } finally {
      settings.dispose();
      await File(directory.path).delete();
      await directory.create();
    }
  });
}
