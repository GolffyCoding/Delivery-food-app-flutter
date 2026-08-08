import 'package:customer_app/domain/models/category_model.dart';
import 'package:customer_app/domain/models/restaurant_model.dart';
import 'package:customer_app/domain/models/food_item_model.dart';
import 'package:customer_app/domain/models/order_model.dart';

final class MockData {
  const MockData._();

  static const String placeholderImg = 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=800&q=80';
  static const String foodImg1 = 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=800&q=80';
  static const String foodImg2 = 'https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?w=800&q=80';
  static const String foodImg3 = 'https://images.unsplash.com/photo-1540189549336-e6e99c3679fe?w=800&q=80';

  static const List<CategoryModel> categories = [
    CategoryModel(id: '1', name: 'Pizza', imageUrl: 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=200&q=60'),
    CategoryModel(id: '2', name: 'Burgers', imageUrl: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=200&q=60'),
    CategoryModel(id: '3', name: 'Sushi', imageUrl: 'https://images.unsplash.com/photo-1579584425555-c3ce17fd4351?w=200&q=60'),
    CategoryModel(id: '4', name: 'Salads', imageUrl: 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=200&q=60'),
    CategoryModel(id: '5', name: 'Desserts', imageUrl: 'https://images.unsplash.com/photo-1551024601-bec78aea704b?w=200&q=60'),
    CategoryModel(id: '6', name: 'Drinks', imageUrl: 'https://images.unsplash.com/photo-1544145945-f90425340c7e?w=200&q=60'),
  ];

  static const List<RestaurantModel> restaurants = [
    RestaurantModel(id: 'r1', name: 'Bella Italia', imageUrl: placeholderImg, cuisine: 'Italian', rating: 4.8, reviewCount: 324, deliveryTime: '20-30', deliveryFee: 2.99),
    RestaurantModel(id: 'r2', name: 'Tokyo Ramen House', imageUrl: 'https://images.unsplash.com/photo-1557872943-16a5ac26437e?w=800&q=80', cuisine: 'Japanese', rating: 4.6, reviewCount: 218, deliveryTime: '25-35', deliveryFee: 3.49),
    RestaurantModel(id: 'r3', name: 'Green Bowl', imageUrl: 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=800&q=80', cuisine: 'Healthy', rating: 4.9, reviewCount: 502, deliveryTime: '15-25', deliveryFee: 1.99),
    RestaurantModel(id: 'r4', name: 'Smokehouse BBQ', imageUrl: 'https://images.unsplash.com/photo-1544025162-d76694265947?w=800&q=80', cuisine: 'American', rating: 4.5, reviewCount: 189, deliveryTime: '30-40', deliveryFee: 0.0),
  ];

  static List<FoodItemModel> getMenu(String restaurantId) {
    return [
      FoodItemModel(id: 'f1', restaurantId: restaurantId, name: 'Margherita Pizza', description: 'Fresh mozzarella, tomato sauce, basil', price: 12.99, discountPrice: 10.99, imageUrl: foodImg1, tags: const ['Popular', 'Vegetarian']),
      FoodItemModel(id: 'f2', restaurantId: restaurantId, name: 'Pepperoni Pizza', description: 'Classic pepperoni with mozzarella', price: 14.99, imageUrl: foodImg2, tags: const ['Popular']),
      FoodItemModel(id: 'f3', restaurantId: restaurantId, name: 'Caesar Salad', description: 'Romaine lettuce, croutons, parmesan', price: 8.99, imageUrl: foodImg3, tags: const ['Healthy']),
      FoodItemModel(id: 'f4', restaurantId: restaurantId, name: 'Tiramisu', description: 'Classic Italian dessert with mascarpone', price: 7.99, imageUrl: 'https://images.unsplash.com/photo-1571877227200-a0d98ea607e9?w=800&q=80', tags: const ['Dessert']),
    ];
  }

  static List<OrderModel> orders = [
    OrderModel(
      id: 'o1',
      restaurantName: 'Bella Italia',
      restaurantImage: placeholderImg,
      subtotal: 23.98,
      deliveryFee: 2.99,
      total: 26.97,
      status: 'Delivered',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      items: const [OrderItemModel(name: 'Margherita Pizza', quantity: 2, price: 11.99)],
    ),
    OrderModel(
      id: 'o2',
      restaurantName: 'Green Bowl',
      restaurantImage: 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=800&q=80',
      subtotal: 15.50,
      deliveryFee: 1.99,
      total: 17.49,
      status: 'On the way',
      createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
      items: const [
        OrderItemModel(name: 'Caesar Salad', quantity: 1, price: 8.99),
        OrderItemModel(name: 'Smoothie', quantity: 1, price: 6.51),
      ],
    ),
  ];
}
