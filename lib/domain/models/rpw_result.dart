/// Ranked Positional Weight summary row for a single work element [nodeId].
class const NodeRpwEntry({
  required final int nodeId,
  required final double tek,
  required final double rpw,
  required final List<int> predecessors,
});

/// Single balanced workstation containing assigned [nodeIds] and time metrics.
class const Workstation({
  required final int stationNumber,
  required final List<int> nodeIds,
  required final double totalTime,
  required final double idleTime,
  required final bool exceedsCycleTime,
});

/// Complete calculation output produced by an RPW solver.
class const RpwResult({
  required final Map<int, double> tekByNode,
  required final Map<int, List<int>> arrowChains,
  required final List<NodeRpwEntry> rankedEntries,
  required final List<Workstation> workstations,
  required final List<NodeRpwEntry> unassignableEntries,
  required final double cycleTime,
  required final double maxStationLoad,
  required final double totalTek,
  required final double balanceDelay,
  required final double productionRate,
}) {
  /// Assembly line efficiency ratio in `[0, 1]`.
  double get lineEfficiency => (1.0 - balanceDelay).clamp(0.0, 1.0);
}
