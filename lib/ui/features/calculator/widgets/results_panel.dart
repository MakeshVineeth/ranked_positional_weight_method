import 'package:material_ui/material_ui.dart';
import 'package:ranked_positional_method/core/formatting/number_formatter.dart';
import 'package:ranked_positional_method/domain/models/result_node.dart';
import 'package:ranked_positional_method/domain/models/rpw_result.dart';
import 'package:ranked_positional_method/domain/services/sample_problem_factory.dart';
import 'package:ranked_positional_method/ui/core/widgets/copyable_result_card.dart';
import 'package:ranked_positional_method/ui/features/calculator/view_models/calculator_view_model.dart';

/// Displays validation messages, empty guidance, or composite RPW calculation results.
class ResultsPanel extends StatelessWidget {
  /// Creates a [ResultsPanel] bound to [viewModel].
  const ResultsPanel({
    super.key,
    required this.viewModel,
  });

  /// ViewModel supplying results, errors, and clipboard copy actions.
  final CalculatorViewModel viewModel;

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
    final ColorScheme colors = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final String? error = viewModel.errorMessage;
    final RpwResult? result = viewModel.result;
    final List<ResultGroup> sections = viewModel.resultSections;
    final double textScale = MediaQuery.textScalerOf(context).scale(16) / 16.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (error != null) ...<Widget>[
          Semantics(
            container: true,
            liveRegion: true,
            child: Card(
              color: colors.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(14),
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
                        error,
                        style: textTheme.bodyMedium?.copyWith(color: colors.onErrorContainer),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        if (result == null)
          _EmptyResultsState(
            onLoadSample: () => viewModel.loadSample(SamplePreset.classicSixNode),
          )
        else ...<Widget>[
          Semantics(
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
                FilledButton.tonalIcon(
                  onPressed: () => _copyAndNotify(
                    context,
                    viewModel.copyFullReport,
                    'Copied full RPW report to clipboard.',
                  ),
                  icon: const Icon(Icons.copy_all_rounded),
                  label: const Text('Copy Report'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          for (int i = 0; i < sections.length; i++) ...<Widget>[
            _buildGroup(context, sections[i], isSummary: i == 0, textScale: textScale),
            const SizedBox(height: 16),
          ],
        ],
      ],
    );
  }

  Widget _buildGroup(
    BuildContext context,
    ResultGroup group, {
    required bool isSummary,
    required double textScale,
  }) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final List<ResultItem> items = group.children.whereType<ResultItem>().toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Semantics(
          header: true,
          child: Text(
            group.title,
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 8),
        if (isSummary)
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final double effectiveWidth = constraints.maxWidth / textScale;
              if (effectiveWidth < 520) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    for (int i = 0; i < items.length; i++) ...<Widget>[
                      _buildCopyCard(context, items[i]),
                      if (i < items.length - 1) const SizedBox(height: 8),
                    ],
                  ],
                );
              }
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: items
                    .map((ResultItem item) {
                      return SizedBox(
                        width: (constraints.maxWidth - 8) / 2,
                        child: _buildCopyCard(context, item),
                      );
                    })
                    .toList(growable: false),
              );
            },
          )
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              for (int i = 0; i < items.length; i++) ...<Widget>[
                _buildCopyCard(context, items[i]),
                if (i < items.length - 1) const SizedBox(height: 8),
              ],
            ],
          ),
      ],
    );
  }

  Widget _buildCopyCard(BuildContext context, ResultItem item) {
    return CopyableResultCard(
      item: item,
      onCopy: (String text) => _copyAndNotify(
        context,
        () => viewModel.copyText(text),
        'Copied "${item.title}" to clipboard.',
      ),
    );
  }
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
