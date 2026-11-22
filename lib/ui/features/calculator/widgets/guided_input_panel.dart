import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:ranked_positional_method/core/formatting/number_formatter.dart';
import 'package:ranked_positional_method/domain/models/rpw_input.dart';
import 'package:ranked_positional_method/domain/services/sample_problem_factory.dart';
import 'package:ranked_positional_method/ui/features/calculator/view_models/calculator_view_model.dart';
import 'package:ranked_positional_method/ui/features/calculator/widgets/inline_error_banner.dart';

/// Visual form panel for entering connections, final node, and cycle time.
class GuidedInputPanel extends StatefulWidget {
  /// Creates a [GuidedInputPanel] bound to [viewModel].
  const GuidedInputPanel({
    super.key,
    required this.viewModel,
  });

  /// ViewModel holding the Guided form state and commands.
  final CalculatorViewModel viewModel;

  @override
  State<GuidedInputPanel> createState() => _GuidedInputPanelState();
}

class _GuidedInputPanelState extends State<GuidedInputPanel> {
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();
  final TextEditingController _tekController = TextEditingController();
  final TextEditingController _finalNodeController = TextEditingController();
  final TextEditingController _finalTekController = TextEditingController();
  final TextEditingController _cycleTimeController = TextEditingController();
  final FocusNode _fromFocus = FocusNode();

  int _lastSyncedRevision = -1;

  static final List<TextInputFormatter> _intFormatters = <TextInputFormatter>[
    FilteringTextInputFormatter.digitsOnly,
  ];
  static final List<TextInputFormatter> _decimalFormatters = <TextInputFormatter>[
    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
  ];

  @override
  void initState() {
    super.initState();
    _syncControllersIfNeeded();
  }

  @override
  void didUpdateWidget(covariant GuidedInputPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncControllersIfNeeded();
  }

  void _syncControllersIfNeeded() {
    final CalculatorViewModel vm = widget.viewModel;
    if (vm.formRevision == _lastSyncedRevision) {
      return;
    }
    _lastSyncedRevision = vm.formRevision;
    _finalNodeController.text = vm.finalNodeText;
    _finalTekController.text = vm.finalTekText;
    _cycleTimeController.text = vm.cycleTimeText;
    if (vm.edges.isEmpty) {
      _fromController.clear();
      _toController.clear();
      _tekController.clear();
    }
  }

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    _tekController.dispose();
    _finalNodeController.dispose();
    _finalTekController.dispose();
    _cycleTimeController.dispose();
    _fromFocus.dispose();
    super.dispose();
  }

  void _handleAddEdge() {
    final bool added = widget.viewModel.addEdgeFromText(
      fromText: _fromController.text,
      toText: _toController.text,
      tekText: _tekController.text,
    );
    if (added) {
      _fromController.clear();
      _toController.clear();
      _tekController.clear();
      _fromFocus.requestFocus();
    }
  }

  void _handleRemoveEdge(int index) {
    widget.viewModel.removeEdgeAt(index);
    _fromFocus.requestFocus();
  }

  void _handleCalculate() {
    FocusManager.instance.primaryFocus?.unfocus();
    widget.viewModel.calculateGuided(
      finalNodeText: _finalNodeController.text,
      finalTekText: _finalTekController.text,
      cycleTimeText: _cycleTimeController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    _syncControllersIfNeeded();
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colors = Theme.of(context).colorScheme;
    final List<NodeEdge> edges = widget.viewModel.edges;
    final double textScale = MediaQuery.textScalerOf(context).scale(16) / 16.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: <Widget>[
            Text('Quick Examples:', style: textTheme.labelLarge),
            for (final SamplePreset preset in SamplePreset.values)
              ActionChip(
                avatar: const Icon(Icons.play_arrow_rounded, size: 18),
                label: Text(preset.label),
                onPressed: () => widget.viewModel.loadSample(preset),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Semantics(
                  header: true,
                  child: Text('1. Add Node Connections', style: textTheme.titleMedium),
                ),
                const SizedBox(height: 4),
                Text(
                  'Enter each directed arrow from one node to the next and the task time (Tek) of the From node.',
                  style: textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
                ),
                const SizedBox(height: 12),
                LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    final double effectiveWidth = constraints.maxWidth / textScale;
                    if (effectiveWidth < 360) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          _buildFromField(),
                          const SizedBox(height: 8),
                          _buildToField(),
                          const SizedBox(height: 8),
                          _buildTekField(),
                          const SizedBox(height: 10),
                          _buildAddButton(),
                        ],
                      );
                    }
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(child: _buildFromField()),
                        const SizedBox(width: 8),
                        Expanded(child: _buildToField()),
                        const SizedBox(width: 8),
                        Expanded(child: _buildTekField()),
                        const SizedBox(width: 8),
                        _buildAddButton(),
                      ],
                    );
                  },
                ),
                if (edges.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: <Widget>[
                      for (int i = 0; i < edges.length; i++)
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: colors.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: colors.outlineVariant),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              const SizedBox(width: 12),
                              Flexible(
                                child: Semantics(
                                  label:
                                      'Node ${edges[i].fromNode} to node ${edges[i].toNode}, Tek ${NumberFormatter.format(edges[i].sourceTek)}',
                                  excludeSemantics: true,
                                  child: Text(
                                    'N${edges[i].fromNode} -> N${edges[i].toNode} (Tek ${NumberFormatter.format(edges[i].sourceTek)})',
                                    style: textTheme.labelLarge,
                                  ),
                                ),
                              ),
                              IconButton(
                                tooltip:
                                    'Remove connection from node ${edges[i].fromNode} to node ${edges[i].toNode}',
                                icon: const Icon(Icons.close_rounded, size: 18),
                                onPressed: () => _handleRemoveEdge(i),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Semantics(
                  header: true,
                  child: Text('2. Final Node and Cycle Time', style: textTheme.titleMedium),
                ),
                const SizedBox(height: 12),
                LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    final double effectiveWidth = constraints.maxWidth / textScale;
                    if (effectiveWidth < 360) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          _buildFinalNodeField(),
                          const SizedBox(height: 8),
                          _buildFinalTekField(),
                          const SizedBox(height: 8),
                          _buildCycleTimeField(),
                        ],
                      );
                    }
                    return Row(
                      children: <Widget>[
                        Expanded(child: _buildFinalNodeField()),
                        const SizedBox(width: 8),
                        Expanded(child: _buildFinalTekField()),
                        const SizedBox(width: 8),
                        Expanded(child: _buildCycleTimeField()),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        if (widget.viewModel.errorMessage != null) ...<Widget>[
          InlineErrorBanner(message: widget.viewModel.errorMessage!),
          const SizedBox(height: 12),
        ],
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final double effectiveWidth = constraints.maxWidth / textScale;
            final Widget calcBtn = FilledButton.icon(
              onPressed: _handleCalculate,
              icon: const Icon(Icons.auto_graph_rounded),
              label: const Text('Calculate'),
            );
            final Widget clearBtn = OutlinedButton.icon(
              onPressed: widget.viewModel.clearAll,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Clear'),
            );
            if (effectiveWidth < 280) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  calcBtn,
                  const SizedBox(height: 8),
                  clearBtn,
                ],
              );
            }
            return Row(
              children: <Widget>[
                Expanded(child: calcBtn),
                const SizedBox(width: 10),
                Expanded(child: clearBtn),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildFromField() {
    return TextField(
      controller: _fromController,
      focusNode: _fromFocus,
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.next,
      inputFormatters: _intFormatters,
      decoration: const InputDecoration(
        labelText: 'From',
        hintText: '1',
      ),
    );
  }

  Widget _buildToField() {
    return TextField(
      controller: _toController,
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.next,
      inputFormatters: _intFormatters,
      decoration: const InputDecoration(
        labelText: 'To',
        hintText: '2',
      ),
    );
  }

  Widget _buildTekField() {
    return TextField(
      controller: _tekController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textInputAction: TextInputAction.done,
      inputFormatters: _decimalFormatters,
      onSubmitted: (_) => _handleAddEdge(),
      decoration: const InputDecoration(
        labelText: 'Tek',
        hintText: '0.4',
      ),
    );
  }

  Widget _buildAddButton() {
    return FilledButton.tonalIcon(
      onPressed: _handleAddEdge,
      icon: const Icon(Icons.add_rounded),
      label: const Text('Add'),
    );
  }

  Widget _buildFinalNodeField() {
    return TextField(
      controller: _finalNodeController,
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.next,
      inputFormatters: _intFormatters,
      decoration: const InputDecoration(
        labelText: 'Final Node',
        hintText: '6',
      ),
    );
  }

  Widget _buildFinalTekField() {
    return TextField(
      controller: _finalTekController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textInputAction: TextInputAction.next,
      inputFormatters: _decimalFormatters,
      decoration: const InputDecoration(
        labelText: 'Final Tek',
        hintText: '0.4',
      ),
    );
  }

  Widget _buildCycleTimeField() {
    return TextField(
      controller: _cycleTimeController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textInputAction: TextInputAction.done,
      inputFormatters: _decimalFormatters,
      onSubmitted: (_) => _handleCalculate(),
      decoration: const InputDecoration(
        labelText: 'Cycle Time',
        hintText: '1.0',
      ),
    );
  }
}
