import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:customer_app/domain/models/cart_item_model.dart';
import 'package:customer_app/domain/models/food_item_model.dart';

sealed class CartEvent {
  const CartEvent();
}

class CartLoad extends CartEvent {
  const CartLoad();
}

class CartAddItem extends CartEvent {
  final FoodItemModel food;
  const CartAddItem(this.food);
}

class CartRemoveItem extends CartEvent {
  final String foodId;
  const CartRemoveItem(this.foodId);
}

class CartUpdateQuantity extends CartEvent {
  final String foodId;
  final int quantity;
  const CartUpdateQuantity(this.foodId, this.quantity);
}

class CartClear extends CartEvent {
  const CartClear();
}

class CartLoaded {
  final List<CartItemModel> items;
  const CartLoaded({this.items = const []});

  double get subtotal => items.fold(0, (sum, item) => sum + item.subtotal);
  double get deliveryFee => items.isEmpty ? 0.0 : 3.99;
  double get total => subtotal + deliveryFee;
  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);
}

@injectable
class CartBloc extends Bloc<CartEvent, CartLoaded> {
  CartBloc() : super(const CartLoaded()) {
    on<CartLoad>((event, emit) => emit(const CartLoaded()));
    on<CartAddItem>(_onAddItem);
    on<CartRemoveItem>(_onRemoveItem);
    on<CartUpdateQuantity>(_onUpdateQuantity);
    on<CartClear>((event, emit) => emit(const CartLoaded()));
  }

  void _onAddItem(CartAddItem event, Emitter<CartLoaded> emit) {
    final currentItems = state.items;
    final index = currentItems.indexWhere((item) => item.food.id == event.food.id);

    List<CartItemModel> newItems;
    if (index >= 0) {
      newItems = List.from(currentItems);
      newItems[index] = newItems[index].copyWith(quantity: newItems[index].quantity + 1);
    } else {
      newItems = [...currentItems, CartItemModel(food: event.food, quantity: 1)];
    }
    emit(CartLoaded(items: newItems));
  }

  void _onRemoveItem(CartRemoveItem event, Emitter<CartLoaded> emit) {
    final newItems = state.items.where((item) => item.food.id != event.foodId).toList();
    emit(CartLoaded(items: newItems));
  }

  void _onUpdateQuantity(CartUpdateQuantity event, Emitter<CartLoaded> emit) {
    if (event.quantity <= 0) {
      add(CartRemoveItem(event.foodId));
      return;
    }
    final newItems = state.items.map((item) {
      return item.food.id == event.foodId ? item.copyWith(quantity: event.quantity) : item;
    }).toList();
    emit(CartLoaded(items: newItems));
  }
}
