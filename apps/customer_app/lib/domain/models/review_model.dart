class ReviewModel {
  final String id;
  final String userId;
  final String orderId;
  final String restaurantId;
  final String? driverId;
  final int rating;
  final String comment;
  final List<String> photoUrls;
  final String restaurantReply;
  final DateTime createdAt;

  const ReviewModel({
    required this.id,
    required this.userId,
    required this.orderId,
    required this.restaurantId,
    this.driverId,
    required this.rating,
    this.comment = '',
    this.photoUrls = const [],
    this.restaurantReply = '',
    required this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) => ReviewModel(
        id: (json['id'] ?? '').toString(),
        userId: (json['user_id'] ?? '').toString(),
        orderId: (json['order_id'] ?? '').toString(),
        restaurantId: (json['restaurant_id'] ?? '').toString(),
        driverId: json['driver_id']?.toString(),
        rating: (json['rating'] as num?)?.toInt() ?? 0,
        comment: json['comment'] as String? ?? '',
        photoUrls: (json['photo_urls'] as List<dynamic>?)?.cast<String>() ?? const [],
        restaurantReply: json['restaurant_reply'] as String? ?? '',
        createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now() : DateTime.now(),
      );
}

class RatingSummaryModel {
  final double average;
  final int count;
  final Map<int, int> distribution;

  const RatingSummaryModel({this.average = 0, this.count = 0, this.distribution = const {}});

  factory RatingSummaryModel.fromJson(Map<String, dynamic> json) {
    final rawDistribution = json['distribution'] as Map<String, dynamic>? ?? const {};
    return RatingSummaryModel(
      average: (json['average'] as num?)?.toDouble() ?? 0,
      count: (json['count'] as num?)?.toInt() ?? 0,
      distribution: rawDistribution.map((k, v) => MapEntry(int.parse(k), (v as num).toInt())),
    );
  }
}
