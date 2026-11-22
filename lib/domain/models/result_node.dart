/// Composite tree node representing structured calculation output.
sealed class ResultNode {
  const ResultNode();

  /// Human-readable title for this node.
  String get title;
}

/// Leaf item in the result composite representing a single copyable metric or row.
class const ResultItem({
  @override required final String title,
  required final String value,
  final String? subtitle,
  final bool isHighlighted = false,
}) extends ResultNode;

/// Composite group holding child [ResultNode] entries under a section heading.
class const ResultGroup({
  @override required final String title,
  required final List<ResultNode> children,
}) extends ResultNode;
