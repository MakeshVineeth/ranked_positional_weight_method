/// Directed precedence edge connecting [fromNode] to [toNode] with task time [sourceTek].
class const NodeEdge({
  required final int fromNode,
  required final int toNode,
  required final double sourceTek,
});

/// Validated input dataset passed to an RPW solver.
class const RpwInput({
  required final List<NodeEdge> edges,
  required final int finalNodeId,
  required final double finalNodeTek,
  required final double cycleTime,
});
