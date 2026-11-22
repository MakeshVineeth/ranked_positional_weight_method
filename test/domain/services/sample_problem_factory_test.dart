import 'package:flutter_test/flutter_test.dart';
import 'package:ranked_positional_method/domain/models/rpw_error.dart';
import 'package:ranked_positional_method/domain/models/rpw_input.dart';
import 'package:ranked_positional_method/domain/models/rpw_result.dart';
import 'package:ranked_positional_method/domain/services/rpw_solver.dart';
import 'package:ranked_positional_method/domain/services/sample_problem_factory.dart';

void main() {
  group('SampleProblemFactory', () {
    const HelgesonBirnieRpwSolver solver = HelgesonBirnieRpwSolver();

    test('produces valid solvable inputs for all presets', () {
      for (final SamplePreset preset in SamplePreset.values) {
        final RpwInput input = SampleProblemFactory.create(preset);
        final SolveOutcome<RpwResult> outcome = solver.solve(input);
        expect(outcome, isA<SolveSuccess<RpwResult>>(), reason: 'Failed preset: ${preset.label}');
      }
    });
  });
}
