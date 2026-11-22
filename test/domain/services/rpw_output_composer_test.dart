import 'package:flutter_test/flutter_test.dart';
import 'package:ranked_positional_method/domain/models/result_node.dart';
import 'package:ranked_positional_method/domain/models/rpw_error.dart';
import 'package:ranked_positional_method/domain/models/rpw_result.dart';
import 'package:ranked_positional_method/domain/services/rpw_output_composer.dart';
import 'package:ranked_positional_method/domain/services/rpw_solver.dart';
import 'package:ranked_positional_method/domain/services/sample_problem_factory.dart';

void main() {
  group('RpwOutputComposer', () {
    const HelgesonBirnieRpwSolver solver = HelgesonBirnieRpwSolver();
    const RpwOutputComposer composer = RpwOutputComposer();

    test('composes composite groups and exports plain text for classic sample', () {
      final SolveOutcome<RpwResult> outcome = solver.solve(
        SampleProblemFactory.create(SamplePreset.classicSixNode),
      );
      final RpwResult result = (outcome as SolveSuccess<RpwResult>).value;

      final List<ResultGroup> groups = composer.buildSections(result);
      expect(groups.map((ResultGroup g) => g.title), contains('Line Summary'));
      expect(groups.map((ResultGroup g) => g.title), contains('Workstation Assignments'));
      expect(groups.map((ResultGroup g) => g.title), contains('RPW Priority Table'));

      final String text = composer.toPlainText(result);
      expect(text, contains('Production Rate:'));
      expect(text, contains('Balance Delay:'));
      expect(text, contains('Station 1: N1, N2'));
    });

    test('includes deferred nodes group when oversized task blocks dependents', () {
      final SolveOutcome<RpwResult> outcome = solver.solve(
        SampleProblemFactory.create(SamplePreset.oversizedTaskCase),
      );
      final RpwResult result = (outcome as SolveSuccess<RpwResult>).value;

      final List<ResultGroup> groups = composer.buildSections(result);
      expect(
        groups.map((ResultGroup g) => g.title),
        contains('Deferred Nodes (Blocked by Oversized Predecessor)'),
      );
    });
  });
}
