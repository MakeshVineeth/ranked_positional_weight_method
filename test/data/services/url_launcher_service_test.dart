import 'package:flutter_test/flutter_test.dart';
import 'package:ranked_positional_method/data/services/url_launcher_service.dart';

void main() {
  const FlutterUrlLauncherService service = FlutterUrlLauncherService();

  test('openExternalUrl rejects non-HTTPS schemes and empty hosts', () async {
    final List<Uri> disallowed = <Uri>[
      Uri.parse('http://example.com'),
      Uri.parse('javascript:alert(1)'),
      Uri.parse('file:///tmp/test'),
      Uri.parse('mailto:test@example.com'),
      Uri.parse('https://'),
    ];

    for (final Uri uri in disallowed) {
      final bool launched = await service.openExternalUrl(uri);
      expect(launched, isFalse, reason: 'Expected rejection for $uri');
    }
  });
}
