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

    test('solves parallel 8-node network with RPW tie-breaking and exact station balance', () {
      final RpwInput input = SampleProblemFactory.create(SamplePreset.parallelEightNode);
      final SolveOutcome<RpwResult> outcome = solver.solve(input);

      expect(outcome, isA<SolveSuccess<RpwResult>>());
      final RpwResult result = (outcome as SolveSuccess<RpwResult>).value;

      expect(result.arrowChains[1], equals(<int>[1, 2, 3, 4, 5, 6, 7, 8]));
      expect(result.arrowChains[2], equals(<int>[2, 4, 6, 7, 8]));
      expect(result.arrowChains[3], equals(<int>[3, 5, 6, 7, 8]));
      expect(result.arrowChains[4], equals(<int>[4, 6, 7, 8]));
      expect(result.arrowChains[5], equals(<int>[5, 6, 7, 8]));
      expect(result.arrowChains[6], equals(<int>[6, 7, 8]));
      expect(result.arrowChains[7], equals(<int>[7, 8]));

      expect(
        result.rankedEntries.map((NodeRpwEntry e) => e.nodeId),
        equals(<int>[1, 2, 3, 4, 5, 6, 7, 8]),
      );
      expect(
        result.rankedEntries.map((NodeRpwEntry e) => e.rpw),
        equals(<double>[24, 17, 13, 13, 10, 8, 5, 1]),
      );

      expect(result.workstations.length, equals(4));
      expect(result.workstations[0].nodeIds, equals(<int>[1, 2]));
      expect(result.workstations[0].totalTime, closeTo(6.0, 1e-6));
      expect(result.workstations[0].idleTime, closeTo(2.0, 1e-6));

      expect(result.workstations[1].nodeIds, equals(<int>[3, 4]));
      expect(result.workstations[1].totalTime, closeTo(8.0, 1e-6));
      expect(result.workstations[1].idleTime, closeTo(0.0, 1e-6));

      expect(result.workstations[2].nodeIds, equals(<int>[5, 6]));
      expect(result.workstations[2].totalTime, closeTo(5.0, 1e-6));
      expect(result.workstations[2].idleTime, closeTo(3.0, 1e-6));

      expect(result.workstations[3].nodeIds, equals(<int>[7, 8]));
      expect(result.workstations[3].totalTime, closeTo(5.0, 1e-6));
      expect(result.workstations[3].idleTime, closeTo(3.0, 1e-6));

      expect(result.totalTek, closeTo(24.0, 1e-6));
      expect(result.maxStationLoad, closeTo(8.0, 1e-6));
      expect(result.balanceDelay, closeTo(0.25, 1e-6));
      expect(result.lineEfficiency, closeTo(0.75, 1e-6));
      expect(result.productionRate, closeTo(0.125, 1e-6));
    });

    test(
      'solves 12-element multi-start converging network without double-counting shared nodes',
      () {
        const List<NodeEdge> edges = <NodeEdge>[
          NodeEdge(fromNode: 1, toNode: 3, sourceTek: 0.2),
          NodeEdge(fromNode: 2, toNode: 4, sourceTek: 0.4),
          NodeEdge(fromNode: 2, toNode: 5, sourceTek: 0.4),
          NodeEdge(fromNode: 3, toNode: 6, sourceTek: 0.7),
          NodeEdge(fromNode: 3, toNode: 7, sourceTek: 0.7),
          NodeEdge(fromNode: 4, toNode: 6, sourceTek: 0.1),
          NodeEdge(fromNode: 5, toNode: 7, sourceTek: 0.3),
          NodeEdge(fromNode: 6, toNode: 8, sourceTek: 0.11),
          NodeEdge(fromNode: 7, toNode: 8, sourceTek: 0.32),
          NodeEdge(fromNode: 7, toNode: 9, sourceTek: 0.32),
          NodeEdge(fromNode: 8, toNode: 11, sourceTek: 0.6),
          NodeEdge(fromNode: 9, toNode: 11, sourceTek: 0.27),
          NodeEdge(fromNode: 10, toNode: 11, sourceTek: 0.38),
          NodeEdge(fromNode: 11, toNode: 12, sourceTek: 0.5),
        ];
        const RpwInput input = RpwInput(
          edges: edges,
          finalNodeId: 12,
          finalNodeTek: 0.12,
          cycleTime: 1.0,
        );

        final SolveOutcome<RpwResult> outcome = solver.solve(input);
        expect(outcome, isA<SolveSuccess<RpwResult>>());
        final RpwResult result = (outcome as SolveSuccess<RpwResult>).value;

        final Map<int, double> rpwById = <int, double>{
          for (final NodeRpwEntry entry in result.rankedEntries) entry.nodeId: entry.rpw,
        };
        expect(rpwById[1], closeTo(2.82, 1e-6));
        expect(rpwById[2], closeTo(2.72, 1e-6));
        expect(rpwById[3], closeTo(2.62, 1e-6));
        expect(rpwById[5], closeTo(2.11, 1e-6));
        expect(rpwById[7], closeTo(1.81, 1e-6));
        expect(rpwById[4], closeTo(1.43, 1e-6));
        expect(rpwById[6], closeTo(1.33, 1e-6));
        expect(rpwById[8], closeTo(1.22, 1e-6));
        expect(rpwById[10], closeTo(1.00, 1e-6));
        expect(rpwById[9], closeTo(0.89, 1e-6));
        expect(rpwById[11], closeTo(0.62, 1e-6));
        expect(rpwById[12], closeTo(0.12, 1e-6));

        expect(result.workstations.length, equals(5));
        expect(result.workstations[0].nodeIds, equals(<int>[1, 2, 5, 4]));
        expect(result.workstations[0].totalTime, closeTo(1.00, 1e-6));
        expect(result.workstations[1].nodeIds, equals(<int>[3, 6]));
        expect(result.workstations[1].totalTime, closeTo(0.81, 1e-6));
        expect(result.workstations[2].nodeIds, equals(<int>[7, 8]));
        expect(result.workstations[2].totalTime, closeTo(0.92, 1e-6));
        expect(result.workstations[3].nodeIds, equals(<int>[10, 9]));
        expect(result.workstations[3].totalTime, closeTo(0.65, 1e-6));
        expect(result.workstations[4].nodeIds, equals(<int>[11, 12]));
        expect(result.workstations[4].totalTime, closeTo(0.62, 1e-6));

        expect(result.totalTek, closeTo(4.00, 1e-6));
        expect(result.maxStationLoad, closeTo(1.00, 1e-6));
        expect(result.balanceDelay, closeTo(0.20, 1e-6));
        expect(result.lineEfficiency, closeTo(0.80, 1e-6));
        expect(result.productionRate, closeTo(1.0, 1e-6));

        final SolveOutcome<RpwResult> reversedOutcome = solver.solve(
          RpwInput(
            edges: edges.reversed.toList(growable: false),
            finalNodeId: 12,
            finalNodeTek: 0.12,
            cycleTime: 1.0,
          ),
        );
        final RpwResult reversed = (reversedOutcome as SolveSuccess<RpwResult>).value;
        expect(
          reversed.workstations.map((Workstation s) => s.nodeIds).toList(),
          equals(result.workstations.map((Workstation s) => s.nodeIds).toList()),
        );
        expect(reversed.balanceDelay, closeTo(result.balanceDelay, 1e-6));
      },
    );

    test('handles IEEE-754 boundary 0.1 + 0.2 <= 0.3 without spilling to an extra station', () {
      const RpwInput input = RpwInput(
        edges: <NodeEdge>[
          NodeEdge(fromNode: 1, toNode: 2, sourceTek: 0.1),
          NodeEdge(fromNode: 2, toNode: 3, sourceTek: 0.2),
        ],
        finalNodeId: 3,
        finalNodeTek: 0.3,
        cycleTime: 0.3,
      );

      final SolveOutcome<RpwResult> outcome = solver.solve(input);
      expect(outcome, isA<SolveSuccess<RpwResult>>());
      final RpwResult result = (outcome as SolveSuccess<RpwResult>).value;

      expect(result.workstations.length, equals(2));
      expect(result.workstations[0].nodeIds, equals(<int>[1, 2]));
      expect(result.workstations[0].totalTime, closeTo(0.3, 1e-6));
      expect(result.workstations[0].idleTime, closeTo(0.0, 1e-6));
      expect(result.workstations[1].nodeIds, equals(<int>[3]));
    });

    test('packs zero-Tek milestone tasks into a single zero-delay workstation', () {
      const RpwInput input = RpwInput(
        edges: <NodeEdge>[
          NodeEdge(fromNode: 1, toNode: 2, sourceTek: 0.0),
          NodeEdge(fromNode: 2, toNode: 3, sourceTek: 2.0),
        ],
        finalNodeId: 3,
        finalNodeTek: 0.0,
        cycleTime: 2.0,
      );

      final SolveOutcome<RpwResult> outcome = solver.solve(input);
      expect(outcome, isA<SolveSuccess<RpwResult>>());
      final RpwResult result = (outcome as SolveSuccess<RpwResult>).value;

      expect(result.workstations.length, equals(1));
      expect(result.workstations[0].nodeIds, equals(<int>[1, 2, 3]));
      expect(result.balanceDelay, closeTo(0.0, 1e-6));
      expect(result.lineEfficiency, closeTo(1.0, 1e-6));
      expect(result.productionRate, closeTo(0.5, 1e-6));
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
