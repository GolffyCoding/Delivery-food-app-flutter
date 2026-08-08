import 'package:equatable/equatable.dart';

import 'order_state.dart' show CancelledBy;

sealed class OrderEvent extends Equatable {
  const OrderEvent();

  @override
  List<Object?> get props => [];
}

class AcceptEvent extends OrderEvent {
  const AcceptEvent();
}

class StartPreparingEvent extends OrderEvent {
  const StartPreparingEvent();
}

class FinishPreparingEvent extends OrderEvent {
  const FinishPreparingEvent();
}

class PickUpEvent extends OrderEvent {
  const PickUpEvent();
}

class StartDeliveringEvent extends OrderEvent {
  const StartDeliveringEvent();
}

class DeliverEvent extends OrderEvent {
  const DeliverEvent();
}

class CompleteEvent extends OrderEvent {
  const CompleteEvent();
}

class CancelEvent extends OrderEvent {
  final String? reason;
  final CancelledBy cancelledBy;
  const CancelEvent({this.reason, this.cancelledBy = CancelledBy.system});

  @override
  List<Object?> get props => [reason, cancelledBy];
}
