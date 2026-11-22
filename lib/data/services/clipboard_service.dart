import 'package:flutter/services.dart';

/// Abstraction for copying text to the host system clipboard.
abstract interface class ClipboardAdapter {
  /// Copies [text] to the system clipboard.
  Future<void> copyText(String text);
}

/// Platform-agnostic [ClipboardAdapter] using Flutter's built-in [Clipboard].
class FlutterClipboardService implements ClipboardAdapter {
  const FlutterClipboardService();

  @override
  Future<void> copyText(String text) {
    return Clipboard.setData(ClipboardData(text: text));
  }
}
