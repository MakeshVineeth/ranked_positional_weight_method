import 'package:flutter/foundation.dart';
import 'package:ranked_positional_method/core/constants/app_constants.dart';
import 'package:ranked_positional_method/core/formatting/number_formatter.dart';
import 'package:ranked_positional_method/data/services/clipboard_service.dart';
import 'package:ranked_positional_method/domain/models/result_node.dart';
import 'package:ranked_positional_method/domain/models/rpw_error.dart';
import 'package:ranked_positional_method/domain/models/rpw_input.dart';
import 'package:ranked_positional_method/domain/models/rpw_result.dart';
import 'package:ranked_positional_method/domain/services/rpw_input_validator.dart';
import 'package:ranked_positional_method/domain/services/rpw_output_composer.dart';
import 'package:ranked_positional_method/domain/services/rpw_solver.dart';
import 'package:ranked_positional_method/domain/services/sample_problem_factory.dart';

/// Input mode selected on the calculator screen.
enum InputMode {
  /// Visual form for adding node connections, final node, and cycle time.
  guided,

  /// Space-separated sequential command-style input mode.
  quickText,
}

/// Active step within [InputMode.quickText].
enum QuickStep {
  /// Waiting for the number of directed connections.
  connectionCount,

  /// Collecting space-separated `from to tek` connection lines.
  connectionEntry,

  /// Waiting for `finalNodeId finalNodeTek`.
  finalNode,

  /// Waiting for `cycleTime`.
  cycleTime,

  /// Calculation completed; ready for reset.
  complete,
}

/// ViewModel coordinating input state, validation, RPW calculation, and clipboard copy.
class CalculatorViewModel extends ChangeNotifier {
  /// Creates a [CalculatorViewModel] with injected domain and platform services.
  CalculatorViewModel({
    required this._validator,
    required this._solver,
    required this._composer,
    required this._clipboard,
  });

  final RpwInputValidator _validator;
  final RpwSolver _solver;
  final RpwOutputComposer _composer;
  final ClipboardAdapter _clipboard;

  InputMode _inputMode = InputMode.guided;
  final List<NodeEdge> _edges = <NodeEdge>[];
  String _finalNodeText = '';
  String _finalTekText = '';
  String _cycleTimeText = '';

  QuickStep _quickStep = QuickStep.connectionCount;
  int _targetEdgeCount = 0;
  final List<NodeEdge> _quickEdges = <NodeEdge>[];
  final List<String> _quickLog = <String>[];
  int? _quickFinalNodeId;
  double? _quickFinalNodeTek;

  RpwResult? _result;
  List<ResultGroup> _resultSections = const <ResultGroup>[];
  String? _errorMessage;
  int _formRevision = 0;

  /// Active UI input mode.
  InputMode get inputMode => _inputMode;

  /// Immutable list of edges entered in Guided mode.
  List<NodeEdge> get edges => List<NodeEdge>.unmodifiable(_edges);

  /// Current text representation for the Guided final node field.
  String get finalNodeText => _finalNodeText;

  /// Current text representation for the Guided final node Tek field.
  String get finalTekText => _finalTekText;

  /// Current text representation for the Guided cycle time field.
  String get cycleTimeText => _cycleTimeText;

  /// Monotonically incremented counter telling views when fields were programmatically replaced.
  int get formRevision => _formRevision;

  /// Current step in Quick Text mode.
  QuickStep get quickStep => _quickStep;

  /// Immutable history lines displayed in Quick Text mode.
  List<String> get quickLog => List<String>.unmodifiable(_quickLog);

  /// Latest computed RPW result, or `null` when none is available.
  RpwResult? get result => _result;

  /// Composite sections rendered from [result].
  List<ResultGroup> get resultSections => _resultSections;

  /// Validation or solver error message, if any.
  String? get errorMessage => _errorMessage;

  /// Descriptive input hint for the current Quick Text step.
  String get quickPrompt => switch (_quickStep) {
    QuickStep.connectionCount => 'Enter number of connections (e.g. 6)',
    QuickStep.connectionEntry =>
      'Connection ${_quickEdges.length + 1} of $_targetEdgeCount: From To Tek',
    QuickStep.finalNode => 'Enter Final Node and its Tek (e.g. 6 0.4)',
    QuickStep.cycleTime => 'Enter Cycle Time (e.g. 1.0)',
    QuickStep.complete => 'Calculation complete. Press Clear to start over.',
  };

  /// Switches between Guided and Quick Text input modes.
  void setInputMode(InputMode mode) {
    if (_inputMode == mode) {
      return;
    }
    _inputMode = mode;
    _errorMessage = null;
    notifyListeners();
  }

  /// Validates and appends a connection edge in Guided mode.
  bool addEdgeFromText({
    required String fromText,
    required String toText,
    required String tekText,
  }) {
    if (_edges.length >= AppConstants.maxEdges) {
      _errorMessage = 'Maximum of ${AppConstants.maxEdges} connections reached.';
      notifyListeners();
      return false;
    }

    final SolveOutcome<int> fromOutcome = _validator.parsePositiveInt(
      fromText,
      fieldName: 'From node',
    );
    if (fromOutcome is SolveError<int>) {
      _errorMessage = fromOutcome.failure.message;
      notifyListeners();
      return false;
    }

    final SolveOutcome<int> toOutcome = _validator.parsePositiveInt(
      toText,
      fieldName: 'To node',
    );
    if (toOutcome is SolveError<int>) {
      _errorMessage = toOutcome.failure.message;
      notifyListeners();
      return false;
    }

    final SolveOutcome<double> tekOutcome = _validator.parseTek(tekText);
    if (tekOutcome is SolveError<double>) {
      _errorMessage = tekOutcome.failure.message;
      notifyListeners();
      return false;
    }

    final int fromNode = (fromOutcome as SolveSuccess<int>).value;
    final int toNode = (toOutcome as SolveSuccess<int>).value;
    final double sourceTek = (tekOutcome as SolveSuccess<double>).value;

    if (fromNode == toNode) {
      _errorMessage = 'Node $fromNode cannot connect to itself.';
      notifyListeners();
      return false;
    }

    for (final NodeEdge existing in _edges) {
      if (existing.fromNode == fromNode && existing.toNode == toNode) {
        _errorMessage = 'Connection $fromNode -> $toNode is already added.';
        notifyListeners();
        return false;
      }
      if (existing.fromNode == fromNode &&
          (existing.sourceTek - sourceTek).abs() > AppConstants.epsilon) {
        _errorMessage =
            'Node $fromNode already has Tek ${NumberFormatter.format(existing.sourceTek)}.';
        notifyListeners();
        return false;
      }
    }

    _edges.add(NodeEdge(fromNode: fromNode, toNode: toNode, sourceTek: sourceTek));
    _errorMessage = null;
    notifyListeners();
    return true;
  }

  /// Removes the connection at [index] from Guided mode.
  void removeEdgeAt(int index) {
    if (index < 0 || index >= _edges.length) {
      return;
    }
    _edges.removeAt(index);
    _errorMessage = null;
    notifyListeners();
  }

  /// Solves the currently configured Guided network.
  void calculateGuided({
    required String finalNodeText,
    required String finalTekText,
    required String cycleTimeText,
  }) {
    _finalNodeText = finalNodeText.trim();
    _finalTekText = finalTekText.trim();
    _cycleTimeText = cycleTimeText.trim();

    if (_edges.isEmpty) {
      _errorMessage = 'Add at least one node connection before calculating.';
      notifyListeners();
      return;
    }

    final SolveOutcome<int> finalNodeOutcome = _validator.parsePositiveInt(
      _finalNodeText,
      fieldName: 'Final node',
    );
    if (finalNodeOutcome is SolveError<int>) {
      _errorMessage = finalNodeOutcome.failure.message;
      notifyListeners();
      return;
    }

    final SolveOutcome<double> finalTekOutcome = _validator.parseTek(
      _finalTekText,
      fieldName: 'Final node Tek',
    );
    if (finalTekOutcome is SolveError<double>) {
      _errorMessage = finalTekOutcome.failure.message;
      notifyListeners();
      return;
    }

    final SolveOutcome<double> cycleOutcome = _validator.parseCycleTime(_cycleTimeText);
    if (cycleOutcome is SolveError<double>) {
      _errorMessage = cycleOutcome.failure.message;
      notifyListeners();
      return;
    }

    final RpwInput input = RpwInput(
      edges: List<NodeEdge>.unmodifiable(_edges),
      finalNodeId: (finalNodeOutcome as SolveSuccess<int>).value,
      finalNodeTek: (finalTekOutcome as SolveSuccess<double>).value,
      cycleTime: (cycleOutcome as SolveSuccess<double>).value,
    );
    _runSolver(input);
  }

  /// Processes one sequential line in Quick Text mode.
  void submitQuickLine(String raw) {
    if (_quickStep == QuickStep.complete) {
      return;
    }

    switch (_quickStep) {
      case QuickStep.connectionCount:
        if (!_validator.isAllowedRawText(raw)) {
          _errorMessage = 'Enter a positive whole number of connections.';
          notifyListeners();
          return;
        }
        final SolveOutcome<int> countOutcome = _validator.parsePositiveInt(
          raw,
          fieldName: 'Number of connections',
          maxValue: AppConstants.maxEdges,
        );
        if (countOutcome is SolveError<int>) {
          _errorMessage = countOutcome.failure.message;
          notifyListeners();
          return;
        }
        _targetEdgeCount = (countOutcome as SolveSuccess<int>).value;
        _quickLog.add('Connections: $_targetEdgeCount');
        _quickStep = QuickStep.connectionEntry;
        _errorMessage = null;
        notifyListeners();

      case QuickStep.connectionEntry:
        final SolveOutcome<NodeEdge> edgeOutcome = _validator.parseQuickEdgeLine(raw);
        if (edgeOutcome is SolveError<NodeEdge>) {
          _errorMessage = edgeOutcome.failure.message;
          notifyListeners();
          return;
        }
        final NodeEdge edge = (edgeOutcome as SolveSuccess<NodeEdge>).value;
        for (final NodeEdge existing in _quickEdges) {
          if (existing.fromNode == edge.fromNode && existing.toNode == edge.toNode) {
            _errorMessage = 'Connection ${edge.fromNode} -> ${edge.toNode} is already entered.';
            notifyListeners();
            return;
          }
          if (existing.fromNode == edge.fromNode &&
              (existing.sourceTek - edge.sourceTek).abs() > AppConstants.epsilon) {
            _errorMessage =
                'Node ${edge.fromNode} already has Tek ${NumberFormatter.format(existing.sourceTek)}.';
            notifyListeners();
            return;
          }
        }
        _quickEdges.add(edge);
        _quickLog.add(
          'Edge ${_quickEdges.length}: N${edge.fromNode} -> N${edge.toNode} (Tek ${NumberFormatter.format(edge.sourceTek)})',
        );
        _errorMessage = null;
        if (_quickEdges.length >= _targetEdgeCount) {
          _quickStep = QuickStep.finalNode;
        }
        notifyListeners();

      case QuickStep.finalNode:
        final SolveOutcome<({int finalNodeId, double finalNodeTek})> finalOutcome = _validator
            .parseQuickFinalNodeLine(raw);
        if (finalOutcome is SolveError<({int finalNodeId, double finalNodeTek})>) {
          _errorMessage = finalOutcome.failure.message;
          notifyListeners();
          return;
        }
        final ({int finalNodeId, double finalNodeTek}) parsed =
            (finalOutcome as SolveSuccess<({int finalNodeId, double finalNodeTek})>).value;
        _quickFinalNodeId = parsed.finalNodeId;
        _quickFinalNodeTek = parsed.finalNodeTek;
        _quickLog.add(
          'Final Node: N${parsed.finalNodeId} (Tek ${NumberFormatter.format(parsed.finalNodeTek)})',
        );
        _quickStep = QuickStep.cycleTime;
        _errorMessage = null;
        notifyListeners();

      case QuickStep.cycleTime:
        if (!_validator.isAllowedRawText(raw)) {
          _errorMessage = 'Cycle time must be a positive number.';
          notifyListeners();
          return;
        }
        final SolveOutcome<double> cycleOutcome = _validator.parseCycleTime(raw);
        if (cycleOutcome is SolveError<double>) {
          _errorMessage = cycleOutcome.failure.message;
          notifyListeners();
          return;
        }
        final double cycleTime = (cycleOutcome as SolveSuccess<double>).value;
        _quickLog.add('Cycle Time: ${NumberFormatter.format(cycleTime)}');
        _quickStep = QuickStep.complete;

        final RpwInput input = RpwInput(
          edges: List<NodeEdge>.unmodifiable(_quickEdges),
          finalNodeId: _quickFinalNodeId!,
          finalNodeTek: _quickFinalNodeTek!,
          cycleTime: cycleTime,
        );
        _runSolver(input);

      case QuickStep.complete:
        break;
    }
  }

  /// Loads a built-in [preset] problem into Guided mode and solves it.
  void loadSample(SamplePreset preset) {
    final RpwInput sample = SampleProblemFactory.create(preset);
    _edges
      ..clear()
      ..addAll(sample.edges);
    _finalNodeText = sample.finalNodeId.toString();
    _finalTekText = NumberFormatter.format(sample.finalNodeTek);
    _cycleTimeText = NumberFormatter.format(sample.cycleTime);
    _inputMode = InputMode.guided;
    _formRevision++;
    _runSolver(sample);
  }

  /// Clears all Guided inputs, Quick Text history, errors, and calculation results.
  void clearAll() {
    _edges.clear();
    _finalNodeText = '';
    _finalTekText = '';
    _cycleTimeText = '';

    _quickStep = QuickStep.connectionCount;
    _targetEdgeCount = 0;
    _quickEdges.clear();
    _quickLog.clear();
    _quickFinalNodeId = null;
    _quickFinalNodeTek = null;

    _result = null;
    _resultSections = const <ResultGroup>[];
    _errorMessage = null;
    _formRevision++;
    notifyListeners();
  }

  /// Copies a single string [text] to the system clipboard.
  Future<void> copyText(String text) {
    return _clipboard.copyText(text);
  }

  /// Copies the full formatted RPW report to the system clipboard.
  Future<void> copyFullReport() async {
    final RpwResult? current = _result;
    if (current == null) {
      return;
    }
    await _clipboard.copyText(_composer.toPlainText(current));
  }

  void _runSolver(RpwInput input) {
    final SolveOutcome<RpwResult> outcome = _solver.solve(input);
    switch (outcome) {
      case SolveSuccess<RpwResult>(:final value):
        _result = value;
        _resultSections = List<ResultGroup>.unmodifiable(_composer.buildSections(value));
        _errorMessage = null;
      case SolveError<RpwResult>(:final failure):
        _result = null;
        _resultSections = const <ResultGroup>[];
        _errorMessage = failure.message;
    }
    notifyListeners();
  }
}
