import 'package:ranked_positional_method/core/formatting/number_formatter.dart';
import 'package:ranked_positional_method/domain/models/result_node.dart';
import 'package:ranked_positional_method/domain/models/rpw_result.dart';

/// Builds a [ResultGroup] composite tree and plain-text report from [RpwResult].
class RpwOutputComposer {
  const RpwOutputComposer();

  /// Composes structured UI sections from [result].
  List<ResultGroup> buildSections(RpwResult result) {
    final List<ResultGroup> sections = <ResultGroup>[
      _buildSummaryGroup(result),
      _buildWorkstationsGroup(result),
      _buildRankedTableGroup(result),
      if (result.arrowChains.isNotEmpty) _buildArrowChainsGroup(result),
      _buildNodesWithTekGroup(result),
    ];

    if (result.unassignableEntries.isNotEmpty) {
      sections.add(_buildBlockedNodesGroup(result));
    }
    return sections;
  }

  /// Renders all sections of [result] as plain text ready for clipboard export.
  String toPlainText(RpwResult result) {
    final StringBuffer buffer = StringBuffer();
    for (final ResultGroup group in buildSections(result)) {
      _writeNode(buffer, group, 0);
      buffer.writeln();
    }
    return buffer.toString().trimRight();
  }

  ResultGroup _buildSummaryGroup(RpwResult result) {
    return ResultGroup(
      title: 'Line Summary',
      children: <ResultNode>[
        ResultItem(
          title: 'Workstations',
          value: result.workstations.length.toString(),
          subtitle: 'Cycle time target: ${NumberFormatter.format(result.cycleTime)}',
          isHighlighted: true,
        ),
        ResultItem(
          title: 'Balance Delay',
          value: NumberFormatter.formatPercent(result.balanceDelay, decimals: 2),
          subtitle: 'Ratio: ${NumberFormatter.format(result.balanceDelay)}',
          isHighlighted: true,
        ),
        ResultItem(
          title: 'Line Efficiency',
          value: NumberFormatter.formatPercent(result.lineEfficiency, decimals: 2),
          subtitle: 'Total Tek: ${NumberFormatter.format(result.totalTek)}',
        ),
        ResultItem(
          title: 'Production Rate',
          value: '${NumberFormatter.format(result.productionRate)} units/min',
          subtitle: 'Bottleneck station load: ${NumberFormatter.format(result.maxStationLoad)}',
        ),
      ],
    );
  }

  ResultGroup _buildWorkstationsGroup(RpwResult result) {
    return ResultGroup(
      title: 'Workstation Assignments',
      children: result.workstations
          .map((Workstation station) {
            final String nodesLabel = station.nodeIds.map((int id) => 'N$id').join(', ');
            final String idleLabel = station.exceedsCycleTime
                ? 'Exceeds cycle time'
                : 'Idle: ${NumberFormatter.format(station.idleTime)}';
            return ResultItem(
              title: 'Station ${station.stationNumber}',
              value: nodesLabel,
              subtitle: 'Load: ${NumberFormatter.format(station.totalTime)} | $idleLabel',
              isHighlighted: station.exceedsCycleTime,
            );
          })
          .toList(growable: false),
    );
  }

  ResultGroup _buildRankedTableGroup(RpwResult result) {
    return ResultGroup(
      title: 'RPW Priority Table',
      children: result.rankedEntries
          .map((NodeRpwEntry entry) {
            final String preds = entry.predecessors.isEmpty
                ? 'Predecessors: None'
                : 'Predecessors: ${entry.predecessors.join(', ')}';
            return ResultItem(
              title: 'Node ${entry.nodeId}',
              value: 'RPW ${NumberFormatter.format(entry.rpw)}',
              subtitle: 'Tek: ${NumberFormatter.format(entry.tek)} | $preds',
            );
          })
          .toList(growable: false),
    );
  }

  ResultGroup _buildArrowChainsGroup(RpwResult result) {
    final List<int> keys = result.arrowChains.keys.toList()..sort();
    return ResultGroup(
      title: 'Arrow Chains',
      children: keys
          .map((int nodeId) {
            final List<int> chain = result.arrowChains[nodeId]!;
            return ResultItem(
              title: 'Chain from N$nodeId',
              value: chain.join(' -> '),
            );
          })
          .toList(growable: false),
    );
  }

  ResultGroup _buildNodesWithTekGroup(RpwResult result) {
    final String summary = result.tekByNode.entries
        .map((MapEntry<int, double> e) => 'N${e.key} = ${NumberFormatter.format(e.value)}')
        .join(', ');
    return ResultGroup(
      title: 'Nodes and Task Times (Tek)',
      children: <ResultNode>[
        ResultItem(
          title: 'All Work Elements',
          value: summary,
        ),
      ],
    );
  }

  ResultGroup _buildBlockedNodesGroup(RpwResult result) {
    return ResultGroup(
      title: 'Deferred Nodes (Blocked by Oversized Predecessor)',
      children: result.unassignableEntries
          .map((NodeRpwEntry entry) {
            return ResultItem(
              title: 'Node ${entry.nodeId}',
              value: 'Tek: ${NumberFormatter.format(entry.tek)}',
              subtitle: 'Depends on a node exceeding cycle time',
              isHighlighted: true,
            );
          })
          .toList(growable: false),
    );
  }

  void _writeNode(StringBuffer buffer, ResultNode node, int depth) {
    final String indent = '  ' * depth;
    switch (node) {
      case ResultGroup(:final title, :final children):
        buffer.writeln('$indent$title');
        for (final ResultNode child in children) {
          _writeNode(buffer, child, depth + 1);
        }
      case ResultItem(:final title, :final value, :final subtitle):
        final String suffix = subtitle != null ? ' ($subtitle)' : '';
        buffer.writeln('$indent$title: $value$suffix');
    }
  }
}
