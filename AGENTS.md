# Repository guidance

## Setup and checks

- This is one Flutter app: repository `botcontrol`, Dart package `remotecontrol`, product `agbot control`. Use `package:remotecontrol/...` imports in tests; keep the Spanish UI.
- Run commands from the repository root. `flutter pub get` resolves app dependencies; `.opencode/package.json` is OpenCode tooling, not an app build step.
- `pubspec.yaml` requires Dart `^3.13.7`; `pubspec.lock` requires Flutter `>=3.44.0`. The README suggests Flutter 3.47.9 or compatible, but there is no SDK pin.
- For Dart changes: format the changed paths with `dart format <paths>`, then `flutter analyze` and relevant tests. `flutter test test/robot_protocol_test.dart` focuses on the binary contract; `flutter test test/control_screen_test.dart test/widget_test.dart` covers gestures, lifecycle, navigation, and layouts. Use `flutter test` for shared behavior changes.
- For Android native/build changes, run `flutter build apk --debug`. The Android app explicitly uses `compileSdk = 37` and Java/Kotlin target 17; release currently uses debug signing.
- `flutter analyze` excludes `android/`, `ios/`, and `linux/`; it does not verify native configuration. Markdown-only changes do not need Flutter builds.

## Wiring and regression traps

- Startup is `lib/main.dart` → `RobotApp` → `MainLayout`. `MainLayout` owns the controller unless injected, retains the connection across Control/Instructions, and disposes only its own controller. Keep this ownership above individual screens.
- `RobotController` is the `ChangeNotifier` for BLE, permissions, sessions, commands, and telemetry; UI observes it with `ListenableBuilder`. `RobotProtocol` is the pure binary layer. Keep BLE operations out of widget builds.
- Widget tests inject `RobotController()..connected = true` into `MainLayout`; BLE initialization is lazy. This exercises local state/input without plugin or hardware setup, not an actual connection. Existing layout anchors are 360×800 and 800×360.
- `HoldButton` uses per-pointer input plus eager gesture recognition so driving can combine two fingers without scrolling. Preserve release on up/cancel/leave and stop calls on drawer/device-picker opening, navigation, leaving resumed lifecycle, and disposal. Do not resume held movement after reconnecting.
- BLE UUIDs are compared in expanded form. Preserve write-with-response serialization, latest-state coalescing, session invalidation, the initial stop before enabling controls, and the 100 ms active-command heartbeat. Consult the BLE skill before changing this contract.
- Displayed motor percentages are reported PWM, not measured speed. Android/iOS are the documented BLE targets; the presence of `linux/` does not establish desktop BLE support. Radio/motor validation requires a physical phone and ESP32; the README's external firmware path is a reference to a separate repository.

## Local instructions

- Load `final-answers-and-considerations` for every task. For application edits, load `flutter-project` and `dart-flutter-standards`; add `flutter-ble-control` for control/input/lifecycle work, `flutter-mobile-design` for UI work, and `flutter-verification` for application checks. These skills live under `.opencode/skills/` and contain the detailed contracts.
- Specialist agents under `.opencode/agents/` have distinct edit and command permissions; selecting one does not grant access to other layers. Use `opencode-builder` and `customize-opencode` when maintaining `.opencode/` assets. `responder-ia`/`IA.txt` logging applies only when explicitly requested.
