import 'package:ranked_positional_method/core/constants/app_constants.dart';
import 'package:ranked_positional_method/domain/models/rpw_error.dart';
import 'package:ranked_positional_method/domain/models/rpw_input.dart';

/// Validates raw text and structured RPW inputs against strict allowlists and bounds.
class RpwInputValidator {
  const RpwInputValidator();

  static final RegExp _numericSpaceAllowlist = RegExp(r'^[0-9. ]+$');
  static final RegExp _whitespaceSplit = RegExp(r'\s+');

  /// Checks whether [raw] contains only digits, decimal points, and spaces within length limits.
  bool isAllowedRawText(String raw) {
    final String trimmed = raw.trim();
    if (trimmed.isEmpty || trimmed.length > AppConstants.maxInputLength) {
      return false;
    }
    return _numericSpaceAllowlist.hasMatch(trimmed);
  }

  /// Parses a positive integer node identifier or edge count from [raw].
  SolveOutcome<int> parsePositiveInt(
    String raw, {
    required String fieldName,
    int? maxValue,
  }) {
    final String trimmed = raw.trim();
    final int? parsed = int.tryParse(trimmed);
    if (parsed == null || parsed <= 0) {
      return SolveError<int>(
        InvalidInputFailure('$fieldName must be a positive whole number.'),
      );
    }
    if (maxValue != null && parsed > maxValue) {
      return SolveError<int>(
        InputLimitExceededFailure('$fieldName cannot exceed $maxValue.'),
      );
    }
    return SolveSuccess<int>(parsed);
  }

  /// Parses a non-negative finite task time from [raw].
  SolveOutcome<double> parseTek(String raw, {String fieldName = 'Task time (Tek)'}) {
    final double? parsed = double.tryParse(raw.trim());
    if (parsed == null || !parsed.isFinite || parsed < 0) {
      return SolveError<double>(
        InvalidInputFailure('$fieldName must be zero or a positive number.'),
      );
    }
    return SolveSuccess<double>(parsed);
  }

  /// Parses a strictly positive finite cycle time from [raw].
  SolveOutcome<double> parseCycleTime(String raw) {
    final double? parsed = double.tryParse(raw.trim());
    if (parsed == null || !parsed.isFinite || parsed <= 0) {
      return const SolveError<double>(
        InvalidInputFailure('Cycle time must be greater than zero.'),
      );
    }
    return SolveSuccess<double>(parsed);
  }

  /// Parses a space-separated `fromNode toNode sourceTek` line in Quick Text mode.
  SolveOutcome<NodeEdge> parseQuickEdgeLine(String raw) {
    if (!isAllowedRawText(raw)) {
      return const SolveError<NodeEdge>(
        InvalidInputFailure('Use only numbers and spaces, e.g. "1 2 0.5".'),
      );
    }
    final List<String> tokens = raw.trim().split(_whitespaceSplit);
    return switch (tokens) {
      [final fromStr, final toStr, final tekStr] => _buildEdge(fromStr, toStr, tekStr),
      _ => const SolveError<NodeEdge>(
        InvalidInputFailure('Enter three values separated by spaces: FromNode ToNode Tek.'),
      ),
    };
  }

  /// Parses a space-separated `finalNodeId finalNodeTek` line in Quick Text mode.
  SolveOutcome<({int finalNodeId, double finalNodeTek})> parseQuickFinalNodeLine(String raw) {
    if (!isAllowedRawText(raw)) {
      return const SolveError<({int finalNodeId, double finalNodeTek})>(
        InvalidInputFailure('Use only numbers and spaces, e.g. "6 0.4".'),
      );
    }
    final List<String> tokens = raw.trim().split(_whitespaceSplit);
    return switch (tokens) {
      [final nodeStr, final tekStr] => _buildFinalNode(nodeStr, tekStr),
      _ => const SolveError<({int finalNodeId, double finalNodeTek})>(
        InvalidInputFailure('Enter two values separated by a space: FinalNode Tek.'),
      ),
    };
  }

  /// Validates the structural integrity and resource bounds of [input].
  RpwFailure? validateInput(RpwInput input) {
    if (input.edges.isEmpty) {
      return const InvalidInputFailure('Add at least one node connection before calculating.');
    }
    if (input.edges.length > AppConstants.maxEdges) {
      return const InputLimitExceededFailure(
        'Too many connections. Maximum supported is ${AppConstants.maxEdges}.',
      );
    }
    if (!input.cycleTime.isFinite || input.cycleTime <= 0) {
      return const InvalidInputFailure('Cycle time must be greater than zero.');
    }
    if (!input.finalNodeTek.isFinite || input.finalNodeTek < 0) {
      return const InvalidInputFailure('Final node Tek must be zero or positive.');
    }
    if (input.finalNodeId <= 0) {
      return const InvalidInputFailure('Final node ID must be a positive whole number.');
    }

    final Set<int> uniqueNodes = <int>{input.finalNodeId};
    final Map<int, double> sourceTekByNode = <int, double>{};
    final Set<({int from, int to})> seenEdges = <({int from, int to})>{};

    for (final NodeEdge edge in input.edges) {
      if (edge.fromNode <= 0 || edge.toNode <= 0) {
        return const InvalidInputFailure('Node IDs must be positive whole numbers.');
      }
      if (edge.fromNode == edge.toNode) {
        return InvalidInputFailure('Node ${edge.fromNode} cannot connect to itself.');
      }
      if (!edge.sourceTek.isFinite || edge.sourceTek < 0) {
        return InvalidInputFailure('Task time for node ${edge.fromNode} must be zero or positive.');
      }
      if (!seenEdges.add((from: edge.fromNode, to: edge.toNode))) {
        return InvalidInputFailure(
          'Duplicate connection from node ${edge.fromNode} to ${edge.toNode}.',
        );
      }

      final double? existingTek = sourceTekByNode[edge.fromNode];
      if (existingTek != null && (existingTek - edge.sourceTek).abs() > AppConstants.epsilon) {
        return InvalidInputFailure(
          'Node ${edge.fromNode} has conflicting Tek values ($existingTek vs ${edge.sourceTek}).',
        );
      }
      sourceTekByNode[edge.fromNode] = edge.sourceTek;
      uniqueNodes.add(edge.fromNode);
      uniqueNodes.add(edge.toNode);
    }

    if (uniqueNodes.length > AppConstants.maxUniqueNodes) {
      return const InputLimitExceededFailure(
        'Too many unique nodes. Maximum supported is ${AppConstants.maxUniqueNodes}.',
      );
    }
    if (sourceTekByNode.containsKey(input.finalNodeId)) {
      return InvalidInputFailure(
        'Final node ${input.finalNodeId} cannot have outgoing connections.',
      );
    }
    return null;
  }

  SolveOutcome<NodeEdge> _buildEdge(String fromStr, String toStr, String tekStr) {
    final SolveOutcome<int> fromOutcome = parsePositiveInt(fromStr, fieldName: 'From node');
    if (fromOutcome is SolveError<int>) {
      return SolveError<NodeEdge>(fromOutcome.failure);
    }
    final SolveOutcome<int> toOutcome = parsePositiveInt(toStr, fieldName: 'To node');
    if (toOutcome is SolveError<int>) {
      return SolveError<NodeEdge>(toOutcome.failure);
    }
    final SolveOutcome<double> tekOutcome = parseTek(tekStr);
    if (tekOutcome is SolveError<double>) {
      return SolveError<NodeEdge>(tekOutcome.failure);
    }

    final int fromNode = (fromOutcome as SolveSuccess<int>).value;
    final int toNode = (toOutcome as SolveSuccess<int>).value;
    final double tek = (tekOutcome as SolveSuccess<double>).value;

    if (fromNode == toNode) {
      return SolveError<NodeEdge>(
        InvalidInputFailure('Node $fromNode cannot connect to itself.'),
      );
    }
    return SolveSuccess<NodeEdge>(
      NodeEdge(fromNode: fromNode, toNode: toNode, sourceTek: tek),
    );
  }

  SolveOutcome<({int finalNodeId, double finalNodeTek})> _buildFinalNode(
    String nodeStr,
    String tekStr,
  ) {
    final SolveOutcome<int> nodeOutcome = parsePositiveInt(nodeStr, fieldName: 'Final node');
    if (nodeOutcome is SolveError<int>) {
      return SolveError<({int finalNodeId, double finalNodeTek})>(nodeOutcome.failure);
    }
    final SolveOutcome<double> tekOutcome = parseTek(tekStr, fieldName: 'Final node Tek');
    if (tekOutcome is SolveError<double>) {
      return SolveError<({int finalNodeId, double finalNodeTek})>(tekOutcome.failure);
    }
    return SolveSuccess<({int finalNodeId, double finalNodeTek})>((
      finalNodeId: (nodeOutcome as SolveSuccess<int>).value,
      finalNodeTek: (tekOutcome as SolveSuccess<double>).value,
    ));
  }
}
