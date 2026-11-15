---
name: project-readme-maintenance
description: Maintains agbot Flutter project README.md files; use ONLY when the user asks to create, update, review, or audit those files.
---

# Project README Maintenance

Maintain accurate, useful README files by grounding every change in verifiable project sources and preserving the target document's established conventions.

## When to use

- The user requests a new README or changes to an existing `README.md` file.
- Commands, setup, environment modes, architecture, usage, or deployment documentation must be created or corrected.
- Do not use this skill for application code, OpenCode configuration, or documentation other than `README.md`.

## Workflow

1. Identify the exact README target. If several files could match and the user did not select one, request clarification.
2. Read the complete target file and inspect `pubspec.yaml`, `pubspec.lock`, `analysis_options.yaml`, relevant `lib/` and `test/` sources, and native Android/iOS configuration when relevant. The Dart package is `remotecontrol`, the repository directory is `botcontrol`, and the app is `agbot control`; distinguish these names. Preserve the existing Spanish README.
3. Preserve the target's language, structure, tone, formatting, valid examples, and unrelated content. Repository documentation that is already in Spanish should remain in Spanish unless the user requests a change.
4. Document only verified commands, paths, dependencies, architecture, and platform behavior. The project uses Flutter commands such as `flutter pub get`, `flutter run`, `flutter analyze`, `flutter test`, and `flutter build apk --debug`; the OpenCode tooling package is not the app build system. Verify SDK requirements from current metadata/tool output, and do not imply Linux can build/sign iOS. Explain physical BLE phone/ESP32 requirements when documenting connection or movement. Treat external firmware paths as references, not portable setup requirements or authorization to modify firmware. Distinguish app-verified behavior from README-only firmware claims; PWM percentages are not measured speed. Never present a recommendation or an unrun device check as an implemented fact.
5. Update the smallest relevant section, avoid duplication, and do not create or edit any non-README file.
6. Re-read the result, check Markdown correctness and internal consistency, and compare every changed claim with its source again.
7. If command execution is available and permitted, validate documented commands where safe; otherwise state that only source-based verification was possible.

## Output

Report the README files changed, the verified content improvements, and the checks performed. Keep user-facing README content in the target document's established language, and state when runtime validation was not performed.
