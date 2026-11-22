import 'package:url_launcher/url_launcher.dart';

/// Abstraction for opening validated external URLs outside the application.
abstract interface class UrlLauncherAdapter {
  /// Attempts to open [uri] in an external browser or tab, returning whether launch succeeded.
  Future<bool> openExternalUrl(Uri uri);
}

/// Cross-platform [UrlLauncherAdapter] enforcing HTTPS allowlist validation.
class FlutterUrlLauncherService implements UrlLauncherAdapter {
  /// Creates a [FlutterUrlLauncherService].
  const FlutterUrlLauncherService();

  @override
  Future<bool> openExternalUrl(Uri uri) async {
    if (uri.scheme != 'https' || uri.host.isEmpty) {
      return false;
    }
    try {
      return await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
        webOnlyWindowName: '_blank',
      );
    } on Object {
      return false;
    }
  }
}
