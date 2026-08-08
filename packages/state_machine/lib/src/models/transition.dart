/// Represents a rule to move from one state to another given an event.
class Transition<Event, State> {
  final State from;
  final Event event;
  final State to;

  const Transition({required this.from, required this.event, required this.to});
}
