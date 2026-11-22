import 'package:material_ui/material_ui.dart';
import 'package:ranked_positional_method/app/di/service_locator.dart';
import 'package:ranked_positional_method/core/constants/app_constants.dart';
import 'package:ranked_positional_method/core/layout/window_size_class.dart';

/// Displays the app's offline privacy commitment, data practices, and version details.
class PrivacyScreen extends StatelessWidget {
  /// Creates a [PrivacyScreen].
  const PrivacyScreen({super.key});

  Future<void> _copyUrl(BuildContext context, String label, String url) async {
    await ServiceLocator.instance.clipboard.copyText(url);
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('Copied $label URL to clipboard.'),
          duration: const Duration(seconds: 4),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colors = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double pad = WindowSizeClass.fromWidth(constraints.maxWidth) == WindowSizeClass.wear
            ? 14
            : 20;

        final List<Widget> items = <Widget>[
          Semantics(
            header: true,
            child: Text(
              'Privacy Policy and About',
              style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Calculate RPW runs completely offline on your device. No personal information, calculations, or usage telemetry ever leaves your phone, browser, or computer.',
            style: textTheme.bodyLarge?.copyWith(color: colors.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          const _PrivacyCard(
            title: 'Data Collection',
            body: 'We do not collect, store on external servers, sell, or share any personal data, device identifiers, location records, crash reports, or analytics.',
          ),
          const SizedBox(height: 12),
          const _PrivacyCard(
            title: 'Local Storage and Permissions',
            body: 'The Android release build requires zero special system permissions. Only your selected theme mode (System, Light, or Dark) is saved locally on your device using platform preferences. Clipboard writes happen only when you activate a result card or Copy button.',
          ),
          const SizedBox(height: 12),
          _PrivacyCard(
            title: 'Standalone Web Privacy Policy',
            body:
                'For Google Play Console verification and web visitors, the full privacy policy is hosted at:\n${AppConstants.privacyPolicyUrl}',
            copyActionLabel: 'Copy privacy policy URL',
            onCopy: () => _copyUrl(context, 'privacy policy', AppConstants.privacyPolicyUrl),
          ),
          const SizedBox(height: 12),
          _PrivacyCard(
            title: 'Application Details',
            body:
                '${AppConstants.appTitle} (${AppConstants.appSubtitle})\nVersion ${AppConstants.appVersion}\nProject Page: ${AppConstants.projectUrl}',
            copyActionLabel: 'Copy project page URL',
            onCopy: () => _copyUrl(context, 'project page', AppConstants.projectUrl),
          ),
        ];

        return SelectionArea(
          child: ListView.builder(
            padding: EdgeInsets.all(pad),
            itemCount: items.length,
            itemBuilder: (BuildContext context, int index) {
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 820),
                  child: SizedBox(width: double.infinity, child: items[index]),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _PrivacyCard extends StatelessWidget {
  const _PrivacyCard({
    required this.title,
    required this.body,
    this.copyActionLabel,
    this.onCopy,
  });

  final String title;
  final String body;
  final String? copyActionLabel;
  final VoidCallback? onCopy;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Semantics(
                    header: true,
                    child: Text(
                      title,
                      style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                if (onCopy != null)
                  IconButton(
                    onPressed: onCopy,
                    tooltip: copyActionLabel,
                    icon: const Icon(Icons.copy_rounded, size: 20),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(body, style: textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
