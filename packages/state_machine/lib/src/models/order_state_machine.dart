import 'package:opendelivery_state_machine/opendelivery_state_machine.dart';

/// Pre-configured State Machine for Order flows.
/// This prevents bugs like jumping from "Preparing" directly to "Delivered".
class OrderStateMachine extends StateMachine<OrderEvent, OrderState> {
  OrderStateMachine() : super(initialState: const PendingState()) {
    addTransitions([
      const Transition(from: PendingState(), event: AcceptEvent(), to: AcceptedState()),
      const Transition(from: AcceptedState(), event: StartPreparingEvent(), to: PreparingState()),
      const Transition(from: PreparingState(), event: FinishPreparingEvent(), to: ReadyState()),
      const Transition(from: ReadyState(), event: PickUpEvent(), to: PickedUpState()),
      const Transition(from: PickedUpState(), event: StartDeliveringEvent(), to: DeliveringState()),
      const Transition(from: DeliveringState(), event: DeliverEvent(), to: DeliveredState()),
      const Transition(from: DeliveredState(), event: CompleteEvent(), to: CompletedState()),
    ]);

    addTransitions([
      const Transition(from: PendingState(), event: CancelEvent(), to: CancelledState()),
      const Transition(from: AcceptedState(), event: CancelEvent(), to: CancelledState()),
      const Transition(from: PreparingState(), event: CancelEvent(), to: CancelledState()),
      const Transition(from: ReadyState(), event: CancelEvent(), to: CancelledState()),
      // A delivery already in the driver's hands can still fail: wrong/unreachable
      // address, customer refuses the order, driver has an accident, etc. Without
      // these, an in-flight delivery has no way to reach a terminal state other
      // than "delivered", which does not reflect reality.
      const Transition(from: PickedUpState(), event: CancelEvent(), to: CancelledState()),
      const Transition(from: DeliveringState(), event: CancelEvent(), to: CancelledState()),
    ]);
  }
}
