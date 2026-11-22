import 'dart:collection';
import 'dart:math' as math;

import 'package:ranked_positional_method/core/constants/app_constants.dart';
import 'package:ranked_positional_method/domain/models/rpw_error.dart';
import 'package:ranked_positional_method/domain/models/rpw_input.dart';
import 'package:ranked_positional_method/domain/models/rpw_result.dart';
import 'package:ranked_positional_method/domain/services/rpw_input_validator.dart';

/// Strategy interface for assembly line balancing solvers.
abstract interface class RpwSolver {
  /// Solves the line balancing problem described by [input].
  SolveOutcome<RpwResult> solve(RpwInput input);
}

/// Solves line balancing using the Helgeson and Birnie Ranked Positional Weight method.
class HelgesonBirnieRpwSolver implements RpwSolver {
  /// Creates a solver using an optional validator.
  const HelgesonBirnieRpwSolver({
    this._validator = const RpwInputValidator(),
  });

  final RpwInputValidator _validator;

  @override
  SolveOutcome<RpwResult> solve(RpwInput input) {
    final RpwFailure? validationError = _validator.validateInput(input);
    if (validationError != null) {
      return SolveError<RpwResult>(validationError);
    }

    final Set<int> nodeSet = <int>{};
    final Map<int, List<int>> outgoing = <int, List<int>>{};
    final Map<int, Set<int>> incoming = <int, Set<int>>{};
    final Map<int, double> tekByNode = <int, double>{};

    for (final NodeEdge edge in input.edges) {
      nodeSet.add(edge.fromNode);
      nodeSet.add(edge.toNode);
      outgoing.putIfAbsent(edge.fromNode, () => <int>[]).add(edge.toNode);
      incoming.putIfAbsent(edge.toNode, () => <int>{}).add(edge.fromNode);
      tekByNode[edge.fromNode] = edge.sourceTek;
    }

    if (!nodeSet.contains(input.finalNodeId)) {
      return SolveError<RpwResult>(
        DisconnectedGraphFailure(
          'Final node ${input.finalNodeId} does not appear in the provided connections.',
        ),
      );
    }
    tekByNode[input.finalNodeId] = input.finalNodeTek;

    final List<int> uniqueNodes = nodeSet.toList()..sort();
    for (final int nodeId in uniqueNodes) {
      if (!tekByNode.containsKey(nodeId)) {
        return SolveError<RpwResult>(
          DisconnectedGraphFailure(
            'Node $nodeId has no outgoing connection and is not marked as the final node.',
          ),
        );
      }
    }

    if (_hasCycle(uniqueNodes, outgoing)) {
      return const SolveError<RpwResult>(
        CyclicGraphFailure(
          'Precedence connections contain a cycle. Remove circular links and try again.',
        ),
      );
    }

    final Set<int> reachableToFinal = _collectReverseReachable(input.finalNodeId, incoming);
    if (reachableToFinal.length != uniqueNodes.length) {
      final List<int> unreachable = uniqueNodes
          .where((int id) => !reachableToFinal.contains(id))
          .toList();
      return SolveError<RpwResult>(
        DisconnectedGraphFailure(
          'All nodes must connect to final node ${input.finalNodeId}. Unconnected: $unreachable.',
        ),
      );
    }

    final Map<int, List<int>> arrowChains = <int, List<int>>{};
    final Map<int, double> rpwByNode = <int, double>{};

    for (final int nodeId in uniqueNodes) {
      if (nodeId == input.finalNodeId) {
        rpwByNode[nodeId] = input.finalNodeTek;
        continue;
      }
      final List<int> chain = _collectForwardReachable(nodeId, outgoing)..sort();
      arrowChains[nodeId] = List<int>.unmodifiable(chain);
      double rpw = 0.0;
      for (final int member in chain) {
        rpw += tekByNode[member]!;
      }
      rpwByNode[nodeId] = rpw;
    }

    final List<NodeRpwEntry> rankedEntries = <NodeRpwEntry>[];
    for (final int nodeId in uniqueNodes) {
      final List<int> preds = (incoming[nodeId]?.toList() ?? <int>[])..sort();
      rankedEntries.add(
        NodeRpwEntry(
          nodeId: nodeId,
          tek: tekByNode[nodeId]!,
          rpw: rpwByNode[nodeId]!,
          predecessors: List<int>.unmodifiable(preds),
        ),
      );
    }

    rankedEntries.sort((NodeRpwEntry a, NodeRpwEntry b) {
      final int rpwCmp = b.rpw.compareTo(a.rpw);
      return rpwCmp != 0 ? rpwCmp : a.nodeId.compareTo(b.nodeId);
    });

    final (:workstations, :unassignableEntries) = _assignWorkstations(
      rankedEntries: rankedEntries,
      cycleTime: input.cycleTime,
    );

    double maxStationLoad = 0.0;
    for (final Workstation station in workstations) {
      maxStationLoad = math.max(maxStationLoad, station.totalTime);
    }

    double totalTek = 0.0;
    for (final int nodeId in uniqueNodes) {
      totalTek += tekByNode[nodeId]!;
    }

    final double productionRate = maxStationLoad > 0 ? 1.0 / maxStationLoad : 0.0;
    final double balanceDelay = (workstations.isNotEmpty && maxStationLoad > 0)
        ? ((workstations.length * maxStationLoad - totalTek) /
                  (workstations.length * maxStationLoad))
              .clamp(0.0, 1.0)
        : 0.0;

    return SolveSuccess<RpwResult>(
      RpwResult(
        tekByNode: Map<int, double>.unmodifiable(
          <int, double>{for (final int id in uniqueNodes) id: tekByNode[id]!},
        ),
        arrowChains: Map<int, List<int>>.unmodifiable(arrowChains),
        rankedEntries: List<NodeRpwEntry>.unmodifiable(rankedEntries),
        workstations: List<Workstation>.unmodifiable(workstations),
        unassignableEntries: List<NodeRpwEntry>.unmodifiable(unassignableEntries),
        cycleTime: input.cycleTime,
        maxStationLoad: maxStationLoad,
        totalTek: totalTek,
        balanceDelay: balanceDelay,
        productionRate: productionRate,
      ),
    );
  }

  bool _hasCycle(List<int> nodes, Map<int, List<int>> outgoing) {
    // 0 = unvisited, 1 = visiting, 2 = visited
    final Map<int, int> state = <int, int>{for (final int id in nodes) id: 0};

    for (final int start in nodes) {
      if (state[start] != 0) {
        continue;
      }
      final List<(int node, int childIndex)> stack = <(int, int)>[(start, 0)];
      state[start] = 1;

      while (stack.isNotEmpty) {
        final (int node, int childIndex) = stack.last;
        final List<int> neighbors = outgoing[node] ?? const <int>[];
        if (childIndex >= neighbors.length) {
          state[node] = 2;
          stack.removeLast();
          continue;
        }
        stack[stack.length - 1] = (node, childIndex + 1);
        final int next = neighbors[childIndex];
        final int nextState = state[next] ?? 0;
        if (nextState == 1) {
          return true;
        }
        if (nextState == 0) {
          state[next] = 1;
          stack.add((next, 0));
        }
      }
    }
    return false;
  }

  Set<int> _collectReverseReachable(int finalNodeId, Map<int, Set<int>> incoming) {
    final Set<int> visited = <int>{finalNodeId};
    final Queue<int> queue = Queue<int>()..add(finalNodeId);
    while (queue.isNotEmpty) {
      final int current = queue.removeFirst();
      for (final int prev in incoming[current] ?? const <int>{}) {
        if (visited.add(prev)) {
          queue.add(prev);
        }
      }
    }
    return visited;
  }

  List<int> _collectForwardReachable(int startNodeId, Map<int, List<int>> outgoing) {
    final Set<int> visited = <int>{startNodeId};
    final Queue<int> queue = Queue<int>()..add(startNodeId);
    while (queue.isNotEmpty) {
      final int current = queue.removeFirst();
      for (final int next in outgoing[current] ?? const <int>[]) {
        if (visited.add(next)) {
          queue.add(next);
        }
      }
    }
    return visited.toList();
  }

  ({List<Workstation> workstations, List<NodeRpwEntry> unassignableEntries}) _assignWorkstations({
    required List<NodeRpwEntry> rankedEntries,
    required double cycleTime,
  }) {
    final List<NodeRpwEntry> rangeIn = <NodeRpwEntry>[];
    final List<NodeRpwEntry> rangeOut = <NodeRpwEntry>[];

    for (final NodeRpwEntry entry in rankedEntries) {
      if (entry.tek <= cycleTime + AppConstants.epsilon) {
        rangeIn.add(entry);
      } else {
        rangeOut.add(entry);
      }
    }

    final Set<int> completed = <int>{};
    final Set<int> rangeOutIds = rangeOut.map((NodeRpwEntry e) => e.nodeId).toSet();
    final List<NodeRpwEntry> unassignableEntries = <NodeRpwEntry>[];
    final Set<int> unassignableIds = <int>{};
    final List<Workstation> workstations = <Workstation>[];
    int stationNumber = 1;

    while (rangeIn.isNotEmpty) {
      double stationLoad = 0.0;
      final List<int> assignedNodes = <int>[];
      bool madeProgress = false;

      for (int i = 0; i < rangeIn.length;) {
        final NodeRpwEntry entry = rangeIn[i];
        final double nextLoad = stationLoad + entry.tek;

        if (nextLoad <= cycleTime + AppConstants.epsilon) {
          final bool allPredecessorsCompleted = entry.predecessors.every(
            (int pred) => completed.contains(pred),
          );

          if (allPredecessorsCompleted) {
            stationLoad = nextLoad;
            assignedNodes.add(entry.nodeId);
            completed.add(entry.nodeId);
            rangeIn.removeAt(i);
            madeProgress = true;
            continue;
          }

          final bool dependsOnBlocked = entry.predecessors.any(
            (int pred) =>
                !completed.contains(pred) &&
                (rangeOutIds.contains(pred) || unassignableIds.contains(pred)),
          );
          if (dependsOnBlocked) {
            unassignableEntries.add(entry);
            unassignableIds.add(entry.nodeId);
            rangeIn.removeAt(i);
            madeProgress = true;
            continue;
          }
        }
        i++;
      }

      if (!madeProgress) {
        unassignableEntries.addAll(rangeIn);
        break;
      }

      if (assignedNodes.isNotEmpty) {
        workstations.add(
          Workstation(
            stationNumber: stationNumber,
            nodeIds: List<int>.unmodifiable(assignedNodes),
            totalTime: stationLoad,
            idleTime: math.max(0.0, cycleTime - stationLoad),
            exceedsCycleTime: false,
          ),
        );
        stationNumber++;
      }
    }

    if (rangeOut.isNotEmpty) {
      rangeOut.sort((NodeRpwEntry a, NodeRpwEntry b) {
        final int tekCmp = b.tek.compareTo(a.tek);
        return tekCmp != 0 ? tekCmp : a.nodeId.compareTo(b.nodeId);
      });
      for (final NodeRpwEntry entry in rangeOut) {
        workstations.add(
          Workstation(
            stationNumber: stationNumber,
            nodeIds: List<int>.unmodifiable(<int>[entry.nodeId]),
            totalTime: entry.tek,
            idleTime: 0.0,
            exceedsCycleTime: true,
          ),
        );
        stationNumber++;
      }
    }

    return (
      workstations: workstations,
      unassignableEntries: unassignableEntries,
    );
  }
}
