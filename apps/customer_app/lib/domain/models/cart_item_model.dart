import 'package:customer_app/domain/models/food_item_model.dart';

class CartItemModel {
  final FoodItemModel food;
  final int quantity;

  const CartItemModel({required this.food, required this.quantity});

  double get subtotal => food.currentPrice * quantity;

  CartItemModel copyWith({FoodItemModel? food, int? quantity}) {
    return CartItemModel(food: food ?? this.food, quantity: quantity ?? this.quantity);
  }
}
