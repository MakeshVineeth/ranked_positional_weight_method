import 'package:flutter_test/flutter_test.dart';
import 'package:ranked_positional_method/core/constants/app_constants.dart';
import 'package:ranked_positional_method/domain/models/rpw_error.dart';
import 'package:ranked_positional_method/domain/models/rpw_input.dart';
import 'package:ranked_positional_method/domain/models/rpw_result.dart';
import 'package:ranked_positional_method/domain/services/rpw_solver.dart';
import 'package:ranked_positional_method/domain/services/sample_problem_factory.dart';

void main() {
  group('HelgesonBirnieRpwSolver', () {
    const HelgesonBirnieRpwSolver solver = HelgesonBirnieRpwSolver();

    test('solves classic 6-node textbook network accurately', () {
      final RpwInput input = SampleProblemFactory.create(SamplePreset.classicSixNode);
      final SolveOutcome<RpwResult> outcome = solver.solve(input);

      expect(outcome, isA<SolveSuccess<RpwResult>>());
      final RpwResult result = (outcome as SolveSuccess<RpwResult>).value;

      expect(result.arrowChains[1], equals(<int>[1, 2, 3, 4, 5, 6]));
      expect(result.arrowChains[2], equals(<int>[2, 4, 5, 6]));
      expect(result.arrowChains[3], equals(<int>[3, 4, 5, 6]));

      expect(
        result.rankedEntries.map((NodeRpwEntry e) => e.nodeId),
        equals(<int>[1, 2, 3, 4, 5, 6]),
      );
      expect(result.rankedEntries.first.rpw, closeTo(2.4, 1e-6));
      expect(result.rankedEntries.last.rpw, closeTo(0.4, 1e-6));

      expect(result.workstations.length, equals(3));
      expect(result.workstations[0].nodeIds, equals(<int>[1, 2]));
      expect(result.workstations[0].idleTime, closeTo(0.0, 1e-6));
      expect(result.workstations[1].nodeIds, equals(<int>[3, 4, 5]));
      expect(result.workstations[1].idleTime, closeTo(0.0, 1e-6));
      expect(result.workstations[2].nodeIds, equals(<int>[6]));
      expect(result.workstations[2].idleTime, closeTo(0.6, 1e-6));

      expect(result.maxStationLoad, closeTo(1.0, 1e-6));
      expect(result.totalTek, closeTo(2.4, 1e-6));
      expect(result.balanceDelay, closeTo(0.2, 1e-6));
      expect(result.lineEfficiency, closeTo(0.8, 1e-6));
      expect(result.productionRate, closeTo(1.0, 1e-6));
      expect(result.unassignableEntries, isEmpty);
    });

    test('terminates cleanly when a downstream node depends on an oversized node', () {
      final RpwInput input = SampleProblemFactory.create(SamplePreset.oversizedTaskCase);
      final SolveOutcome<RpwResult> outcome = solver.solve(input);

      expect(outcome, isA<SolveSuccess<RpwResult>>());
      final RpwResult result = (outcome as SolveSuccess<RpwResult>).value;

      expect(result.workstations.length, equals(2));
      expect(result.workstations[0].nodeIds, equals(<int>[1]));
      expect(result.workstations[0].exceedsCycleTime, isFalse);
      expect(result.workstations[1].nodeIds, equals(<int>[2]));
      expect(result.workstations[1].exceedsCycleTime, isTrue);

      expect(result.unassignableEntries.map((NodeRpwEntry e) => e.nodeId), equals(<int>[3, 4]));
      expect(result.maxStationLoad, closeTo(6.0, 1e-6));
      expect(result.balanceDelay, greaterThanOrEqualTo(0.0));
      expect(result.balanceDelay, lessThanOrEqualTo(1.0));
    });

    test('does not skip indirect branches when direct edge to final node comes first', () {
      const RpwInput input = RpwInput(
        edges: <NodeEdge>[
          NodeEdge(fromNode: 1, toNode: 4, sourceTek: 1.0),
          NodeEdge(fromNode: 1, toNode: 2, sourceTek: 1.0),
          NodeEdge(fromNode: 2, toNode: 3, sourceTek: 2.0),
          NodeEdge(fromNode: 3, toNode: 4, sourceTek: 3.0),
        ],
        finalNodeId: 4,
        finalNodeTek: 4.0,
        cycleTime: 10.0,
      );

      final SolveOutcome<RpwResult> outcome = solver.solve(input);
      expect(outcome, isA<SolveSuccess<RpwResult>>());
      final RpwResult result = (outcome as SolveSuccess<RpwResult>).value;

      expect(result.arrowChains[1], equals(<int>[1, 2, 3, 4]));
      expect(result.rankedEntries.first.nodeId, equals(1));
      expect(result.rankedEntries.first.rpw, closeTo(10.0, 1e-6));
    });

    test('maps RPW accurately by node ID even when finalNodeId is not the largest ID', () {
      const RpwInput input = RpwInput(
        edges: <NodeEdge>[
          NodeEdge(fromNode: 1, toNode: 3, sourceTek: 2.0),
          NodeEdge(fromNode: 3, toNode: 4, sourceTek: 3.0),
          NodeEdge(fromNode: 4, toNode: 2, sourceTek: 4.0),
        ],
        finalNodeId: 2,
        finalNodeTek: 1.0,
        cycleTime: 10.0,
      );

      final SolveOutcome<RpwResult> outcome = solver.solve(input);
      expect(outcome, isA<SolveSuccess<RpwResult>>());
      final RpwResult result = (outcome as SolveSuccess<RpwResult>).value;

      final Map<int, double> rpwById = <int, double>{
        for (final NodeRpwEntry entry in result.rankedEntries) entry.nodeId: entry.rpw,
      };
      expect(rpwById[1], closeTo(10.0, 1e-6));
      expect(rpwById[3], closeTo(8.0, 1e-6));
      expect(rpwById[4], closeTo(5.0, 1e-6));
      expect(rpwById[2], closeTo(1.0, 1e-6));
    });

    test('handles all nodes exceeding cycle time without division by zero or negative delay', () {
      const RpwInput input = RpwInput(
        edges: <NodeEdge>[
          NodeEdge(fromNode: 1, toNode: 2, sourceTek: 7.0),
        ],
        finalNodeId: 2,
        finalNodeTek: 6.0,
        cycleTime: 5.0,
      );

      final SolveOutcome<RpwResult> outcome = solver.solve(input);
      expect(outcome, isA<SolveSuccess<RpwResult>>());
      final RpwResult result = (outcome as SolveSuccess<RpwResult>).value;

      expect(result.workstations.length, equals(2));
      expect(result.maxStationLoad, closeTo(7.0, 1e-6));
      expect(result.productionRate, closeTo(1.0 / 7.0, 1e-6));
      expect(result.balanceDelay, closeTo((14.0 - 13.0) / 14.0, 1e-6));
      expect(result.balanceDelay.isFinite, isTrue);
    });

    test('rejects cyclic precedence graphs cleanly', () {
      const RpwInput input = RpwInput(
        edges: <NodeEdge>[
          NodeEdge(fromNode: 1, toNode: 2, sourceTek: 1.0),
          NodeEdge(fromNode: 2, toNode: 3, sourceTek: 1.0),
          NodeEdge(fromNode: 3, toNode: 1, sourceTek: 1.0),
          NodeEdge(fromNode: 3, toNode: 4, sourceTek: 1.0),
        ],
        finalNodeId: 4,
        finalNodeTek: 1.0,
        cycleTime: 5.0,
      );

      final SolveOutcome<RpwResult> outcome = solver.solve(input);
      expect(outcome, isA<SolveError<RpwResult>>());
      expect((outcome as SolveError<RpwResult>).failure, isA<CyclicGraphFailure>());
    });

    test('rejects disconnected precedence graphs cleanly', () {
      const RpwInput input = RpwInput(
        edges: <NodeEdge>[
          NodeEdge(fromNode: 1, toNode: 2, sourceTek: 1.0),
          NodeEdge(fromNode: 3, toNode: 4, sourceTek: 1.0),
        ],
        finalNodeId: 4,
        finalNodeTek: 1.0,
        cycleTime: 5.0,
      );

      final SolveOutcome<RpwResult> outcome = solver.solve(input);
      expect(outcome, isA<SolveError<RpwResult>>());
      expect((outcome as SolveError<RpwResult>).failure, isA<DisconnectedGraphFailure>());
    });

    test('rejects graphs exceeding max edge limit', () {
      final List<NodeEdge> edges = List<NodeEdge>.generate(
        AppConstants.maxEdges + 1,
        (int i) => NodeEdge(fromNode: i + 1, toNode: i + 2, sourceTek: 1.0),
      );
      final RpwInput input = RpwInput(
        edges: edges,
        finalNodeId: AppConstants.maxEdges + 2,
        finalNodeTek: 1.0,
        cycleTime: 5.0,
      );

      final SolveOutcome<RpwResult> outcome = solver.solve(input);
      expect(outcome, isA<SolveError<RpwResult>>());
      expect((outcome as SolveError<RpwResult>).failure, isA<InputLimitExceededFailure>());
    });
  });
}
