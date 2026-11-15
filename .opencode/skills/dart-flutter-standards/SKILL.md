---
name: dart-flutter-standards
description: Guides Dart and Flutter code conventions; use when authoring or reviewing Dart code or maintaining Dart guidance under .opencode.
---

# Dart and Flutter Standards

Use project configuration and [Effective Dart](https://dart.dev/effective-dart) as the basis for maintainable code.

## When to use

- Write or review `.dart` code or document its coding conventions in OpenCode assets.
- Do not apply application-code formatting rules to Markdown as though it were Dart.

## Workflow

1. Read the relevant sources, `pubspec.yaml`, and `analysis_options.yaml`. This project enables `package:flutter_lints/flutter.yaml`; the analyzer excludes build and native platform directories. Do not claim native configuration is validated by `flutter analyze`.
2. Follow Dart null safety, lowerCamelCase members, UpperCamelCase types, lower_snake_case files, and the existing import grouping. Use `final` by default, `const` when valid, precise boundary types, and inference where clear. Avoid unnecessary `dynamic`, forced null assertions, casts, lint suppressions, and generic abstractions.
3. Keep `build` pure and inexpensive. Prefer small cohesive widgets, immutable inputs, and localized rebuilds. Do not mutate controller state, start scans, subscribe to streams, or schedule repeated work during rendering.
4. Make asynchronous ownership explicit. Await work when ordering matters; use `unawaited` only deliberately with an understood failure path. Cancel timers/subscriptions and remove observers in their owner's cleanup. After asynchronous gaps, check widget mounting or the relevant controller session before acting; `mounted` alone does not invalidate stale BLE sessions.
5. Preserve callbacks and domain names (`acelerar`, `retroceder`, `girarIzquierda`, `girarDerecha`, `stop`). Use existing error conventions and Spanish messages. Explain non-obvious reasoning in comments rather than narrating syntax.
6. Avoid broad formatting changes and package additions. Format only authorized changed Dart files with `dart format <explicit paths>` when permitted, then use `flutter-verification` for analysis and tests.
7. Consult the installed SDK and official [Dart language](https://dart.dev/language), [Flutter API](https://api.flutter.dev/), and [Flutter lints](https://pub.dev/packages/flutter_lints) when API compatibility is uncertain. Do not upgrade SDK constraints just to use a newer API.

## Output

Report implementation decisions and checks actually performed; preserve unrelated code style and changes.
