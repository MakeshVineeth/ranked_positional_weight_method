import 'package:material_ui/material_ui.dart';
import 'package:ranked_positional_method/domain/models/result_node.dart';

/// Card displaying a single [ResultItem] that copies its content when activated.
class CopyableResultCard extends StatelessWidget {
  /// Creates a copyable card for [item].
  const CopyableResultCard({
    super.key,
    required this.item,
    required this.onCopy,
  });

  static const BorderRadius _cardRadius = BorderRadius.all(Radius.circular(16));

  /// Leaf result data displayed inside the card.
  final ResultItem item;

  /// Callback invoked with the formatted text when the user activates the card.
  final Future<void> Function(String text) onCopy;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final String copyPayload = item.subtitle == null
        ? '${item.title}: ${item.value}'
        : '${item.title}: ${item.value} (${item.subtitle})';

    return Semantics(
      button: true,
      excludeSemantics: true,
      label: copyPayload,
      onTapHint: 'copy to clipboard',
      child: Material(
        type: MaterialType.card,
        color: item.isHighlighted ? colors.primaryContainer : colors.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: _cardRadius,
          side: BorderSide(
            color: item.isHighlighted ? colors.primary : colors.outlineVariant,
            width: item.isHighlighted ? 1.5 : 1.0,
          ),
        ),
        clipBehavior: Clip.none,
        child: InkWell(
          borderRadius: _cardRadius,
          focusColor: colors.primary.withValues(alpha: 0.24),
          onTap: () => onCopy(copyPayload),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: <Widget>[
                  if (item.isHighlighted) ...<Widget>[
                    Icon(
                      Icons.star_rounded,
                      size: 18,
                      color: colors.onPrimaryContainer,
                    ),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          item.title,
                          style: textTheme.labelMedium?.copyWith(
                            color: item.isHighlighted
                                ? colors.onPrimaryContainer
                                : colors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.value,
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: item.isHighlighted
                                ? colors.onPrimaryContainer
                                : colors.onSurface,
                          ),
                        ),
                        if (item.subtitle != null) ...<Widget>[
                          const SizedBox(height: 2),
                          Text(
                            item.subtitle!,
                            style: textTheme.bodySmall?.copyWith(
                              color: item.isHighlighted
                                  ? colors.onPrimaryContainer
                                  : colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.copy_rounded,
                    size: 18,
                    color: item.isHighlighted ? colors.onPrimaryContainer : colors.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
