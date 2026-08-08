import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:customer_app/data/restaurant/restaurant_repository.dart';
import 'package:customer_app/domain/models/restaurant_model.dart';
import 'package:customer_app/domain/models/food_item_model.dart';

sealed class RestaurantEvent {
  const RestaurantEvent();
}

class RestaurantLoad extends RestaurantEvent {
  final String id;
  const RestaurantLoad(this.id);
}

sealed class RestaurantState {
  const RestaurantState();
}

class RestaurantInitial extends RestaurantState {
  const RestaurantInitial();
}

class RestaurantLoading extends RestaurantState {
  const RestaurantLoading();
}

class RestaurantLoaded extends RestaurantState {
  final RestaurantModel restaurant;
  final List<FoodItemModel> menu;
  const RestaurantLoaded({required this.restaurant, required this.menu});
}

class RestaurantError extends RestaurantState {
  final String message;
  const RestaurantError(this.message);
}

@injectable
class RestaurantBloc extends Bloc<RestaurantEvent, RestaurantState> {
  final RestaurantRepository _repository;

  RestaurantBloc(this._repository) : super(const RestaurantInitial()) {
    on<RestaurantLoad>(_onLoad);
  }

  Future<void> _onLoad(RestaurantLoad event, Emitter<RestaurantState> emit) async {
    emit(const RestaurantLoading());

    final restaurantResult = await _repository.getById(event.id);
    await restaurantResult.when(
      success: (restaurant) async {
        final menuResult = await _repository.getMenu(event.id);
        menuResult.when(
          success: (menu) => emit(RestaurantLoaded(restaurant: restaurant, menu: menu)),
          failure: (failure) => emit(RestaurantError(failure.message)),
        );
      },
      failure: (failure) async => emit(RestaurantError(failure.message)),
    );
  }
}
