import 'package:material_ui/material_ui.dart';

/// Compact live-region banner displaying validation or solver errors inline.
class InlineErrorBanner extends StatelessWidget {
  /// Creates an [InlineErrorBanner] for [message].
  const InlineErrorBanner({
    super.key,
    required this.message,
  });

  /// Error text shown to the user.
  final String message;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Semantics(
      container: true,
      liveRegion: true,
      child: Card(
        color: colors.errorContainer,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: <Widget>[
              Icon(
                Icons.error_outline_rounded,
                color: colors.onErrorContainer,
                semanticLabel: 'Error',
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colors.onErrorContainer,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
