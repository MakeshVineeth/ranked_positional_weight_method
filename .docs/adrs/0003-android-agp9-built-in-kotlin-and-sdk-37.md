# 3. Android AGP 9 Built-in Kotlin and SDK 37 Target

Date: 2026-11-22

## Status

Accepted

## Context

The project's Android build used legacy Groovy scripts (`build.gradle`), Gradle 5.6.2, AGP 3.5.0, Kotlin 1.3.50, `compileSdkVersion 29`, `targetSdkVersion 29`, and deprecated `jcenter()` / Jetifier settings. Google Play requires targeting recent Android SDK releases, and modern Flutter toolchains expect Kotlin DSL (`*.kts`), Java 17 bytecode, and AGP 9 built-in Kotlin support.

## Decision

- Migrate all Android Gradle scripts to Kotlin DSL (`settings.gradle.kts`, `build.gradle.kts`, `app/build.gradle.kts`).
- Upgrade the Gradle wrapper to `9.5.0` and Android Gradle Plugin to `9.3.1`.
- Target `compileSdk = 37`, `targetSdk = 37`, and `minSdk = 24`.
- Remove the external `org.jetbrains.kotlin.android` plugin and rely on AGP 9 built-in Kotlin (`kotlin { compilerOptions { jvmTarget = JvmTarget.JVM_17 } }`).
- Enable R8 shrinking and resource shrinking (`isMinifyEnabled = true`, `isShrinkResources = true`) with ProGuard keep rules for Flutter embedding.
- Remove deprecated `android.enableJetifier` and `android.enableR8` properties, and move `MainActivity` to `com.makeshtech.rpw`.

## Consequences

- Release APKs and AABs satisfy modern Google Play SDK and R8 optimization requirements.
- Dropping the standalone Kotlin Gradle plugin avoids AGP 9 plugin conflicts and reduces build script boilerplate.
- Note: If Flutter's Gradle plugin triggers `DisableNewDslMigration`, `android.newDsl=false` may be retained in `gradle.properties` solely until Flutter removes legacy AGP DSL hooks; `android.builtInKotlin` remains enabled.
