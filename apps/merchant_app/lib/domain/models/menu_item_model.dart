import 'package:equatable/equatable.dart';

class MenuItemModel extends Equatable {
  final String id;
  final String name;
  final String description;
  final double price;
  final String category;
  final String imageUrl;
  final bool isAvailable;
  final int stockCount;

  const MenuItemModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    this.imageUrl = '',
    this.isAvailable = true,
    this.stockCount = 100,
  });

  bool get isLowStock => stockCount <= 5 && stockCount > 0;
  bool get isOutOfStock => stockCount <= 0;

  MenuItemModel copyWith({String? name, String? description, double? price, bool? isAvailable, int? stockCount}) {
    return MenuItemModel(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      category: category,
      imageUrl: imageUrl,
      isAvailable: isAvailable ?? this.isAvailable,
      stockCount: stockCount ?? this.stockCount,
    );
  }

  @override
  List<Object?> get props => [id, name, price, isAvailable, stockCount];
}
