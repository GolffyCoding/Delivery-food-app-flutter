import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:opendelivery_core/opendelivery_core.dart';
import 'package:opendelivery_network/opendelivery_network.dart';
import 'package:customer_app/data/order/order_repository.dart';
import 'package:customer_app/data/tracking/eta_repository.dart';
import 'package:customer_app/domain/models/order_model.dart';

sealed class OrderTrackingEvent {
  const OrderTrackingEvent();
}

class OrderTrackingLoad extends OrderTrackingEvent {
  final String orderId;
  const OrderTrackingLoad(this.orderId);
}

class _OrderStatusPushed extends OrderTrackingEvent {
  final String status;
  const _OrderStatusPushed(this.status);
}

class _DriverLocationPushed extends OrderTrackingEvent {
  final double lat;
  final double lng;
  const _DriverLocationPushed(this.lat, this.lng);
}

class OrderTrackingCancel extends OrderTrackingEvent {
  const OrderTrackingCancel();
}

sealed class OrderTrackingState {
  const OrderTrackingState();
}

class OrderTrackingLoading extends OrderTrackingState {
  const OrderTrackingLoading();
}

class OrderTrackingLoaded extends OrderTrackingState {
  final OrderModel order;
  final bool isCancelling;
  final String? cancelError;
  // Live ETA to the delivery address, recomputed client-side each time the
  // driver's location pings in over `driver:<id>` — null until the driver
  // has been picked-up/en-route and at least one location update arrives.
  final int? etaMinutes;
  final double? etaDistanceKm;
  const OrderTrackingLoaded(this.order, {this.isCancelling = false, this.cancelError, this.etaMinutes, this.etaDistanceKm});
}

class OrderTrackingError extends OrderTrackingState {
  final String message;
  const OrderTrackingError(this.message);
}

@injectable
class OrderTrackingBloc extends Bloc<OrderTrackingEvent, OrderTrackingState> {
  final OrderRepository _repository;
  final EtaRepository _etaRepository;
  final WebSocketService _wsService;
  final SecureStorageService _secureStorage;
  StreamSubscription? _wsSub;
  String? _driverRoomJoined;

  OrderTrackingBloc(this._repository, this._etaRepository, this._wsService, this._secureStorage) : super(const OrderTrackingLoading()) {
    on<OrderTrackingLoad>(_onLoad);
    on<_OrderStatusPushed>(_onStatusPushed);
    on<_DriverLocationPushed>(_onDriverLocationPushed);
    on<OrderTrackingCancel>(_onCancel);
  }

  Future<void> _onLoad(OrderTrackingLoad event, Emitter<OrderTrackingState> emit) async {
    emit(const OrderTrackingLoading());

    final result = await _repository.getById(event.orderId);
    result.when(
      success: (order) => emit(OrderTrackingLoaded(order)),
      failure: (failure) => emit(OrderTrackingError(failure.message)),
    );
    _joinDriverRoomIfNeeded();

    // Live status pushes: `{"type":"order","event":"order.accepted",...}` on
    // room `order:<id>`, per the realtime API.
    final token = await _secureStorage.get(StorageConstants.accessTokenKey);
    await _wsService.connect('${ApiConstants.wsBaseUrl}${ApiConstants.ws}', token: token);
    _wsService.joinRoom('order:${event.orderId}');
    _joinDriverRoomIfNeeded();
    _wsSub = _wsService.messages.listen((msg) {
      if (msg['type'] == 'order' && (msg['payload'] as Map?)?['order_id'] == event.orderId) {
        final status = (msg['payload'] as Map)['status'] as String?;
        if (status != null) add(_OrderStatusPushed(status));
      } else if (msg['type'] == 'driver' && msg['event'] == 'driver.location') {
        final payload = msg['payload'] as Map?;
        final lat = (payload?['latitude'] as num?)?.toDouble();
        final lng = (payload?['longitude'] as num?)?.toDouble();
        if (lat != null && lng != null) add(_DriverLocationPushed(lat, lng));
      }
    });
  }

  // The driver-location room is keyed by driver ID, which we only learn once
  // the order loads — so this gets called again after load succeeds, and is
  // a no-op once already joined for this driver.
  void _joinDriverRoomIfNeeded() {
    final current = state;
    if (current is! OrderTrackingLoaded) return;
    final driverId = current.order.driverId;
    if (driverId == null || driverId == _driverRoomJoined) return;
    if (!const ['picked_up', 'delivering'].contains(current.order.status)) return;
    _wsService.joinRoom('driver:$driverId');
    _driverRoomJoined = driverId;
  }

  Future<void> _onDriverLocationPushed(_DriverLocationPushed event, Emitter<OrderTrackingState> emit) async {
    final current = state;
    if (current is! OrderTrackingLoaded) return;
    final destLat = current.order.deliveryLat;
    final destLng = current.order.deliveryLng;
    if (destLat == null || destLng == null) return;

    final result = await _etaRepository.calculate(driverLat: event.lat, driverLng: event.lng, destLat: destLat, destLng: destLng);
    result.when(
      success: (eta) => emit(OrderTrackingLoaded(
        current.order,
        isCancelling: current.isCancelling,
        etaMinutes: eta.estimatedMinutes,
        etaDistanceKm: eta.distanceKm,
      )),
      failure: (_) {}, // stale ETA is better than a jarring error banner for a background recompute
    );
  }

  void _onStatusPushed(_OrderStatusPushed event, Emitter<OrderTrackingState> emit) {
    final current = state;
    if (current is OrderTrackingLoaded) {
      emit(OrderTrackingLoaded(current.order.copyWith(status: event.status)));
      _joinDriverRoomIfNeeded();
    }
  }

  Future<void> _onCancel(OrderTrackingCancel event, Emitter<OrderTrackingState> emit) async {
    final current = state;
    if (current is! OrderTrackingLoaded || !current.order.isCancellable || current.isCancelling) return;

    emit(OrderTrackingLoaded(current.order, isCancelling: true));
    final result = await _repository.cancel(current.order.id, reason: 'Cancelled by customer');
    result.when(
      success: (_) => emit(OrderTrackingLoaded(current.order.copyWith(status: 'cancelled'))),
      // The backend is authoritative on cancellability: by the time this
      // request lands, the restaurant may have already marked the order
      // "ready" or a driver may have picked it up, in which case the server
      // should reject it. Surface that instead of pretending it worked.
      failure: (failure) => emit(OrderTrackingLoaded(current.order, cancelError: failure.message)),
    );
  }

  @override
  Future<void> close() {
    _wsSub?.cancel();
    _wsService.disconnect();
    return super.close();
  }
}
