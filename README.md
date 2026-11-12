# agbot control

App Flutter para conducir el ESP32 `agbot` por Bluetooth Low Energy. Interfaz
oscura, controles multitáctiles y telemetría PWM de ambos motores.

## Ejecutar

Con Flutter 3.47.9 o compatible y el SDK de Android instalado:

```bash
flutter pub get
flutter run
```

Usa un teléfono físico con BLE. Para iOS se necesita macOS, Xcode y configurar
la firma del proyecto `ios/Runner.xcworkspace`.

1. Enciende el ESP32 con el firmware de `/home/felipe/Projects/ESP32/bot`.
2. Activa Bluetooth, abre el menú **☰** y pulsa **Conectar**. Acepta los permisos solicitados.
   Android 11 y anteriores también necesitan ubicación activa para buscar BLE.
3. Selecciona **agbot**. No requiere emparejamiento en los ajustes del teléfono.
   Si ya lo emparejaste allí, pulsa **Desvincular** antes de conectar desde la app:
   el firmware actual no conserva las claves de emparejamiento al reiniciarse.
4. Mantén **Acelerar** o **Atrás** y combina con **Izquierda** o **Derecha**.
5. Suelta la aceleración o pulsa **Detener** para detener el movimiento.

En horizontal, Izquierda y Derecha están una al lado de la otra en la zona
izquierda; Acelerar y Atrás están en la derecha. La franja superior muestra
conexión y aceleración de forma compacta. El menú incluye **Control** e
**Instrucciones**, con espacio disponible para futuras opciones.

El giro solo no mueve el robot. La rampa de potencia y la inversión se calculan
en el ESP32. Los porcentajes mostrados son PWM real reportado, no velocidad medida.
Al salir de la app se liberan los botones. La desconexión o 500 ms sin comandos
también solicitan parada en el firmware. No se reanuda el movimiento automáticamente.

## Código

- `lib/main.dart`: inicialización y arranque de la aplicación.
- `lib/app.dart`: aplicación y configuración del tema oscuro.
- `lib/layouts/main_layout.dart`: layout compartido, menú, navegación, conexión y ciclo de vida.
- `lib/screens/control_screen.dart`: pantalla principal con estado compacto y controles.
- `lib/screens/instructions_screen.dart`: guía de conexión y uso del robot.
- `lib/widgets/connection_status.dart`: estado y acciones de conexión.
- `lib/widgets/device_picker.dart`: selector de dispositivos Bluetooth.
- `lib/widgets/motor_telemetry.dart`: indicadores de potencia y estado del robot.
- `lib/widgets/driving_controls.dart`: controles de dirección, aceleración y parada.
- `lib/widgets/hold_button.dart`: botón reutilizable de mantener pulsado con multitáctil.
- `lib/theme/app_colors.dart`: colores compartidos de la interfaz.
- `lib/controllers/robot_controller.dart`: permisos, búsqueda, conexión, telemetría y funciones
  `acelerar`, `retroceder`, `girarIzquierda`, `girarDerecha` y `stop`.
- `lib/protocol/robot_protocol.dart`: comandos binarios y decodificación de estado.

La interfaz se divide en `layouts`, `screens` y `widgets` (componentes reutilizables).
Los widgets reciben datos y callbacks desde la pantalla. El controlador mantiene
el estado y la lógica Bluetooth; el layout conserva la conexión entre pantallas
y libera los controles al abrir el menú, cambiar de pantalla o salir de la app.

Servicio BLE `FFF0`, escritura **con respuesta** en `FFF1`, lectura y notificaciones
en `FFF2`. Cada orden contiene un byte: adelante `01`, atrás `02`, izquierda `04`,
derecha `08`; se combinan con OR. Parada `00`. Se envía al pulsar/soltar y cada
100 ms con botones activos. Las escrituras se serializan sin acumular órdenes
obsoletas. El estado contiene cinco bytes: botones, PWM base, PWM izquierdo,
PWM derecho y flags. El firmware original se consultó únicamente en lectura.

## Comprobar

```bash
flutter analyze
flutter test
flutter build apk --debug
```

La conexión BLE y el movimiento deben comprobarse con el ESP32 y un teléfono.
