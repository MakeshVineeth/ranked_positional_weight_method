# 2. Platform-Agnostic Design and Adaptive Material 3 UI

Date: 2026-11-22

## Status

Accepted

## Context

The legacy app used Material 2 theming (`primarySwatch`, `headline6`), relied on older third-party packages (`theme_provider`, `clipboard`, `flutter_fadein`), and scaled a single vertical column only by raw `MediaQuery` width divisions. Modern deployments must work well across phones (compact to large), foldables, tablets, Wear OS watches, resizable multi-window desktop panes, and Web browsers without platform-specific forks in business or UI logic.

## Decision

- Upgrade UI imports to `package:material_ui/material_ui.dart` and Material 3 (`ColorScheme.fromSeed`).
- Drive every responsive transition from `LayoutBuilder` constraints via `WindowSizeClass` breakpoints (`wear` under 300dp, `compact`, `medium`, `expanded`, and `large`) rather than checking device OS or locking screen orientation.
- Support foldable hinges and display cutouts using `SafeArea`, edge-to-edge system chrome, `DisplayFeatureSubScreen`, and `android:windowLayoutInDisplayCutoutMode = shortEdges`.
- Replace legacy clipboard and theme packages with Flutter's built-in `Clipboard` API and `shared_preferences`, ensuring identical Dart code runs on Android, Web, and Windows.

## Consequences

- Layouts adapt smoothly when windows resize, split screens activate, or foldables unfold.
- Removing legacy third-party UI dependencies shrinks dependency surface and eliminates null-safety and platform compatibility drift.
- Wear OS users receive a streamlined preset-driven view instead of cramped multi-column text inputs.
