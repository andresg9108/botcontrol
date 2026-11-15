---
name: flutter-ble-control
description: Maintains agbot BLE commands, telemetry, permissions, and hold-to-drive invariants; use when changing or reviewing robot control or its input and lifecycle integration.
---

# Flutter BLE Robot Control

Ground changes in `RobotController`, `RobotProtocol`, `HoldButton`, `DrivingControls`, `MainLayout`, and their tests. These are the current app contracts, not universal BLE rules; verify them again if the firmware contract changes.

## When to use

- Change BLE discovery, permissions, connection setup, writes, telemetry, or cleanup.
- Change driving gestures, stop handling, navigation/lifecycle integration, or review a visual change touching driving controls.
- Do not load for isolated colors or unrelated documentation.

## Workflow

1. Trace the affected input-to-command-to-status path and inspect relevant tests before editing. If firmware evidence is needed, use an available user-supplied source; the README's external firmware path is a reference, not permission to edit that repository.
2. Preserve the current binary contract:
   - Expanded UUID service `FFF0`, command characteristic `FFF1`, status characteristic `FFF2`.
   - Write **with response**, one byte combining forward `0x01`, reverse `0x02`, left `0x04`, right `0x08` with OR. Stop is `0x00`; opposite directions produce stop in `RobotProtocol.command`.
   - Status must contain exactly five bytes: buttons, base PWM, left PWM, right PWM, flags. Flag bits are timeout `1`, pausing `2`, output fault `4`. Malformed status currently causes connection loss handling.
   - Commands are sent on press/release and every 100 ms while buttons are active. Serialize writes, retain the latest state instead of a backlog, and preserve session invalidation across reconnects. Connection preparation sends stop before enabling control.
3. Preserve hold-to-drive input: independent pointer ownership permits acceleration plus steering. Release on up, cancellation, and pointer leaving the control; visual rebuilds must not latch movement or replace this with tap-to-toggle or delayed long-press recognition. No automatic movement resumption after a reconnect or navigation.
4. Preserve `MainLayout` stop behavior when opening the drawer/device picker, changing screens, leaving resumed lifecycle, and disposing. Keep controls disabled when disconnected or output-faulted. Do not label a local stop request as confirmed physical stopping; PWM is reported output, not measured speed. The README describes a firmware 500 ms watchdog; the app heartbeat does not prove that firmware behavior.
5. Preserve cancellation, timeouts, and ownership for scan, connection, notifications, and heartbeat. Keep `_session` and `_searchSession` guards or an equivalent verified stale-result mechanism; guard against callbacks arriving after disposal and against old writes crossing sessions.
6. For permissions, inspect both Dart and native declarations: `android/app/src/main/AndroidManifest.xml` and `ios/Runner/Info.plist`. Current Android flow requests scan/connect at SDK 31+ and location on older Android; older devices may need location services enabled. iOS usage descriptions are declared and authorization is triggered by BLE use. Do not add classic pairing or background BLE features without a task requirement.
7. For behavior changes, extend focused tests where they protect protocol, concurrent input, cancellation, faults, or lifecycle semantics. Use `flutter-verification`. Validate discovery, permission denial, reconnection, notifications, and actual motor response on a physical BLE phone/ESP32 when available; unit/widget tests do not establish radio or hardware success.

## References

- [flutter_reactive_ble](https://pub.dev/packages/flutter_reactive_ble) and the installed version in `pubspec.lock`.
- [Android Bluetooth permissions](https://developer.android.com/develop/connectivity/bluetooth/bt-permissions).
- [permission_handler](https://pub.dev/packages/permission_handler).

## Output

State the verified protocol or input contract, changed behavior, automated results, and hardware checks actually performed or still pending.
