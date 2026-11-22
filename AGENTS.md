# Repository Guidelines for Agents

## Overview
Calculate RPW is an offline-first, platform-agnostic Flutter application (Android, Web, Windows, and other Flutter targets) that balances assembly lines using the Helgeson and Birnie Ranked Positional Weight (RPW) method.

## Architecture and Design Rules
- Follow clean layered separation across `lib/core/`, `lib/domain/`, `lib/data/`, `lib/app/`, and `lib/ui/`.
- Keep `lib/domain/` 100% pure Dart with zero `dart:io`, `dart:html`, or Flutter UI imports so business logic stays portable and easy to unit test.
- Use `package:material_ui/material_ui.dart` (Material 3) rather than legacy `package:flutter/material.dart`.
- Apply established design patterns consistently:
  - Strategy: `RpwSolver` and `HelgesonBirnieRpwSolver`
  - Factory: `SampleProblemFactory`
  - Singleton: `ServiceLocator` (always call `ServiceLocator.reset()` in test teardowns)
  - Composite: `ResultNode` (`ResultGroup` and `ResultItem`)
  - MVVM + Repository: `CalculatorViewModel`, `ThemeRepository`, and injected services
- Keep responsive layout decisions strictly driven by `LayoutBuilder` constraints (`WindowSizeClass`) and `MediaQuery.displayFeaturesOf`. Never lock screen orientation or hardcode device types.
- Maintain zero unnecessary Android permissions in `android/app/src/main/AndroidManifest.xml`. Keep release `compileSdk = 37` and `targetSdk = 37` with AGP built-in Kotlin.

## Security and Domain Integrity
- Follow OWASP secure coding practices: validate and bound every input (`AppConstants.maxEdges`, `AppConstants.maxUniqueNodes`, finite non-negative Tek, strictly positive cycle time), detect cycles and disconnected nodes before solving, and prevent infinite loops or division by zero.
- Do not change RPW domain math without explicit maintainer confirmation.
- Never commit secrets, keystores, local filesystem paths, or personally identifiable information (PII).

## Documentation and Prose Style
- Write clear, natural human text across UI copy, Help guides, ADRs, and Markdown documentation.
- Avoid filler phrasing, em dashes, and double hyphens (`--`) in prose.
- Keep inline Dart comments focused on non-obvious intent, and write clean `///` doc comments on public declarations without `@param` or `@return` tags.
- Architecture diagrams live in `.docs/architecture/c4/` (4 Structurizr DSL files and 4 rendered PNGs). ADRs live in `.docs/adrs/` using the Nygard format.

## Required Verification Before Merging
Run these checks from the repository root before finalizing changes:
1. `dart format --output=none --set-exit-if-changed lib test`
2. `dart analyze --fatal-infos lib test`
3. `flutter test`
4. `python .agents/skills/conventional-commit-pii-guard/scripts/scan_pii.py --repo`

## Skills
- Conventional Commit + PII Scanner: `.agents/skills/conventional-commit-pii-guard/SKILL.md`
