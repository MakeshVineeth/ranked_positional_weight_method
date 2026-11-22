# 1. Layered MVVM Architecture and State Management

Date: 2026-11-22

## Status

Accepted

## Context

The legacy application kept UI widgets, input validation, mutable calculation arrays, and the RPW solver inside a single stateful widget (`Home.dart`). This tight coupling made unit testing impossible, risked state leaks across runs, and mixed platform clipboard and theme logic directly with domain math.

## Decision

Adopt a clean layered architecture organized into `core`, `domain`, `data`, `app`, and `ui`:

- Keep `lib/domain/` strictly pure Dart with zero Flutter or platform dependencies.
- Apply clear design patterns where they fit naturally:
  - Strategy (`RpwSolver` and `HelgesonBirnieRpwSolver`)
  - Factory (`SampleProblemFactory`)
  - Singleton (`ServiceLocator` with test reset support)
  - Composite (`ResultNode`, `ResultGroup`, and `ResultItem`)
- Use standard `ChangeNotifier` ViewModels (`CalculatorViewModel`) and Repositories (`ThemeRepository`) wired via `Provider`, paired with `go_router` (`StatefulShellRoute.indexedStack`) for declarative routing.

## Consequences

- Domain algorithms, validation rules, and ViewModel transitions can be verified directly with fast unit tests.
- Replacing storage, clipboard, or solver implementations requires only swapping an injected interface in `ServiceLocator`.
- Contributors must keep business calculations inside `lib/domain/` rather than UI widget state.
