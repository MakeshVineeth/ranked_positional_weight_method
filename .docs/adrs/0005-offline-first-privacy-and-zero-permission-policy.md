# 5. Offline-First Privacy and Zero-Permission Policy

Date: 2026-11-22

## Status

Accepted

## Context

Calculate RPW is distributed publicly via Google Play Console and GitHub Pages. Industrial engineering calculations often involve internal cycle times and line structures, and users expect a pure calculator utility to request zero invasive permissions and transmit no telemetry.

## Decision

- Strip all `<uses-permission>` declarations from `android/app/src/main/AndroidManifest.xml`, retaining `INTERNET` only in `debug` and `profile` manifests for Flutter tooling.
- Set `android:allowBackup="false"`, `android:usesCleartextTraffic="false"`, and `android:taskAffinity=""` in the Android manifest.
- Store no user inputs on disk; persist only the chosen `ThemeMode` locally via `SharedPreferencesAsync`.
- Include an in-app Privacy screen and publish a standalone static privacy page at `/privacy/` on GitHub Pages for Google Play Console compliance.

## Consequences

- The production Android package requests zero runtime or install-time permissions.
- No third-party analytics SDKs, network clients, or data-collection disclosures are required.
- Google Play Console reviewers and end users can verify the privacy commitment directly at the static `/privacy/` URL.
