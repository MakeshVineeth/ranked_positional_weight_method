import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:ranked_positional_method/app/di/service_locator.dart';
import 'package:ranked_positional_method/core/constants/app_constants.dart';
import 'package:ranked_positional_method/core/layout/window_size_class.dart';
import 'package:ranked_positional_method/data/services/url_launcher_service.dart';
import 'package:url_launcher/link.dart';

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

  Future<void> _openUrl(BuildContext context, String label, Uri uri) async {
    final bool launched = await ServiceLocator.instance.urlLauncher.openExternalUrl(uri);
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('Could not open $label. Use the copy button to copy the link.'),
            duration: const Duration(seconds: 4),
          ),
        );
    }
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
            body: 'For Google Play Console verification and web visitors, the full privacy policy is hosted at:',
            linkUrl: AppConstants.privacyPolicyUrl,
            onOpenLink: () => _openUrl(
              context,
              'privacy policy',
              Uri.parse(AppConstants.privacyPolicyUrl),
            ),
            copyActionLabel: 'Copy privacy policy URL',
            onCopy: () => _copyUrl(context, 'privacy policy', AppConstants.privacyPolicyUrl),
          ),
          const SizedBox(height: 12),
          _PrivacyCard(
            title: 'Application Details',
            body:
                '${AppConstants.appTitle} (${AppConstants.appSubtitle})\nVersion ${AppConstants.appVersion}\nProject Page:',
            linkUrl: AppConstants.projectUrl,
            onOpenLink: () => _openUrl(
              context,
              'project page',
              Uri.parse(AppConstants.projectUrl),
            ),
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
    this.linkUrl,
    this.onOpenLink,
    this.copyActionLabel,
    this.onCopy,
  });

  final String title;
  final String body;
  final String? linkUrl;
  final VoidCallback? onOpenLink;
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
            if (linkUrl != null && onOpenLink != null) ...<Widget>[
              const SizedBox(height: 4),
              _ExternalHyperlink(
                url: linkUrl!,
                onOpenLink: onOpenLink!,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ExternalHyperlink extends StatelessWidget {
  const _ExternalHyperlink({
    required this.url,
    required this.onOpenLink,
  });

  final String url;
  final VoidCallback onOpenLink;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colors = Theme.of(context).colorScheme;

    Widget buildSurface(VoidCallback? onTap) {
      return InkWell(
        borderRadius: BorderRadius.circular(8),
        mouseCursor: SystemMouseCursors.click,
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    url,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colors.primary,
                      decoration: TextDecoration.underline,
                      decorationColor: colors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.open_in_new_rounded,
                  size: 18,
                  color: colors.primary,
                ),
              ],
            ),
          ),
        ),
      );
    }

    final Widget interactiveLink =
        kIsWeb && ServiceLocator.instance.urlLauncher is FlutterUrlLauncherService
        ? Link(
            uri: Uri.parse(url),
            target: LinkTarget.blank,
            builder: (BuildContext context, FollowLink? followLink) => buildSurface(followLink),
          )
        : Semantics(
            link: true,
            child: buildSurface(onOpenLink),
          );

    return SelectionContainer.disabled(child: interactiveLink);
  }
}
