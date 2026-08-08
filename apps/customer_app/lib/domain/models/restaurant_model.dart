class RestaurantModel {
  final String id;
  final String name;
  final String imageUrl;
  final String cuisine;
  final double rating;
  final int reviewCount;
  final String deliveryTime;
  final double deliveryFee;
  final bool isOpen;

  const RestaurantModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.cuisine,
    required this.rating,
    required this.reviewCount,
    required this.deliveryTime,
    required this.deliveryFee,
    this.isOpen = true,
  });

  factory RestaurantModel.fromJson(Map<String, dynamic> json) {
    final cuisineTypes = (json['cuisine_types'] as List<dynamic>?)?.cast<String>() ?? const [];
    return RestaurantModel(
      id: (json['id'] ?? '').toString(),
      name: json['name'] as String? ?? 'Restaurant',
      imageUrl: json['logo_url'] as String? ?? json['cover_image_url'] as String? ?? '',
      cuisine: cuisineTypes.isNotEmpty ? cuisineTypes.join(', ') : '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['rating_count'] as int? ?? 0,
      // The backend doesn't return an ETA estimate on the restaurant object
      // itself (only `/tracking/eta` given two coordinates), so this stays
      // a placeholder until that's wired up per-restaurant.
      deliveryTime: '20-30',
      deliveryFee: (json['delivery_fee'] as num?)?.toDouble() ?? 0.0,
      isOpen: (json['status'] as String? ?? 'active') == 'active',
    );
  }
}
