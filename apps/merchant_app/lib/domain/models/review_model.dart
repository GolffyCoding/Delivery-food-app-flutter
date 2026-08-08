class ReviewModel {
  final String id;
  final String orderId;
  final int rating;
  final String comment;
  final String restaurantReply;
  final DateTime createdAt;

  const ReviewModel({
    required this.id,
    required this.orderId,
    required this.rating,
    this.comment = '',
    this.restaurantReply = '',
    required this.createdAt,
  });

  bool get hasReply => restaurantReply.isNotEmpty;

  factory ReviewModel.fromJson(Map<String, dynamic> json) => ReviewModel(
        id: (json['id'] ?? '').toString(),
        orderId: (json['order_id'] ?? '').toString(),
        rating: (json['rating'] as num?)?.toInt() ?? 0,
        comment: json['comment'] as String? ?? '',
        restaurantReply: json['restaurant_reply'] as String? ?? '',
        createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now() : DateTime.now(),
      );
}

class RatingSummaryModel {
  final double average;
  final int count;

  const RatingSummaryModel({this.average = 0, this.count = 0});

  factory RatingSummaryModel.fromJson(Map<String, dynamic> json) => RatingSummaryModel(
        average: (json['average'] as num?)?.toDouble() ?? 0,
        count: (json['count'] as num?)?.toInt() ?? 0,
      );
}
