import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opendelivery_core/opendelivery_core.dart';
import 'package:opendelivery_state_machine/opendelivery_state_machine.dart';
import 'package:driver_app/data/driver_repository.dart';

sealed class ActiveDeliveryEvent {}

class LoadDelivery extends ActiveDeliveryEvent {
  final String orderId;
  LoadDelivery(this.orderId);
}

class UpdateStatus extends ActiveDeliveryEvent {
  final OrderEvent event;
  final String backendStatus;
  UpdateStatus(this.event, this.backendStatus);
}

class ActiveDeliveryState {
  final String orderId;
  final OrderState status;
  const ActiveDeliveryState({required this.orderId, this.status = const PickedUpState()});

  ActiveDeliveryState copyWith({OrderState? status}) => ActiveDeliveryState(orderId: orderId, status: status ?? this.status);
}

class ActiveDeliveryBloc extends Bloc<ActiveDeliveryEvent, ActiveDeliveryState> {
  final DriverRepository _driverRepository;
  OrderStateMachine? _stateMachine;

  ActiveDeliveryBloc(this._driverRepository) : super(const ActiveDeliveryState(orderId: '')) {
    on<LoadDelivery>(_onLoad);
    on<UpdateStatus>(_onUpdateStatus);
  }

  void _onLoad(LoadDelivery event, Emitter<ActiveDeliveryState> emit) {
    final machine = OrderStateMachine();
    // `POST /driver/orders/:id/accept` already moved the backend order to
    // `picked_up` before this screen ever opens, so fast-forward the local
    // machine to match instead of re-deriving it from scratch.
    machine.emit(const AcceptEvent());
    machine.emit(const StartPreparingEvent());
    machine.emit(const FinishPreparingEvent());
    machine.emit(const PickUpEvent());
    _stateMachine = machine;
    emit(ActiveDeliveryState(orderId: event.orderId, status: machine.currentState));
  }

  Future<void> _onUpdateStatus(UpdateStatus event, Emitter<ActiveDeliveryState> emit) async {
    final machine = _stateMachine;
    if (machine == null) return;
    try {
      final newState = machine.emit(event.event);
      emit(state.copyWith(status: newState));

      final result = await _driverRepository.updateOrderStatus(state.orderId, event.backendStatus);
      result.when(
        success: (_) {},
        failure: (failure) => AppLogger.error('Failed to sync order status', error: failure.message, tag: 'ActiveDelivery'),
      );
    } on InvalidTransitionException catch (e) {
      AppLogger.error('Driver tried invalid transition', error: e, tag: 'ActiveDelivery');
    }
  }
}
