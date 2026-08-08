import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opendelivery_network/opendelivery_network.dart';
import 'package:opendelivery_core/opendelivery_core.dart';
import 'package:driver_app/data/driver_repository.dart';

sealed class DriverOnlineEvent {}

class ToggleOnline extends DriverOnlineEvent {}

class OrderReceived extends DriverOnlineEvent {
  final Map<String, dynamic> data;
  OrderReceived(this.data);
}

class DriverOnlineState {
  final bool isOnline;
  final bool isBusy;
  final Map<String, dynamic>? incomingOrder;
  const DriverOnlineState({this.isOnline = false, this.isBusy = false, this.incomingOrder});

  DriverOnlineState copyWith({bool? isOnline, bool? isBusy, Map<String, dynamic>? incomingOrder}) {
    return DriverOnlineState(isOnline: isOnline ?? this.isOnline, isBusy: isBusy ?? this.isBusy, incomingOrder: incomingOrder);
  }
}

class DriverOnlineBloc extends Bloc<DriverOnlineEvent, DriverOnlineState> {
  final WebSocketService _wsService;
  final DriverRepository _driverRepository;
  final SecureStorageService _secureStorage;
  StreamSubscription? _wsSub;
  Timer? _locationTimer;

  DriverOnlineBloc(this._wsService, this._driverRepository, this._secureStorage) : super(const DriverOnlineState()) {
    on<ToggleOnline>(_onToggle);
    on<OrderReceived>(_onOrderReceived);
  }

  Future<void> _onToggle(ToggleOnline event, Emitter<DriverOnlineState> emit) async {
    if (state.isBusy) return;
    emit(state.copyWith(isBusy: true));

    final goingOnline = !state.isOnline;
    final result = goingOnline ? await _driverRepository.goOnline() : await _driverRepository.goOffline();

    result.when(
      success: (_) {
        emit(state.copyWith(isOnline: goingOnline, isBusy: false));
        if (goingOnline) {
          unawaited(_connectRealtime());
          _locationTimer = Timer.periodic(const Duration(seconds: 12), (_) => _pingLocation());
        } else {
          _teardownRealtime();
        }
      },
      failure: (failure) {
        AppLogger.error('Failed to toggle online status', error: failure.message, tag: 'DriverOnline');
        emit(state.copyWith(isBusy: false));
      },
    );
  }

  Future<void> _connectRealtime() async {
    final token = await _secureStorage.get(StorageConstants.accessTokenKey);
    final driverId = await _secureStorage.get(StorageConstants.userIdKey);
    await _wsService.connect('${ApiConstants.wsBaseUrl}${ApiConstants.ws}', token: token);
    if (driverId != null) _wsService.joinRoom('driver:$driverId');
    _wsSub = _wsService.messages.listen((msg) {
      if (msg['type'] == 'notification' && msg['event'] == 'order.created') {
        add(OrderReceived(msg['payload'] as Map<String, dynamic>? ?? const {}));
      }
    });
  }

  Future<void> _pingLocation() async {
    // NOTE: wire this to a real GPS stream (see packages/location) once the
    // app requests location permission — sending a fixed point for now.
    await _driverRepository.sendLocation(latitude: 13.7563, longitude: 100.5018);
  }

  void _teardownRealtime() {
    _locationTimer?.cancel();
    _locationTimer = null;
    _wsSub?.cancel();
    _wsService.disconnect();
  }

  Future<void> _onOrderReceived(OrderReceived event, Emitter<DriverOnlineState> emit) async {
    AppLogger.info('New order received: ${event.data['order_id']}', tag: 'DriverOnline');
    emit(state.copyWith(incomingOrder: event.data));
  }

  @override
  Future<void> close() {
    _teardownRealtime();
    return super.close();
  }
}
