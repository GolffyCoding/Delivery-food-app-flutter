import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opendelivery_core/opendelivery_core.dart';
import 'package:opendelivery_sync/opendelivery_sync.dart';
import 'package:driver_app/features/incoming_order/bloc/incoming_order_event.dart';
import 'package:driver_app/features/incoming_order/bloc/incoming_order_state.dart';

class IncomingOrderBloc extends Bloc<IncomingOrderEvent, IncomingOrderState> {
  final SyncQueue _syncQueue;
  Timer? _countdownTimer;
  Map<String, dynamic> _orderData = const {};

  IncomingOrderBloc(this._syncQueue) : super(IncomingOrderRejected()) {
    on<StartCountdown>(_onStartCountdown);
    on<AcceptOrder>(_onAcceptOrder);
    on<RejectOrder>(_onRejectOrder);
  }

  void _onStartCountdown(StartCountdown event, Emitter<IncomingOrderState> emit) {
    _orderData = event.orderData;
    emit(IncomingOrderCountdown(orderData: _orderData, remainingSeconds: 15));

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state is! IncomingOrderCountdown) {
        timer.cancel();
        return;
      }
      final current = (state as IncomingOrderCountdown).remainingSeconds - 1;
      if (current <= 0) {
        timer.cancel();
        add(RejectOrder(_orderData['order_id'] as String? ?? ''));
      } else {
        emit((state as IncomingOrderCountdown).copyWith(remainingSeconds: current));
      }
    });
  }

  Future<void> _onAcceptOrder(AcceptOrder event, Emitter<IncomingOrderState> emit) async {
    _countdownTimer?.cancel();
    emit(IncomingOrderLoading(orderData: _orderData));

    try {
      // Idempotency key = order ID -> the backend rejects a duplicate accept
      // if this app crashes and retries the queued request, preventing the
      // same order from being assigned to two drivers.
      await _syncQueue.enqueue(SyncRequest(
        localId: 'accept_${event.orderId}',
        idempotencyKey: event.orderId,
        path: ApiConstants.driverOrderAccept(event.orderId),
        createdAt: DateTime.now(),
      ));

      emit(IncomingOrderAccepted(orderId: event.orderId));
    } catch (e) {
      emit(IncomingOrderError(message: e.toString()));
    }
  }

  Future<void> _onRejectOrder(RejectOrder event, Emitter<IncomingOrderState> emit) async {
    // The API has no explicit decline endpoint — letting the countdown lapse
    // (or tapping Decline) just stops showing it here; the backend's own
    // offer timeout re-routes the order to the next nearest driver.
    _countdownTimer?.cancel();
    emit(IncomingOrderRejected());
  }

  @override
  Future<void> close() {
    _countdownTimer?.cancel();
    return super.close();
  }
}
