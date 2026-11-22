import 'package:material_ui/material_ui.dart';
import 'package:ranked_positional_method/core/formatting/number_formatter.dart';
import 'package:ranked_positional_method/domain/models/rpw_result.dart';
import 'package:ranked_positional_method/domain/services/sample_problem_factory.dart';
import 'package:ranked_positional_method/ui/features/calculator/view_models/calculator_view_model.dart';

/// Streamlined RPW calculator view designed for round and sub-300dp Wear OS screens.
class WearCalculatorView extends StatelessWidget {
  /// Creates a [WearCalculatorView] bound to [viewModel].
  const WearCalculatorView({
    super.key,
    required this.viewModel,
  });

  /// ViewModel supplying calculation state and sample triggers.
  final CalculatorViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colors = Theme.of(context).colorScheme;
    final RpwResult? result = viewModel.result;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      children: <Widget>[
        Semantics(
          header: true,
          child: Text(
            'RPW Quick Solve',
            style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 8),
        for (final SamplePreset preset in SamplePreset.values) ...<Widget>[
          FilledButton.tonal(
            onPressed: () => viewModel.loadSample(preset),
            child: Text(
              preset.label,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 6),
        ],
        if (viewModel.errorMessage != null) ...<Widget>[
          const SizedBox(height: 4),
          Semantics(
            container: true,
            liveRegion: true,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(Icons.error_outline_rounded, size: 16, color: colors.error),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    'Error: ${viewModel.errorMessage}',
                    style: textTheme.bodySmall?.copyWith(color: colors.error),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ],
        if (result != null) ...<Widget>[
          const SizedBox(height: 8),
          Semantics(
            container: true,
            liveRegion: true,
            child: MergeSemantics(
              child: Card(
                color: colors.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: <Widget>[
                      Text(
                        '${result.workstations.length} Stations',
                        style: textTheme.titleMedium?.copyWith(
                          color: colors.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Delay: ${NumberFormatter.formatPercent(result.balanceDelay, decimals: 1)}',
                        style: textTheme.bodySmall?.copyWith(color: colors.onPrimaryContainer),
                      ),
                      Text(
                        'Rate: ${NumberFormatter.format(result.productionRate)}/m',
                        semanticsLabel:
                            'Production rate: ${NumberFormatter.format(result.productionRate)} units per minute',
                        style: textTheme.bodySmall?.copyWith(color: colors.onPrimaryContainer),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (result.unassignableEntries.isNotEmpty) ...<Widget>[
            const SizedBox(height: 6),
            Card(
              color: colors.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  'Blocked nodes: ${result.unassignableEntries.map((NodeRpwEntry e) => 'N${e.nodeId}').join(', ')}',
                  style: textTheme.bodySmall?.copyWith(color: colors.onErrorContainer),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
          const SizedBox(height: 6),
          for (final Workstation station in result.workstations) ...<Widget>[
            MergeSemantics(
              child: Card(
                color: station.exceedsCycleTime ? colors.errorContainer : null,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'S${station.stationNumber}: ${station.nodeIds.map((int id) => 'N$id').join(', ')}',
                        semanticsLabel:
                            'Station ${station.stationNumber}: nodes ${station.nodeIds.join(', ')}',
                        style: textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: station.exceedsCycleTime ? colors.onErrorContainer : null,
                        ),
                      ),
                      Text(
                        station.exceedsCycleTime
                            ? 'Load ${NumberFormatter.format(station.totalTime)} (Exceeds cycle time)'
                            : 'Load ${NumberFormatter.format(station.totalTime)}, Idle ${NumberFormatter.format(station.idleTime)}',
                        style: textTheme.bodySmall?.copyWith(
                          color: station.exceedsCycleTime
                              ? colors.onErrorContainer
                              : colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
          ],
          OutlinedButton(
            onPressed: viewModel.clearAll,
            child: const Text('Clear'),
          ),
        ],
        const SizedBox(height: 16),
      ],
    );
  }
}
