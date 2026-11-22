import 'dart:ui' show DisplayFeature, DisplayFeatureType;

import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:ranked_positional_method/core/layout/window_size_class.dart';
import 'package:ranked_positional_method/ui/features/calculator/view_models/calculator_view_model.dart';
import 'package:ranked_positional_method/ui/features/calculator/widgets/guided_input_panel.dart';
import 'package:ranked_positional_method/ui/features/calculator/widgets/quick_text_input_panel.dart';
import 'package:ranked_positional_method/ui/features/calculator/widgets/results_panel.dart';
import 'package:ranked_positional_method/ui/features/calculator/widgets/wear_calculator_view.dart';

/// Main adaptive RPW calculator workspace supporting Wear, Phones, Foldables, Tablets, and Desktop.
class CalculatorScreen extends StatelessWidget {
  /// Creates a [CalculatorScreen].
  const CalculatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final CalculatorViewModel viewModel = context.watch<CalculatorViewModel>();
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
          return WearCalculatorView(viewModel: viewModel);
        }

        final Widget inputColumn = _buildInputSection(viewModel);
        final Widget resultsColumn = ResultsPanel(viewModel: viewModel);

        if (hasVerticalHinge && sizeClass.supportsSplitPane) {
          return Row(
            children: <Widget>[
              Expanded(
                child: FocusTraversalGroup(
                  child: DisplayFeatureSubScreen(
                    anchorPoint: Offset.zero,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: inputColumn,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: FocusTraversalGroup(
                  child: DisplayFeatureSubScreen(
                    anchorPoint: Offset(constraints.maxWidth, 0),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: resultsColumn,
                    ),
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
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: inputColumn,
                      ),
                    ),
                  ),
                  const VerticalDivider(width: 1),
                  Expanded(
                    flex: 6,
                    child: FocusTraversalGroup(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: resultsColumn,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  inputColumn,
                  const SizedBox(height: 20),
                  resultsColumn,
                ],
              ),
            ),
          ),
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
