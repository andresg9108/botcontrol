---
name: flutter-project
description: Guides agbot app architecture and reusable widgets; use when creating, editing, or reviewing Flutter application code in this repository.
---

# Flutter Project

Maintain the Flutter BLE remote for the ESP32 agbot. The repository directory is `botcontrol`, the Dart package is `remotecontrol`, and the product title is `agbot control`; do not rename one to match another incidentally.

Project paths in this skill, such as `lib/`, `test/`, and `pubspec.yaml`, are relative to the repository root, not the skill directory.

## When to use

- Change or review Dart application code, screens, navigation, or shared widgets.
- Consult from OpenCode-authoring work when describing the verified project architecture.
- Do not load for unrelated documentation or configuration work.

## Workflow

1. Read `pubspec.yaml`, `analysis_options.yaml`, the affected sources and their callers. Recheck versions instead of assuming the latest online Flutter API exists locally. Dependencies currently include `flutter_reactive_ble`, `permission_handler`, and `device_info_plus`.
2. Preserve the existing separation:
   - `lib/main.dart`: startup; `lib/app.dart`: `MaterialApp` and dark Material 3 theme.
   - `lib/layouts/main_layout.dart`: owns or accepts a `RobotController`, keeps the connection across Control/Instructions, coordinates drawer, device sheet, navigation, and app lifecycle.
   - `lib/screens/`: composes controller data and callbacks into pages.
   - `lib/widgets/`: reusable presentation and touch controls, including `HoldButton`, `DrivingControls`, `ConnectionStatus`, `DevicePicker`, and `MotorTelemetry`.
   - `lib/theme/app_colors.dart`: shared palette.
   - `lib/controllers/robot_controller.dart`: `ChangeNotifier` state, permissions, BLE sessions, streams, timers, commands, and telemetry.
   - `lib/protocol/robot_protocol.dart`: pure command encoding and status decoding.
3. Reuse constructor-injected values/callbacks and the existing `ListenableBuilder`/`ChangeNotifier` pattern. Keep Bluetooth operations out of widget `build` methods. Do not add a state-management, routing, charting, or design-system dependency for a task the current structure handles.
4. Before extracting a widget, inspect existing equivalents and actual consumers. Use focused immutable constructor contracts, `super.key`, `final` fields, and explicit enabled/pressed/callback meanings. Use `StatefulWidget` only for owned transient state/resources. Keep files in lower_snake_case, types in UpperCamelCase, and local relative imports consistent.
5. Keep the existing Spanish UI and intentional bilingual comments. Telemetry percentages represent reported PWM, not measured speed. Preserve the established left/right steering group and forward/reverse group unless a redesign explicitly changes them.
6. Never create a controller in `build`, dispose an injected controller as though it were owned, restore pressed movement after navigation/reconnection, or remove stop calls while refactoring layouts. Consult `flutter-ble-control` for command/lifecycle changes and `flutter-mobile-design` for visual work.
7. Use `flutter-verification` to select relevant checks. The presence of `linux/` is not proof that the BLE flow supports desktop; Android/iOS are the documented mobile targets. Report device-dependent behavior separately.

## Output

Summarize affected layers, reused widgets/state ownership, and actual verification. This skill does not expand the active agent's edit permissions.
