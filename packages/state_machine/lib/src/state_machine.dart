import 'package:opendelivery_state_machine/opendelivery_state_machine.dart';

/// Exception thrown when an invalid state transition is attempted.
class InvalidTransitionException implements Exception {
  final String message;
  const InvalidTransitionException(this.message);

  @override
  String toString() => 'InvalidTransitionException: $message';
}

/// A generic, strictly-typed State Machine.
class StateMachine<Event, State> {
  // Keyed by event *type* rather than event value: events like CancelEvent
  // carry payload fields (reason, cancelledBy) that vary per call, so matching
  // on Equatable value would make lookups fail for any payload other than the
  // exact one used when the transition was registered.
  final Map<State, Map<Type, State>> _transitions = {};
  State _currentState;

  StateMachine({required State initialState}) : _currentState = initialState;

  State get currentState => _currentState;

  void addTransition(Transition<Event, State> transition) {
    _transitions.putIfAbsent(transition.from, () => {});
    _transitions[transition.from]![transition.event.runtimeType] = transition.to;
  }

  void addTransitions(List<Transition<Event, State>> transitions) {
    for (final t in transitions) {
      addTransition(t);
    }
  }

  /// Attempts to trigger an event and transition to the next state.
  /// Throws [InvalidTransitionException] if the transition is not allowed.
  State emit(Event event) {
    final possibleTransitions = _transitions[_currentState];
    final eventType = event.runtimeType;
    if (possibleTransitions == null || !possibleTransitions.containsKey(eventType)) {
      throw InvalidTransitionException('Cannot trigger "$event" from "$_currentState"');
    }
    _currentState = possibleTransitions[eventType]!;
    return _currentState;
  }

  bool canEmit(Event event) => _transitions[_currentState]?.containsKey(event.runtimeType) ?? false;
}
