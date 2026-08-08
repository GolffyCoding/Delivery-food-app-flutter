import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:customer_app/data/restaurant/restaurant_repository.dart';
import 'package:customer_app/domain/mock_data.dart';
import 'package:customer_app/domain/models/category_model.dart';
import 'package:customer_app/domain/models/restaurant_model.dart';

sealed class HomeEvent {
  const HomeEvent();
}

class HomeLoad extends HomeEvent {
  const HomeLoad();
}

sealed class HomeState {
  const HomeState();
}

class HomeInitial extends HomeState {
  const HomeInitial();
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeLoaded extends HomeState {
  final List<CategoryModel> categories;
  final List<RestaurantModel> restaurants;
  // Merchant-paid/curated placement, backed by the restaurant's own
  // `is_featured` flag — a single, clearly-labeled banner strip rather than
  // interstitial popups or ads unrelated to ordering food.
  final List<RestaurantModel> featuredRestaurants;

  const HomeLoaded({required this.categories, required this.restaurants, required this.featuredRestaurants});
}

class HomeError extends HomeState {
  final String message;
  const HomeError(this.message);
}

@injectable
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final RestaurantRepository _restaurantRepository;

  HomeBloc(this._restaurantRepository) : super(const HomeInitial()) {
    on<HomeLoad>(_onLoad);
  }

  Future<void> _onLoad(HomeLoad event, Emitter<HomeState> emit) async {
    emit(const HomeLoading());

    final results = await Future.wait([_restaurantRepository.getRestaurants(), _restaurantRepository.getFeatured()]);
    final restaurantsResult = results[0];
    final featuredResult = results[1];

    restaurantsResult.when(
      success: (restaurants) => emit(HomeLoaded(
        // The backend has no global "food category" endpoint, only per-restaurant
        // menu categories — these chips stay decorative until that exists.
        categories: MockData.categories,
        restaurants: restaurants,
        featuredRestaurants: featuredResult.when(success: (f) => f, failure: (_) => const []),
      )),
      failure: (failure) => emit(HomeError(failure.message)),
    );
  }
}
