import 'package:equatable/equatable.dart';

sealed class OrderState extends Equatable {
  const OrderState();

  bool get isFinalState => this is CompletedState || this is CancelledState;
  bool get isActive => !isFinalState;

  @override
  List<Object?> get props => [];
}

class PendingState extends OrderState {
  const PendingState();
}

class AcceptedState extends OrderState {
  const AcceptedState();
}

class PreparingState extends OrderState {
  const PreparingState();
}

class ReadyState extends OrderState {
  const ReadyState();
}

class PickedUpState extends OrderState {
  const PickedUpState();
}

class DeliveringState extends OrderState {
  const DeliveringState();
}

class DeliveredState extends OrderState {
  const DeliveredState();
}

class CompletedState extends OrderState {
  const CompletedState();
}

enum CancelledBy { customer, merchant, driver, system }

class CancelledState extends OrderState {
  final String? reason;
  final CancelledBy cancelledBy;
  const CancelledState({this.reason, this.cancelledBy = CancelledBy.system});

  @override
  List<Object?> get props => [reason, cancelledBy];
}
