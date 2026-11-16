# agbot control

App Flutter para conducir el ESP32 `agbot` por Bluetooth Low Energy. Interfaz
oscura, controles multitáctiles y telemetría PWM de ambos motores.

Este repositorio (`botcontrol`) contiene la **app de control agbot control**;
el paquete Dart se llama `remotecontrol`.

## Construir el robot

**La documentación para construir el bot que controla esta app está en
[andresg9108/bot](https://github.com/andresg9108/bot).**

Consulta ese repositorio para preparar el robot y su firmware. Este README
describe cómo ejecutar y usar la app de control, no cómo construir el robot.

## Requisitos de desarrollo y compatibilidad

- Flutter en el `PATH`, con Dart compatible con `^3.13.7` (`pubspec.yaml`).
  `pubspec.lock` exige Flutter `>=3.44.0`; deben cumplirse **ambas** restricciones.
  Flutter 3.47.9 es la referencia sugerida, no una versión fijada por el proyecto.
- **Android:** entorno Flutter para Android en Linux, macOS o Windows, Android
  SDK Platform **37** (`compileSdk`), herramientas de línea de comandos,
  Platform-Tools y licencias aceptadas. El proyecto usa destino Java/Kotlin 17;
  utiliza un JDK compatible con el Gradle del proyecto, no confundas ese destino
  con una versión obligatoria del JDK que ejecuta Gradle. `minSdk`, `targetSdk`
  y NDK se toman del SDK Flutter instalado.
- **iOS:** macOS y Xcode con sus herramientas de línea de comandos y soporte
  iOS, más las dependencias nativas requeridas por Flutter/plugins según tu
  entorno. Abre `ios/Runner.xcworkspace` y configura el equipo y la firma del
  target **Runner** con tu cuenta Apple y un identificador disponible. El target
  declara **iOS 15.0** como mínimo; las dependencias pueden imponer requisitos
  adicionales. Linux y Windows no compilan ni firman esta app para iOS.
- **Uso real:** teléfono Android o iPhone con BLE, robot ESP32 con firmware
  compatible y, para el modo volante, acelerómetro operativo. Emuladores y
  simuladores no sustituyen la prueba de radio, sensores y motores en hardware.

Android/iOS son los destinos móviles documentados, no una matriz de dispositivos
certificados. La carpeta `linux/` no establece soporte BLE de escritorio; no se
documenta funcionamiento del control en web, Linux, Windows ni macOS.

## Ejecutar

Desde la raíz de `botcontrol` (donde está `pubspec.yaml`):

```bash
flutter doctor -v
flutter pub get
flutter devices
```

Corrige primero los problemas del destino elegido que muestre `flutter doctor`.
Para Android, si faltan licencias, usa `flutter doctor --android-licenses`.
Conecta y autoriza el teléfono: depuración USB en Android; confianza y modo de
desarrollador cuando lo requiera iOS. La carpeta `.opencode/` contiene herramientas
de asistencia, no dependencias ni pasos de compilación de la app.

Para iniciar **manualmente una sesión de desarrollo**, sustituye `ID_DEL_TELEFONO`
por el identificador de `flutter devices`:

```bash
flutter run -d ID_DEL_TELEFONO
```

### Generar e instalar sin iniciar depuración

**Android**, para una instalación de prueba local:

```bash
flutter build apk --debug
flutter install --debug -d ID_DEL_TELEFONO
```

El APK se genera en `build/app/outputs/flutter-apk/app-debug.apk`. También puedes
copiarlo al teléfono e instalarlo autorizando esa fuente cuando Android lo pida.
`flutter install` puede desinstalar la versión anterior: guarda lo necesario y
ten en cuenta que puedes perder la configuración privada de la app. Abre
**agbot control** desde el lanzador después de instalar.

Para generar artefactos Android de distribución, Flutter ofrece
`flutter build apk --release` y `flutter build appbundle --release`, pero este
proyecto **firma actualmente release con la clave debug**. Configura una firma
de producción antes de distribuir; compilar en release no resuelve esa carencia.

**iOS**, solo en macOS con firma y aprovisionamiento preparados:

```bash
flutter build ipa
```

Genera el archivo Xcode en `build/ios/archive/` y, si la exportación es válida,
el IPA en `build/ios/ipa/`. Distribuye e instala mediante el flujo de Xcode o
TestFlight adecuado a tu perfil y cuenta Apple; un IPA no es instalable en
cualquier iPhone por el mero hecho de copiarlo. Consulta las guías de Flutter
para [Android](https://docs.flutter.dev/deployment/android) e
[iOS](https://docs.flutter.dev/deployment/ios) para firma y distribución.

## Conectar y conducir

1. Prepara el robot siguiendo la documentación de
   [andresg9108/bot](https://github.com/andresg9108/bot) y enciende el ESP32
   con su firmware instalado.
2. Activa Bluetooth, abre el menú **☰** y pulsa **Conectar**. Acepta los permisos solicitados.
   Android 11 y anteriores también necesitan ubicación activa para buscar BLE.
3. Selecciona **agbot** desde la app, sin emparejarlo previamente en los ajustes
   del teléfono. El servidor BLE externo consultado permite lectura/escritura
   sin exigir cifrado o autenticación; no se afirma que todas las versiones de
   firmware gestionen o conserven las claves de emparejamiento del mismo modo.
4. En modo manual, mantén **ACELERAR** o **RETROCEDER** y combina con
   **IZQUIERDA** o **DERECHA** usando otro dedo.
5. Suelta avance/retroceso o pulsa **DETENER** para solicitar parada.

En horizontal, Izquierda y Derecha están una al lado de la otra en la zona
izquierda; Acelerar y Retroceder están en la derecha. La franja superior muestra
conexión, movimiento/PWM y giro solicitado, en formato compacto cuando falta
altura. El menú incluye **Control**, **Instrucciones** y **Configuraciones**;
la conexión se conserva al navegar entre estas pantallas.

### Intensidad manual y volante

- En modo manual, el botón de ajustes de la barra de Control abre **Intensidad
  de giro** y solicita parada antes de mostrar el deslizador. Parte del 50 % y
  permite 0–100 % en pasos de 5: 0 % solicita trayectoria recta; 100 % reduce a
  cero la potencia del lado afectado por el giro. Se aplica al avanzar y retroceder.
  Este valor vive en memoria, no se guarda entre arranques.
- En **Configuraciones → Control por acelerómetro**, activa el modo volante.
  Se ocultan los botones de giro: sostén el teléfono frente a ti como un volante
  al entrar en Control; la primera muestra válida fija el centro. Mantén
  **ACELERAR** o **RETROCEDER** y gira el teléfono para dirigir. Hay una zona
  muerta de 5° y el giro máximo se alcanza a 45°, con lecturas suavizadas.
- **Centrar volante y detener** solicita parada y recalibra con la siguiente
  muestra válida. La preferencia de usar acelerómetro se guarda en
  `settings.json` dentro del almacenamiento privado del teléfono; no se guarda
  el centro. Sin datos válidos del sensor, los controles de marcha se deshabilitan
  y se solicita parada. Puedes volver al modo manual desde Configuraciones.

El giro solo no mueve el robot. La rampa de potencia y la inversión se calculan
en el ESP32. Los porcentajes de motores son PWM calculado y reportado por el
firmware, **no velocidad medida**; el giro mostrado es la solicitud local de la
app, no una medición de la trayectoria.

La app libera los botones y solicita parada al abrir el menú, el selector de
dispositivos o el ajuste manual, cambiar de pantalla, dejar el primer plano o
desmontar el layout. Una nueva conexión envía parada antes de habilitar el
control; no restaura las pulsaciones anteriores. Esto no confirma una parada
física si el enlace ya se ha perdido.

El [firmware externo consultado](https://github.com/andresg9108/bot) define un
timeout de **500 ms sin comandos** en `main/motor_motion.h` y lo aplica en
`main/motor_motion.c`; `main/agbot.c` solicita parada ante desconexión/error BLE.
Es comportamiento de ese código, no una garantía sobre el firmware instalado ni
una prueba física realizada aquí. No es una parada de emergencia independiente:
haz las primeras pruebas con ruedas levantadas y alimentación desconectable.

## Problemas comunes

| Síntoma | Qué revisar |
| --- | --- |
| No aparece el robot | Activa Bluetooth, comprueba alimentación, alcance y que el ESP32 esté anunciándose. La búsqueda dura 10 s: pulsa **Buscar de nuevo**. La app solo lista el nombre `agbot` (sin distinguir mayúsculas) o anuncios con el servicio `FFF0`. |
| Permisos denegados | En Android 12+ permite dispositivos cercanos/Bluetooth (scan y connect); en Android 11 o anterior concede ubicación y activa su servicio. Si ya denegaste el permiso, revísalo en los ajustes de la app y vuelve a buscar. En iOS, autoriza Bluetooth cuando se solicite y revisa el permiso en Ajustes si lo rechazaste. |
| No conecta o falla al preparar el control | Comprueba que otra app/teléfono no esté usando el robot y que el firmware ofrezca `FFF0`, `FFF1` y `FFF2`. La app necesita lectura y notificaciones de estado y escritura con respuesta; ver solo el nombre no prueba compatibilidad. Si existe una vinculación antigua y hay errores de seguridad, prueba a olvidarla y conecta de nuevo desde la app, sin asumir una causa concreta sobre las claves. |
| Se perdió la telemetría / estado BLE inválido | Revisa enlace y versión de firmware. El estado debe tener exactamente cinco bytes; un paquete con otra longitud o un error de notificaciones cierra la sesión de control. Tras corregir la causa, conecta de nuevo desde el menú; la app no reconecta ni reanuda automáticamente. |
| PWM a cero o **SIN COMANDOS** | Sin avance/retroceso no se solicita marcha. **SIN COMANDOS** representa el flag de timeout reportado por el robot; no es un diagnóstico de velocidad. Revisa los comandos y el enlace antes de seguir. |
| **PAUSA DE INVERSIÓN** / **FALLO DE SALIDA** | Son flags del firmware. La pausa es un estado transitorio; un fallo de salida bloquea los controles y solicita parada. Asegura el robot y revisa firmware, driver y alimentación antes de reiniciar o reconectar; no fuerces movimiento desde la app. |
| Volante no disponible o descentrado | Sostén el teléfono frente a ti, no plano sobre una mesa; pulsa **Centrar volante y detener**. Si faltan datos, vuelve a entrar en Control o desactiva el acelerómetro. Su timeout de datos de 500 ms es local a la app y distinto del timeout de comandos del firmware. |
| Error al leer/guardar configuraciones | Un fallo de lectura mantiene el modo manual predeterminado; un fallo de escritura no confirma el nuevo valor. Reintenta y revisa el almacenamiento del teléfono; no es un fallo BLE. |
| Falla la compilación o instalación | Revisa `flutter doctor -v`, SDK Platform 37/licencias/JDK en Android y Xcode/firma/perfil en macOS. Una firma distinta puede impedir actualizar una instalación existente; desinstalar borra sus datos privados. |

## Código

- `lib/main.dart`: inicialización y arranque de la aplicación.
- `lib/app.dart`: aplicación y configuración del tema oscuro.
- `lib/layouts/main_layout.dart`: layout compartido, menú, navegación, conexión y ciclo de vida.
- `lib/screens/control_screen.dart`: pantalla principal con estado compacto y controles.
- `lib/screens/instructions_screen.dart`: guía de conexión y uso del robot.
- `lib/screens/settings_screen.dart`: selección del modo de conducción.
- `lib/widgets/connection_status.dart`: estado y acciones de conexión.
- `lib/widgets/device_picker.dart`: selector de dispositivos Bluetooth.
- `lib/widgets/motor_telemetry.dart`: indicadores de potencia y estado del robot.
- `lib/widgets/driving_controls.dart`: controles de dirección, aceleración y parada.
- `lib/widgets/hold_button.dart`: botón reutilizable de mantener pulsado con multitáctil.
- `lib/theme/app_colors.dart`: colores compartidos de la interfaz.
- `lib/controllers/robot_controller.dart`: permisos, búsqueda, conexión, telemetría y funciones
  `acelerar`, `retroceder`, `girarIzquierda`, `girarDerecha` y `stop`.
- `lib/controllers/settings_controller.dart`: carga y guardado local de la preferencia de acelerómetro.
- `lib/controllers/tilt_steering_controller.dart`: muestras, centro, intensidad y fallos del volante.
- `lib/protocol/robot_protocol.dart`: comandos binarios y decodificación de estado.

La interfaz se divide en `layouts`, `screens` y `widgets` (componentes reutilizables).
Los widgets reciben datos y callbacks desde la pantalla. El controlador mantiene
el estado y la lógica Bluetooth; el layout conserva la conexión entre pantallas
y libera los controles al abrir el menú, cambiar de pantalla o salir de la app.

Servicio BLE `FFF0`, escritura **con respuesta** en `FFF1`, lectura y notificaciones
en `FFF2`. La app actual envía **dos bytes binarios**, no texto:

1. Máscara de botones: adelante `01`, atrás `02`, izquierda `04`, derecha `08`
   (hexadecimal); se combinan con OR. Las direcciones opuestas solicitan parada.
2. Intensidad de giro 0–100 en decimal; sin dirección de giro se envía cero.

Ejemplos hexadecimales: `05 19` = adelante/izquierda al 25 %; `09 64` =
adelante/derecha al 100 %; `00 00` = parada. Se envía al pulsar/soltar, al cambiar
la intensidad aplicable y cada 100 ms con botones activos. Las escrituras se
serializan conservando el estado más reciente, sin cola de órdenes obsoletas.
El estado contiene cinco bytes: botones, PWM base, PWM izquierdo, PWM derecho y
flags (timeout `01`, pausa `02`, fallo de salida `04`).

El firmware externo actual acepta uno o dos bytes de comando, pero una versión
antigua que solo acepte uno **no es compatible con los paquetes actuales de la
app**. Consulta su [contrato BLE](https://github.com/andresg9108/bot/blob/main/BLE_CONTROL.md)
y comprueba la versión realmente grabada. El servidor
[agBLE consultado](https://github.com/andresg9108/ESP32-utilities/blob/main/BLE/agBLE/agBLE_server.c)
no exige autenticación/cifrado en estas características; esto no constituye un
mecanismo de autorización del conductor ni demuestra persistencia de claves.

## Comprobar

```bash
flutter analyze
flutter test
```

Para acotar las pruebas existentes:

```bash
flutter test test/robot_protocol_test.dart
flutter test test/control_screen_test.dart test/widget_test.dart
flutter test test/settings_controller_test.dart test/settings_navigation_test.dart test/tilt_steering_test.dart
```

- Protocolo: máscara, paquetes de dos bytes, parada por valores inválidos y
  decodificación de telemetría/flags.
- Widgets: multitáctil, liberación, segundo plano, navegación, tema, contraste,
  objetivos táctiles y layouts verticales/horizontales con texto ampliado.
- Configuraciones/volante: persistencia y errores de archivos, cambio de modo,
  cálculo de ángulos, datos de sensor simulados y ausencia de reanudación local.

Estas pruebas inyectan estado/controladores y muestras; marcar `connected = true`
en un test **no establece una conexión BLE**. No validan permisos del sistema,
radio, sensores reales, GPIO/PWM ni movimiento. `flutter analyze` excluye
`android/`, `ios/` y `linux/`: no verifica la configuración nativa. Para cambios
nativos Android, `flutter build apk --debug` comprueba compilación, no hardware;
para iOS hace falta el entorno macOS descrito arriba. Los cambios solo de
Markdown no requieren builds Flutter.

### Validación física pendiente de cada entorno

Con teléfono y ESP32 reales, ruedas levantadas y posibilidad de cortar alimentación:

1. Comprueba permisos concedidos/denegados, Bluetooth apagado, búsqueda y conexión.
2. Verifica telemetría, avance/retroceso, giros combinados y distintas intensidades;
   distingue PWM reportado de velocidad real.
3. Comprueba parada al soltar/cancelar, abrir menús, cambiar de pantalla y pasar a
   segundo plano; tras reconectar debe exigirse una nueva pulsación.
4. Prueba el volante en ambas orientaciones, centrado, retorno al modo manual y
   restauración de la preferencia tras reiniciar la app.
5. Comprueba pérdida de enlace y timeout del firmware en condiciones seguras,
   sin tratar el límite nominal de 500 ms como garantía de frenado instantáneo.

Esta documentación se contrastó con fuentes locales y externas en lectura;
no acredita ejecución de los comandos, pruebas automatizadas superadas ni una
conexión o movimiento físicos verificados.
