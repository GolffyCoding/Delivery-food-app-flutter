import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:merchant_app/data/merchant_restaurant_datasource.dart';

sealed class RestaurantSessionEvent {}

class CheckRestaurant extends RestaurantSessionEvent {}

class ToggleOpenStatus extends RestaurantSessionEvent {}

class CreateRestaurant extends RestaurantSessionEvent {
  final String name;
  final String cuisine;
  final String phone;
  final String address;
  final double latitude;
  final double longitude;
  CreateRestaurant({
    required this.name,
    required this.cuisine,
    required this.phone,
    required this.address,
    required this.latitude,
    required this.longitude,
  });
}

sealed class RestaurantSessionState {}

class RestaurantSessionLoading extends RestaurantSessionState {}

class RestaurantSessionNeedsSetup extends RestaurantSessionState {}

class RestaurantSessionCreating extends RestaurantSessionState {}

class RestaurantSessionReady extends RestaurantSessionState {
  final String restaurantId;
  final String name;
  final bool isOpen;
  final bool isTogglingOpen;
  RestaurantSessionReady(this.restaurantId, this.name, {this.isOpen = true, this.isTogglingOpen = false});

  RestaurantSessionReady copyWith({bool? isOpen, bool? isTogglingOpen}) => RestaurantSessionReady(
        restaurantId,
        name,
        isOpen: isOpen ?? this.isOpen,
        isTogglingOpen: isTogglingOpen ?? this.isTogglingOpen,
      );
}

class RestaurantSessionError extends RestaurantSessionState {
  final String message;
  RestaurantSessionError(this.message);
}

/// Every weekday open 09:00-21:00 — a placeholder until the merchant app
/// grows a real opening-hours editor. The backend requires all 7 days
/// (`day_of_week` 1-7) to be present on restaurant creation.
final _standardOpeningHours = [
  for (var day = 1; day <= 7; day++) {'day_of_week': day, 'open_time': '09:00', 'close_time': '21:00', 'is_closed': false},
];

class RestaurantSessionBloc extends Bloc<RestaurantSessionEvent, RestaurantSessionState> {
  final MerchantRestaurantDatasource _datasource;

  RestaurantSessionBloc(this._datasource) : super(RestaurantSessionLoading()) {
    on<CheckRestaurant>(_onCheck);
    on<CreateRestaurant>(_onCreate);
    on<ToggleOpenStatus>(_onToggleOpen);
  }

  Future<void> _onCheck(CheckRestaurant event, Emitter<RestaurantSessionState> emit) async {
    emit(RestaurantSessionLoading());
    try {
      final json = await _datasource.getMyRestaurant();
      if (json == null || json['id'] == null) {
        emit(RestaurantSessionNeedsSetup());
      } else {
        emit(RestaurantSessionReady(
          json['id'].toString(),
          json['name'] as String? ?? 'My Restaurant',
          isOpen: (json['status'] as String? ?? 'active') == 'active',
        ));
      }
    } catch (_) {
      emit(RestaurantSessionNeedsSetup());
    }
  }

  // Customers must not be able to place orders against a merchant who has
  // deliberately closed for the day — this is the toggle that backs that
  // guarantee. It's optimistic-but-reverting: if the PUT fails, flip back
  // rather than leave the UI claiming a status the backend never accepted.
  Future<void> _onToggleOpen(ToggleOpenStatus event, Emitter<RestaurantSessionState> emit) async {
    final current = state;
    if (current is! RestaurantSessionReady || current.isTogglingOpen) return;

    final target = !current.isOpen;
    emit(current.copyWith(isOpen: target, isTogglingOpen: true));
    try {
      await _datasource.update(current.restaurantId, {'status': target ? 'active' : 'inactive'});
      emit((state as RestaurantSessionReady).copyWith(isTogglingOpen: false));
    } catch (_) {
      emit((state as RestaurantSessionReady).copyWith(isOpen: !target, isTogglingOpen: false));
    }
  }

  Future<void> _onCreate(CreateRestaurant event, Emitter<RestaurantSessionState> emit) async {
    emit(RestaurantSessionCreating());
    try {
      final json = await _datasource.create(
        name: event.name,
        cuisineTypes: [event.cuisine.toLowerCase()],
        phone: event.phone,
        address: event.address,
        latitude: event.latitude,
        longitude: event.longitude,
        deliveryRadiusKm: 5,
        openingHours: _standardOpeningHours,
      );
      emit(RestaurantSessionReady(json['id'].toString(), json['name'] as String? ?? event.name));
    } catch (e) {
      emit(RestaurantSessionError(e.toString()));
    }
  }
}
