import 'package:material_ui/material_ui.dart';
import 'package:ranked_positional_method/core/formatting/number_formatter.dart';
import 'package:ranked_positional_method/domain/models/result_node.dart';
import 'package:ranked_positional_method/domain/models/rpw_result.dart';
import 'package:ranked_positional_method/domain/services/sample_problem_factory.dart';
import 'package:ranked_positional_method/ui/core/widgets/copyable_result_card.dart';

/// Lazy sliver list displaying empty guidance or composite RPW results.
class ResultsSliverList extends StatelessWidget {
  /// Creates a lazy [ResultsSliverList].
  const ResultsSliverList({
    super.key,
    required this.result,
    required this.resultSections,
    required this.availableWidth,
    required this.onLoadSample,
    required this.onCopyText,
    required this.onCopyReport,
    this.onEditInputs,
    this.maxWidth,
  });

  /// Latest computed RPW result, or `null` when none is available.
  final RpwResult? result;

  /// Composite sections built from [result].
  final List<ResultGroup> resultSections;

  /// Available horizontal extent used for responsive summary columns without per-scroll relayout.
  final double availableWidth;

  /// Callback invoked when the user loads a sample preset from empty state.
  final void Function(SamplePreset preset) onLoadSample;

  /// Callback invoked with copied item text.
  final Future<void> Function(String text) onCopyText;

  /// Callback invoked to copy the full plain-text report.
  final Future<void> Function() onCopyReport;

  /// Optional callback shown on compact screens to jump back to input fields.
  final VoidCallback? onEditInputs;

  /// Optional maximum width constraint applied to each virtualized item.
  final double? maxWidth;

  Future<void> _copyAndNotify(
    BuildContext context,
    Future<void> Function() action,
    String msg,
  ) async {
    await action();
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(msg),
          duration: const Duration(seconds: 4),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final double textScale = MediaQuery.textScalerOf(context).scale(16) / 16.0;
    final double effectiveWidth = maxWidth != null && availableWidth > maxWidth!
        ? maxWidth!
        : availableWidth;
    final bool twoColumnSummary = (effectiveWidth / textScale) >= 520;
    final List<_ResultDisplayEntry> entries = _flattenEntries(twoColumnSummary);

    return SliverList.builder(
      itemCount: entries.length,
      itemBuilder: (BuildContext context, int index) {
        final Widget child = _buildEntry(context, entries[index]);
        if (maxWidth == null) {
          return child;
        }
        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth!),
            child: child,
          ),
        );
      },
    );
  }

  List<_ResultDisplayEntry> _flattenEntries(bool twoColumnSummary) {
    final RpwResult? current = result;
    if (current == null) {
      return const <_ResultDisplayEntry>[_EmptyStateEntry()];
    }

    final List<_ResultDisplayEntry> entries = <_ResultDisplayEntry>[
      _ResultsHeaderEntry(current),
    ];

    for (int s = 0; s < resultSections.length; s++) {
      final ResultGroup group = resultSections[s];
      entries.add(_SectionHeadingEntry(group.title));
      final List<ResultItem> items = group.children.whereType<ResultItem>().toList(growable: false);

      if (s == 0 && twoColumnSummary) {
        for (int i = 0; i < items.length; i += 2) {
          final ResultItem left = items[i];
          final ResultItem? right = i + 1 < items.length ? items[i + 1] : null;
          entries.add(_SummaryRowEntry(left, right));
        }
      } else {
        for (final ResultItem item in items) {
          entries.add(_SingleCardEntry(item));
        }
      }
    }

    return entries;
  }

  Widget _buildEntry(BuildContext context, _ResultDisplayEntry entry) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return switch (entry) {
      _EmptyStateEntry() => _EmptyResultsState(
        onLoadSample: () => onLoadSample(SamplePreset.classicSixNode),
      ),
      _ResultsHeaderEntry(:final result) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Semantics(
          container: true,
          liveRegion: true,
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 8,
            children: <Widget>[
              Semantics(
                header: true,
                label:
                    'Calculated Results: ${result.workstations.length} workstations, balance delay ${NumberFormatter.formatPercent(result.balanceDelay, decimals: 2)}',
                child: Text(
                  'Calculated Results',
                  style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  if (onEditInputs != null)
                    OutlinedButton.icon(
                      onPressed: onEditInputs,
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Edit Inputs'),
                    ),
                  FilledButton.tonalIcon(
                    onPressed: () => _copyAndNotify(
                      context,
                      onCopyReport,
                      'Copied full RPW report to clipboard.',
                    ),
                    icon: const Icon(Icons.copy_all_rounded),
                    label: const Text('Copy Report'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      _SectionHeadingEntry(:final title) => Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 8),
        child: Semantics(
          header: true,
          child: Text(
            title,
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ),
      _SummaryRowEntry(:final left, :final right) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(child: _buildCopyCard(context, left)),
            const SizedBox(width: 8),
            Expanded(
              child: right != null ? _buildCopyCard(context, right) : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
      _SingleCardEntry(:final item) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: _buildCopyCard(context, item),
      ),
    };
  }

  Widget _buildCopyCard(BuildContext context, ResultItem item) {
    return CopyableResultCard(
      item: item,
      onCopy: (String text) => _copyAndNotify(
        context,
        () => onCopyText(text),
        'Copied "${item.title}" to clipboard.',
      ),
    );
  }
}

sealed class _ResultDisplayEntry {
  const _ResultDisplayEntry();
}

final class _EmptyStateEntry extends _ResultDisplayEntry {
  const _EmptyStateEntry();
}

final class _ResultsHeaderEntry extends _ResultDisplayEntry {
  const _ResultsHeaderEntry(this.result);
  final RpwResult result;
}

final class _SectionHeadingEntry extends _ResultDisplayEntry {
  const _SectionHeadingEntry(this.title);
  final String title;
}

final class _SummaryRowEntry extends _ResultDisplayEntry {
  const _SummaryRowEntry(this.left, this.right);
  final ResultItem left;
  final ResultItem? right;
}

final class _SingleCardEntry extends _ResultDisplayEntry {
  const _SingleCardEntry(this.item);
  final ResultItem item;
}

class _EmptyResultsState extends StatelessWidget {
  const _EmptyResultsState({required this.onLoadSample});

  final VoidCallback onLoadSample;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.account_tree_outlined,
              size: 48,
              color: colors.primary,
            ),
            const SizedBox(height: 12),
            Semantics(
              header: true,
              child: Text(
                'Ready to Balance Your Assembly Line',
                style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add precedence connections, set your final task and cycle time, then select Calculate. Activate any result card later to copy it.',
              style: textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.tonalIcon(
              onPressed: onLoadSample,
              icon: const Icon(Icons.play_circle_outline_rounded),
              label: const Text('Try 6-Node Sample'),
            ),
          ],
        ),
      ),
    );
  }
}
