import 'package:flutter_test/flutter_test.dart';
import 'package:ranked_positional_method/domain/models/rpw_error.dart';
import 'package:ranked_positional_method/domain/models/rpw_input.dart';
import 'package:ranked_positional_method/domain/services/rpw_input_validator.dart';

void main() {
  group('RpwInputValidator', () {
    const RpwInputValidator validator = RpwInputValidator();

    test('accepts valid raw numeric input and rejects disallowed characters', () {
      expect(validator.isAllowedRawText('1 2 0.4'), isTrue);
      expect(validator.isAllowedRawText('1; DROP TABLE'), isFalse);
      expect(validator.isAllowedRawText('   '), isFalse);
    });

    test('parses valid Quick Text edge line and rejects malformed lines', () {
      final SolveOutcome<NodeEdge> ok = validator.parseQuickEdgeLine('1 2 0.75');
      expect(ok, isA<SolveSuccess<NodeEdge>>());
      final NodeEdge edge = (ok as SolveSuccess<NodeEdge>).value;
      expect(edge.fromNode, equals(1));
      expect(edge.toNode, equals(2));
      expect(edge.sourceTek, closeTo(0.75, 1e-6));

      expect(validator.parseQuickEdgeLine('1 2'), isA<SolveError<NodeEdge>>());
      expect(validator.parseQuickEdgeLine('2 2 1.0'), isA<SolveError<NodeEdge>>());
    });

    test('parses Quick Text final node line', () {
      final SolveOutcome<({int finalNodeId, double finalNodeTek})> ok = validator
          .parseQuickFinalNodeLine('6 0.4');
      expect(ok, isA<SolveSuccess<({int finalNodeId, double finalNodeTek})>>());
      final parsed = (ok as SolveSuccess<({int finalNodeId, double finalNodeTek})>).value;
      expect(parsed.finalNodeId, equals(6));
      expect(parsed.finalNodeTek, closeTo(0.4, 1e-6));

      expect(
        validator.parseQuickFinalNodeLine('6'),
        isA<SolveError<({int finalNodeId, double finalNodeTek})>>(),
      );
    });

    test('rejects conflicting Tek values and outgoing edges from final node', () {
      const RpwInput conflictingTek = RpwInput(
        edges: <NodeEdge>[
          NodeEdge(fromNode: 1, toNode: 2, sourceTek: 0.4),
          NodeEdge(fromNode: 1, toNode: 3, sourceTek: 0.9),
        ],
        finalNodeId: 3,
        finalNodeTek: 0.2,
        cycleTime: 1.0,
      );
      expect(validator.validateInput(conflictingTek), isA<InvalidInputFailure>());

      const RpwInput finalHasOutgoing = RpwInput(
        edges: <NodeEdge>[
          NodeEdge(fromNode: 1, toNode: 2, sourceTek: 0.4),
          NodeEdge(fromNode: 2, toNode: 3, sourceTek: 0.5),
        ],
        finalNodeId: 2,
        finalNodeTek: 0.5,
        cycleTime: 1.0,
      );
      expect(validator.validateInput(finalHasOutgoing), isA<InvalidInputFailure>());
    });
  });
}
