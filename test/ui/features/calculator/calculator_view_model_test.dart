import 'package:flutter_test/flutter_test.dart';
import 'package:ranked_positional_method/data/services/clipboard_service.dart';
import 'package:ranked_positional_method/domain/models/rpw_result.dart';
import 'package:ranked_positional_method/domain/services/rpw_input_validator.dart';
import 'package:ranked_positional_method/domain/services/rpw_output_composer.dart';
import 'package:ranked_positional_method/domain/services/rpw_solver.dart';
import 'package:ranked_positional_method/domain/services/sample_problem_factory.dart';
import 'package:ranked_positional_method/ui/features/calculator/view_models/calculator_view_model.dart';

class _FakeClipboard implements ClipboardAdapter {
  String? lastCopied;

  @override
  Future<void> copyText(String text) async {
    lastCopied = text;
  }
}

void main() {
  group('CalculatorViewModel', () {
    late _FakeClipboard clipboard;
    late CalculatorViewModel viewModel;

    setUp(() {
      clipboard = _FakeClipboard();
      viewModel = CalculatorViewModel(
        validator: const RpwInputValidator(),
        solver: const HelgesonBirnieRpwSolver(),
        composer: const RpwOutputComposer(),
        clipboard: clipboard,
      );
    });

    test('supports Guided mode calculation and full Clear reset', () {
      expect(viewModel.addEdgeFromText(fromText: '1', toText: '2', tekText: '0.4'), isTrue);
      expect(viewModel.addEdgeFromText(fromText: '2', toText: '3', tekText: '0.6'), isTrue);
      expect(viewModel.edges.length, equals(2));

      viewModel.calculateGuided(finalNodeText: '3', finalTekText: '0.5', cycleTimeText: '1.0');
      expect(viewModel.errorMessage, isNull);
      expect(viewModel.result, isNotNull);
      expect(viewModel.result!.workstations.length, equals(2));
      expect(viewModel.calculationRevision, equals(1));

      viewModel.clearAll();
      expect(viewModel.edges, isEmpty);
      expect(viewModel.result, isNull);
      expect(viewModel.resultSections, isEmpty);
      expect(viewModel.errorMessage, isNull);
      expect(viewModel.finalNodeText, isEmpty);
      expect(viewModel.cycleTimeText, isEmpty);
    });

    test('supports Quick Text step-by-step flow and copies full report', () async {
      viewModel.setInputMode(InputMode.quickText);
      viewModel.submitQuickLine('2');
      expect(viewModel.quickStep, equals(QuickStep.connectionEntry));

      viewModel.submitQuickLine('1 2 0.4');
      viewModel.submitQuickLine('2 3 0.5');
      expect(viewModel.quickStep, equals(QuickStep.finalNode));

      viewModel.submitQuickLine('3 0.3');
      expect(viewModel.quickStep, equals(QuickStep.cycleTime));

      viewModel.submitQuickLine('1.0');
      expect(viewModel.quickStep, equals(QuickStep.complete));
      expect(viewModel.errorMessage, isNull);
      expect(viewModel.result, isNotNull);
      expect(viewModel.calculationRevision, equals(1));

      await viewModel.copyFullReport();
      expect(clipboard.lastCopied, contains('Workstations: 2'));
    });

    test('produces identical 6-node results across Guided and Quick Text modes', () {
      viewModel.loadSample(SamplePreset.classicSixNode);
      final RpwResult guidedResult = viewModel.result!;
      expect(viewModel.calculationRevision, equals(1));

      viewModel.clearAll();
      viewModel.setInputMode(InputMode.quickText);
      viewModel.submitQuickLine('6');
      viewModel.submitQuickLine('1 2 0.4');
      viewModel.submitQuickLine('1 3 0.4');
      viewModel.submitQuickLine('2 4 0.6');
      viewModel.submitQuickLine('3 4 0.3');
      viewModel.submitQuickLine('4 5 0.5');
      viewModel.submitQuickLine('5 6 0.2');
      viewModel.submitQuickLine('6 0.4');
      viewModel.submitQuickLine('1.0');

      final RpwResult quickResult = viewModel.result!;
      expect(viewModel.calculationRevision, equals(2));
      expect(
        quickResult.workstations.map((Workstation s) => s.nodeIds).toList(),
        equals(guidedResult.workstations.map((Workstation s) => s.nodeIds).toList()),
      );
      expect(
        quickResult.rankedEntries.map((NodeRpwEntry e) => (e.nodeId, e.rpw)).toList(),
        equals(guidedResult.rankedEntries.map((NodeRpwEntry e) => (e.nodeId, e.rpw)).toList()),
      );
      expect(quickResult.balanceDelay, closeTo(guidedResult.balanceDelay, 1e-6));
      expect(quickResult.productionRate, closeTo(guidedResult.productionRate, 1e-6));
    });

    test('loads sample presets and resets Quick Text state cleanly on Clear', () {
      viewModel.loadSample(SamplePreset.classicSixNode);
      expect(viewModel.edges.length, equals(6));
      expect(viewModel.result?.workstations.length, equals(3));

      viewModel.clearAll();
      expect(viewModel.quickStep, equals(QuickStep.connectionCount));
      expect(viewModel.quickLog, isEmpty);
      expect(viewModel.result, isNull);
    });
  });
}
