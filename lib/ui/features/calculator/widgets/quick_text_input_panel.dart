import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:ranked_positional_method/ui/features/calculator/view_models/calculator_view_model.dart';

/// Sequential space-separated input mode compatible with rapid keyboard entry.
class QuickTextInputPanel extends StatefulWidget {
  /// Creates a [QuickTextInputPanel] bound to [viewModel].
  const QuickTextInputPanel({
    super.key,
    required this.viewModel,
  });

  /// ViewModel holding the Quick Text step state and commands.
  final CalculatorViewModel viewModel;

  @override
  State<QuickTextInputPanel> createState() => _QuickTextInputPanelState();
}

class _QuickTextInputPanelState extends State<QuickTextInputPanel> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final FocusNode _clearFocusNode = FocusNode();
  int _lastSyncedRevision = -1;

  static final List<TextInputFormatter> _allowlistFormatters = <TextInputFormatter>[
    FilteringTextInputFormatter.allow(RegExp(r'[0-9. ]')),
  ];

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _clearFocusNode.dispose();
    super.dispose();
  }

  void _syncResetIfNeeded() {
    if (widget.viewModel.formRevision != _lastSyncedRevision) {
      _lastSyncedRevision = widget.viewModel.formRevision;
      _controller.clear();
    }
  }

  void _submit() {
    final String value = _controller.text;
    widget.viewModel.submitQuickLine(value);
    if (widget.viewModel.errorMessage == null) {
      _controller.clear();
    }
    if (widget.viewModel.quickStep == QuickStep.complete) {
      _clearFocusNode.requestFocus();
    } else {
      _focusNode.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    _syncResetIfNeeded();
    final CalculatorViewModel vm = widget.viewModel;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colors = Theme.of(context).colorScheme;
    final bool isComplete = vm.quickStep == QuickStep.complete;
    final double textScale = MediaQuery.textScalerOf(context).scale(16) / 16.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Semantics(
              header: true,
              child: Text('Quick Text Entry', style: textTheme.titleMedium),
            ),
            const SizedBox(height: 4),
            Text(
              'Enter space-separated numbers step by step.',
              style: textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
            ),
            const SizedBox(height: 12),
            Semantics(
              container: true,
              liveRegion: true,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: colors.secondaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  vm.quickPrompt,
                  style: textTheme.labelLarge?.copyWith(
                    color: colors.onSecondaryContainer,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (vm.quickLog.isNotEmpty) ...<Widget>[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    for (final String line in vm.quickLog)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text(line, style: textTheme.bodyMedium),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            TextField(
              controller: _controller,
              focusNode: _focusNode,
              enabled: !isComplete,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.done,
              inputFormatters: _allowlistFormatters,
              onSubmitted: (_) => _submit(),
              decoration: InputDecoration(
                labelText: 'Step Input',
                helperText: vm.quickPrompt,
              ),
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final double effectiveWidth = constraints.maxWidth / textScale;
                final Widget enterBtn = FilledButton.icon(
                  onPressed: isComplete ? null : _submit,
                  icon: const Icon(Icons.keyboard_return_rounded),
                  label: const Text('Enter'),
                );
                final Widget clearBtn = OutlinedButton.icon(
                  focusNode: _clearFocusNode,
                  onPressed: vm.clearAll,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Clear'),
                );
                if (effectiveWidth < 280) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      enterBtn,
                      const SizedBox(height: 8),
                      clearBtn,
                    ],
                  );
                }
                return Row(
                  children: <Widget>[
                    Expanded(child: enterBtn),
                    const SizedBox(width: 10),
                    Expanded(child: clearBtn),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
