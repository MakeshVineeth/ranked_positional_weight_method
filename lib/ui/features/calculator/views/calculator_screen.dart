import 'dart:ui' show DisplayFeature, DisplayFeatureType;

import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:ranked_positional_method/core/layout/window_size_class.dart';
import 'package:ranked_positional_method/domain/models/result_node.dart';
import 'package:ranked_positional_method/domain/models/rpw_result.dart';
import 'package:ranked_positional_method/ui/features/calculator/view_models/calculator_view_model.dart';
import 'package:ranked_positional_method/ui/features/calculator/widgets/guided_input_panel.dart';
import 'package:ranked_positional_method/ui/features/calculator/widgets/quick_text_input_panel.dart';
import 'package:ranked_positional_method/ui/features/calculator/widgets/results_panel.dart';
import 'package:ranked_positional_method/ui/features/calculator/widgets/wear_calculator_view.dart';

typedef _ResultsSnapshot = ({
  String? errorMessage,
  RpwResult? result,
  List<ResultGroup> resultSections,
});

/// Main adaptive RPW calculator workspace supporting Wear, Phones, Foldables, Tablets, and Desktop.
class CalculatorScreen extends StatefulWidget {
  /// Creates a [CalculatorScreen].
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final ScrollController _inputScrollController = ScrollController();
  final ScrollController _resultsScrollController = ScrollController();

  @override
  void dispose() {
    _inputScrollController.dispose();
    _resultsScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<DisplayFeature> features = MediaQuery.displayFeaturesOf(context);
    final bool hasVerticalHinge = features.any(
      (DisplayFeature f) =>
          (f.type == DisplayFeatureType.hinge || f.type == DisplayFeatureType.fold) &&
          f.bounds.height > f.bounds.width,
    );

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final WindowSizeClass sizeClass = WindowSizeClass.fromWidth(constraints.maxWidth);

        if (sizeClass == WindowSizeClass.wear) {
          return Consumer<CalculatorViewModel>(
            builder: (_, CalculatorViewModel viewModel, _) =>
                WearCalculatorView(viewModel: viewModel),
          );
        }

        if (hasVerticalHinge && sizeClass.supportsSplitPane) {
          return Row(
            children: <Widget>[
              Expanded(
                child: FocusTraversalGroup(
                  child: DisplayFeatureSubScreen(
                    anchorPoint: Offset.zero,
                    child: _buildInputScrollPane(padding: 16),
                  ),
                ),
              ),
              Expanded(
                child: FocusTraversalGroup(
                  child: DisplayFeatureSubScreen(
                    anchorPoint: Offset(constraints.maxWidth, 0),
                    child: _buildResultsScrollPane(padding: 16),
                  ),
                ),
              ),
            ],
          );
        }

        if (sizeClass.supportsSplitPane) {
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1400),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    flex: 5,
                    child: FocusTraversalGroup(
                      child: _buildInputScrollPane(padding: 20),
                    ),
                  ),
                  const VerticalDivider(width: 1),
                  Expanded(
                    flex: 6,
                    child: FocusTraversalGroup(
                      child: _buildResultsScrollPane(padding: 20),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return CustomScrollView(
          controller: _resultsScrollController,
          primary: false,
          slivers: <Widget>[
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
              sliver: SliverToBoxAdapter(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 640),
                    child: RepaintBoundary(
                      child: Consumer<CalculatorViewModel>(
                        builder: (_, CalculatorViewModel viewModel, _) =>
                            _buildInputSection(viewModel),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              sliver: _buildResultsSliverSelector(maxWidth: 640),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInputScrollPane({required double padding}) {
    return RepaintBoundary(
      child: CustomScrollView(
        controller: _inputScrollController,
        primary: false,
        slivers: <Widget>[
          SliverPadding(
            padding: EdgeInsets.all(padding),
            sliver: SliverToBoxAdapter(
              child: Consumer<CalculatorViewModel>(
                builder: (_, CalculatorViewModel viewModel, _) => _buildInputSection(viewModel),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsScrollPane({required double padding}) {
    return RepaintBoundary(
      child: CustomScrollView(
        controller: _resultsScrollController,
        primary: false,
        slivers: <Widget>[
          SliverPadding(
            padding: EdgeInsets.all(padding),
            sliver: _buildResultsSliverSelector(),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsSliverSelector({double? maxWidth}) {
    return Selector<CalculatorViewModel, _ResultsSnapshot>(
      selector: (_, CalculatorViewModel vm) => (
        errorMessage: vm.errorMessage,
        result: vm.result,
        resultSections: vm.resultSections,
      ),
      builder: (BuildContext context, _ResultsSnapshot snapshot, _) {
        final CalculatorViewModel vm = context.read<CalculatorViewModel>();
        return ResultsSliverList(
          errorMessage: snapshot.errorMessage,
          result: snapshot.result,
          resultSections: snapshot.resultSections,
          onLoadSample: vm.loadSample,
          onCopyText: vm.copyText,
          onCopyReport: vm.copyFullReport,
          maxWidth: maxWidth,
        );
      },
    );
  }

  Widget _buildInputSection(CalculatorViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SegmentedButton<InputMode>(
          segments: const <ButtonSegment<InputMode>>[
            ButtonSegment<InputMode>(
              value: InputMode.guided,
              icon: Icon(Icons.view_agenda_outlined),
              label: Text('Guided Form'),
            ),
            ButtonSegment<InputMode>(
              value: InputMode.quickText,
              icon: Icon(Icons.terminal_rounded),
              label: Text('Quick Text'),
            ),
          ],
          selected: <InputMode>{viewModel.inputMode},
          onSelectionChanged: (Set<InputMode> selection) {
            if (selection.isNotEmpty) {
              viewModel.setInputMode(selection.first);
            }
          },
        ),
        const SizedBox(height: 16),
        switch (viewModel.inputMode) {
          InputMode.guided => GuidedInputPanel(viewModel: viewModel),
          InputMode.quickText => QuickTextInputPanel(viewModel: viewModel),
        },
      ],
    );
  }
}
