class FoodItemModel {
  final String id;
  final String restaurantId;
  final String name;
  final String description;
  final double price;
  final double? discountPrice;
  final String imageUrl;
  final List<String> tags;
  final bool isAvailable;

  const FoodItemModel({
    required this.id,
    required this.restaurantId,
    required this.name,
    required this.description,
    required this.price,
    this.discountPrice,
    required this.imageUrl,
    this.tags = const [],
    this.isAvailable = true,
  });

  double get currentPrice => discountPrice ?? price;
  bool get hasDiscount => discountPrice != null && discountPrice! < price;
  int get discountPercent => hasDiscount ? (((price - discountPrice!) / price) * 100).round() : 0;

  factory FoodItemModel.fromJson(Map<String, dynamic> json, {required String restaurantId}) {
    return FoodItemModel(
      id: (json['id'] ?? '').toString(),
      restaurantId: (json['restaurant_id'] ?? restaurantId).toString(),
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      price: (json['base_price'] as num?)?.toDouble() ?? 0.0,
      discountPrice: (json['discount_price'] as num?)?.toDouble(),
      imageUrl: json['image_url'] as String? ?? '',
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? const [],
      isAvailable: json['is_active'] as bool? ?? true,
    );
  }
}
