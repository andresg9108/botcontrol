---
name: flutter-verification
description: Selects Flutter analysis, unit/widget, accessibility, and device checks; use when verifying application changes or reviewing test coverage in this project.
---

# Flutter Verification

Choose checks proportionate to the change and run only commands allowed by the active agent. Do not claim static inspection proves device behavior.

## When to use

- Verify Dart/Flutter application changes or review meaningful test coverage.
- Consult while writing project-specific verification guidance.
- For OpenCode Markdown-only changes, validate frontmatter, skill references, permissions, and content instead of running Flutter builds.

## Workflow

Before starting or attaching to any runtime debugging session (including `flutter run`, `flutter attach`, IDE debug launches, or DevTools), obtain the user's explicit permission. The user prefers to manage debugging manually in another terminal; request their session output when needed. A general verification request does not grant this permission. Formatting, analysis, automated tests, and build-only commands follow the normal rules below.

1. Read existing tests and identify what can regress. Current coverage includes `test/robot_protocol_test.dart` (binary contract), `test/control_screen_test.dart` (multitouch and lifecycle), and `test/widget_test.dart` (navigation, connection retention, and 800x360/360x800 layouts). These are examples, not proof of full BLE coverage.
   - Control-behavior widget tests inject `RobotController()..connected = true`; other startup/layout cases use the default disconnected app. The BLE client is lazy and no writer is configured. Assertions cover local button state and widget behavior, not actual writes, scan/permission flows, notifications, session races, or reconnects. Pointer-leave, output-fault, device-picker, and assistive-operation checks are suggested scenarios below, not established existing coverage.
2. For Dart edits, format explicit changed paths where allowed, run `flutter analyze`, and run the relevant tests with `flutter test <test paths>`. Run `flutter test` when shared control/navigation/protocol behavior affects the suite. Do not add tests that merely mirror a cosmetic constant or run the same passing checks repeatedly without new reasons.
3. For layout/accessibility work, select representative logical sizes: 360x800 portrait and 800x360 landscape as existing regression anchors; add a narrow 320-wide case, tablet, split window, or short landscape when relevant. Check default and enlarged text (including 2x and the largest available OS setting), display insets, long Spanish names/errors, and all affected connection/fault states. Restore modified tester view properties and dispose test resources.
4. Use real simultaneous gestures with separate pointer IDs for drive controls. Verify release/cancel/leave, opposite directions, opening the menu, navigation, backgrounding, disabled/fault states, and stop as relevant. Keep test controllers injectable so widget tests need not initialize the BLE plugin.
5. For meaningful accessibility changes, inspect semantics and use `tester.ensureSemantics()` with appropriate `androidTapTargetGuideline`, `iOSTapTargetGuideline`, `labeledTapTargetGuideline`, and `textContrastGuideline` checks. Dispose the semantics handle. Raw pointer controls may expose no semantic tap action: a passing guideline cannot establish they work with a screen reader. Verify custom hold controls separately.
6. Run `flutter build apk --debug` when Android native/build configuration or packaging changed and tools are available. Do not build an APK for Markdown-only or trivial visual edits. iOS build/signing requires macOS/Xcode; do not report it as verified from Linux.
7. On a device, check thumb reach, two-finger use, stop visibility, cutouts/gesture navigation, TalkBack/VoiceOver, and BLE workflows affected by the change. Profile performance in profile mode when there is a measured rendering concern; do not infer frame times from debug mode or static code.
8. Inspect relevant diffs and new files. Report actual command results and failures; distinguish an environment/tool restriction from a failing application check.

## References

- [Flutter testing](https://docs.flutter.dev/testing/overview).
- [Accessibility testing](https://docs.flutter.dev/ui/accessibility/accessibility-testing).
- [Performance profiling](https://docs.flutter.dev/perf/ui-performance).

## Output

List performed checks and results, plus any specific pending device/runtime verification relevant to the change. Follow `final-answers-and-considerations`.
