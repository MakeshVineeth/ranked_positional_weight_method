/// Typed domain failure hierarchy for RPW validation and graph solving.
sealed class RpwFailure {
  /// Human-readable message describing the failure.
  String get message;
}

/// Failure raised when user-supplied numbers or syntax are invalid.
class const InvalidInputFailure(@override final String message) implements RpwFailure;

/// Failure raised when precedence edges form a directed cycle.
class const CyclicGraphFailure(@override final String message) implements RpwFailure;

/// Failure raised when nodes cannot all reach the terminal node or lack task times.
class const DisconnectedGraphFailure(@override final String message) implements RpwFailure;

/// Failure raised when input size exceeds safe resource bounds.
class const InputLimitExceededFailure(@override final String message) implements RpwFailure;

/// Outcome union returning either a computed [value] or a typed [failure].
sealed class SolveOutcome<T> {
  const SolveOutcome();
}

/// Successful calculation outcome carrying [value].
class const SolveSuccess<T>(final T value) extends SolveOutcome<T>;

/// Failed calculation outcome carrying [failure].
class const SolveError<T>(final RpwFailure failure) extends SolveOutcome<T>;
