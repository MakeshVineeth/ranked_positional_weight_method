import 'package:ranked_positional_method/domain/models/rpw_input.dart';

/// Preset assembly line problem scenarios available via [SampleProblemFactory].
enum SamplePreset {
  /// Six-task serial and branched textbook example.
  classicSixNode('6-Node Classic Line'),

  /// Eight-task network with converging subassemblies.
  parallelEightNode('8-Node Parallel Line'),

  /// Small network illustrating a task exceeding cycle time.
  oversizedTaskCase('Oversized Task Case');

  const SamplePreset(this.label);

  /// Display name shown in sample selectors.
  final String label;
}

/// Factory creating built-in [RpwInput] datasets for learning and verification.
abstract final class SampleProblemFactory {
  /// Builds an [RpwInput] instance matching the selected [preset].
  static RpwInput create(SamplePreset preset) => switch (preset) {
    SamplePreset.classicSixNode => const RpwInput(
      edges: <NodeEdge>[
        NodeEdge(fromNode: 1, toNode: 2, sourceTek: 0.4),
        NodeEdge(fromNode: 1, toNode: 3, sourceTek: 0.4),
        NodeEdge(fromNode: 2, toNode: 4, sourceTek: 0.6),
        NodeEdge(fromNode: 3, toNode: 4, sourceTek: 0.3),
        NodeEdge(fromNode: 4, toNode: 5, sourceTek: 0.5),
        NodeEdge(fromNode: 5, toNode: 6, sourceTek: 0.2),
      ],
      finalNodeId: 6,
      finalNodeTek: 0.4,
      cycleTime: 1.0,
    ),
    SamplePreset.parallelEightNode => const RpwInput(
      edges: <NodeEdge>[
        NodeEdge(fromNode: 1, toNode: 2, sourceTek: 2.0),
        NodeEdge(fromNode: 1, toNode: 3, sourceTek: 2.0),
        NodeEdge(fromNode: 2, toNode: 4, sourceTek: 4.0),
        NodeEdge(fromNode: 3, toNode: 5, sourceTek: 3.0),
        NodeEdge(fromNode: 4, toNode: 6, sourceTek: 5.0),
        NodeEdge(fromNode: 5, toNode: 6, sourceTek: 2.0),
        NodeEdge(fromNode: 6, toNode: 7, sourceTek: 3.0),
        NodeEdge(fromNode: 7, toNode: 8, sourceTek: 4.0),
      ],
      finalNodeId: 8,
      finalNodeTek: 1.0,
      cycleTime: 8.0,
    ),
    SamplePreset.oversizedTaskCase => const RpwInput(
      edges: <NodeEdge>[
        NodeEdge(fromNode: 1, toNode: 2, sourceTek: 3.0),
        NodeEdge(fromNode: 2, toNode: 3, sourceTek: 6.0),
        NodeEdge(fromNode: 3, toNode: 4, sourceTek: 2.0),
      ],
      finalNodeId: 4,
      finalNodeTek: 2.0,
      cycleTime: 5.0,
    ),
  };
}
