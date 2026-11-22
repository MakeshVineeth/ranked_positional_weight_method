# Keep Flutter embedding and plugin reflection classes intact under R8.
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Flutter embedding optionally references Play Core splitcompat/splitinstall when deferred components are unused.
-dontwarn com.google.android.play.core.**
