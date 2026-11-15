---
name: flutter-mobile-design
description: Guides mobile UX, Material 3 theming, adaptive Flutter layouts, and accessibility; use when designing, styling, or reviewing the agbot interface.
---

# Flutter Mobile Interface Design

Design a touch-first mobile robot remote with clear connection state, readable telemetry, predictable two-thumb driving, and an immediately reachable stop action. Preserve the established dark identity and Spanish copy unless the user requests a redesign. This skill grants no additional editing permissions.

## When to use

- Design or refine Flutter screens, widgets, typography, colors, spacing, icons, motion, adaptive layout, or visual accessibility.
- Review presentation changes for usability and consistency.
- Do not use for transport/protocol implementation; load `flutter-ble-control` when presentation touches driving inputs or stop/lifecycle wiring.

## Workflow

1. Inspect `lib/app.dart`, `lib/theme/app_colors.dart`, affected layouts/screens/widgets, and existing tests. Identify the primary task, the current visual hierarchy, the smallest available window, and the states users must distinguish. For substantial redesigns, state a concise visual direction tied to driving usability before implementation; do not impose a generic dashboard.
2. Compose a restrained hierarchy: driving controls dominate; connection and reported PWM remain glanceable; secondary help/settings belong in the existing navigation. Preserve the steering-left and acceleration-right spatial model. Keep `DETENER` visible and reachable, visually distinct from navigation, without a confirmation dialog, gesture, animation, or scrolling delay. Never place a modal over active driving without preserving the existing stop request.
3. Use theme roles rather than scattered values: reuse `AppColors`, `Theme.of(context).colorScheme`, `textTheme`, and component themes. Keep surface/on-surface, primary/on-primary, and error/on-error pairs coherent in dark mode. Centralize new shared tokens only when reused; a spacing rhythm based on 4/8 logical pixels and a small consistent radius/type scale are design heuristics, not Flutter requirements. Prefer installed Material icons and system fonts; add no package or asset registration for decoration alone.
4. Adapt to **available constraints**, not device brand, platform, or orientation alone. Use `LayoutBuilder` for local constraints and targeted `MediaQuery` accessors for window/text/inset information. Choose breakpoints where content stops fitting, considering height as well as width. Keep both portrait and landscape usable, support resize/split screen, and bound content widths on larger displays instead of stretching everything. Do not lock orientation to hide overflow.
5. Respect Flutter constraints: avoid `Expanded` in an unbounded scrolling axis, hard-coded screen heights, and repeated intrinsic measurement as layout fixes. Allow text wrapping and flexible sizing. Use `SafeArea` around critical content, accounting for the layout's existing safe area and AppBar; check landscape side cutouts, bottom gesture areas, and modal sheet/keyboard `viewInsets` where relevant. Do not shrink labels or disable scaling to force a layout to fit. Keep secondary content scrollable where necessary while protecting primary driving access.
6. Design comfortable touch targets: use at least **48x48 logical pixels** as the shared project baseline (Flutter's Android guideline is 48; its iOS guideline is 44). Driving buttons should generally be much larger for sustained thumb use. Measure the actual hit region, not just the icon, and separate adjacent targets. Avoid `MaterialTapTargetSize.shrinkWrap` or compact density that silently breaks target sizes. The larger baseline is a project choice, not a claim that all platform minima are identical.
7. Make states unmistakable: connected, scanning, connecting, disconnected, error, output fault, enabled, disabled, and pressed where relevant. Pair colors with text/icons/shapes; do not depend on a tiny colored dot. Use honest action labels and recovery messages for denied permissions, Bluetooth off, empty scan results, and connection loss. Do not show stale telemetry as live after disconnect, or label PWM as measured speed. Critical errors must remain discoverable rather than being available only as truncated text.
8. Preserve OS text scaling, including nonlinear scaling through current `TextScaler` APIs supported by the installed SDK. Use readable text-theme styles and suitable line heights. Verify narrow windows and enlarged text before truncating; never cap scaling globally or rely on `FittedBox` to reduce essential labels. Aim for contrast of at least **4.5:1** for normal text, **3:1** for large text, and **3:1** for meaningful non-text controls/state indicators against adjacent colors. Measure actual composited foreground/background colors, including opacity, rather than guessing from hex values. These are WCAG-derived design targets, not a claim of full accessibility compliance.
9. Prefer standard Material controls for ordinary actions, with accessible names, tooltips for icon-only actions, visible focus, and logical traversal. For custom controls, inspect `Semantics` labels, values, enabled/button state, and duplicated descendant announcements. Avoid announcing every telemetry update as a live region. A semantics label alone does not make a raw-pointer hold button screen-reader-operable. If an accessible input alternative is requested, coordinate the behavior change through `FlutterExpert` or `BLEExpert`, preserving release/stop semantics; never invent a latched semantic tap-to-drive action in a styling task.
10. Preserve `HoldButton` pointer ownership, eager gesture handling, independent multitouch, release/up/cancel/leave behavior, and enabled/pressed callback contracts. Do not replace `Listener` with `onTap`/`onLongPress` for a visual effect, change widget identity during a press, or put absorbing overlays over active controls. Keep controller creation/ownership and layout lifecycle/navigation stop calls intact.
11. Give immediate state feedback without delaying command dispatch. Keep nonessential animations subtle and short (roughly 100–200 ms is a starting heuristic); honor `MediaQuery.disableAnimationsOf(context)` or an installed-SDK-compatible equivalent. Do not animate hit-region positions while pressed or smooth away error/stop feedback. Avoid heavy blur, repeated opacity layers, large shadows, and perpetual decorative animation on the driving screen. Use small `const` widgets and localized rebuilds; profile actual bottlenecks before adding `RepaintBoundary` or other optimizations.
12. Follow `flutter-verification`: check affected states, narrow portrait/short landscape, text enlargement, insets, target size, semantics, and gesture regressions. Use screenshots/goldens only with a meaningful baseline and intentional visual-review task; source inspection alone does not establish rendering or accessibility success. Validate thumb comfort and assistive interaction on devices when available.

## Official references and scope of recommendations

Consulted on 2026-11-15; online docs can target a newer SDK, so check local compatibility before using APIs.

- [Flutter adaptive best practices](https://docs.flutter.dev/ui/adaptive-responsive/best-practices): touch first, small widgets, window-based layouts, orientation support.
- [SafeArea and MediaQuery](https://docs.flutter.dev/ui/adaptive-responsive/safearea-mediaquery): cutouts, system insets, text and accessibility settings.
- [Material Design for Flutter](https://docs.flutter.dev/ui/design/material) and [Material 3](https://m3.material.io/develop/flutter): design-system integration; retain the project's existing Material 3 choice on mobile.
- [Flutter accessible UI design](https://docs.flutter.dev/ui/accessibility/ui-design-and-styling): text enlargement, contrast and platform target guidance.
- [Flutter accessibility testing](https://docs.flutter.dev/ui/accessibility/accessibility-testing): guideline APIs and native inspection tools.
- [Flutter performance best practices](https://docs.flutter.dev/perf/best-practices): rebuild cost, layers, clipping, intrinsic layout, profiling.
- [Apple Human Interface Guidelines: accessibility](https://developer.apple.com/design/human-interface-guidelines/accessibility): perceivable states, text enlargement, comfortable controls, spacing, alternatives to gestures, reduced motion.

The two-thumb grouping, always-reachable stop, dark identity, spacing rhythm, and suggested animation range are project design decisions. Accessibility improvements must be evaluated against the actual control behavior, not only these references.

## Output

Summarize visual changes and their usability rationale, affected files, tested sizes/states/accessibility properties, and any pending device checks. Clearly separate observed results from recommendations.
