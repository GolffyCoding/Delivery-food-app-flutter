class OrderItemModel {
  final String name;
  final int quantity;
  final double price;

  const OrderItemModel({required this.name, required this.quantity, required this.price});

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      name: json['name'] as String? ?? '',
      quantity: json['quantity'] as int? ?? 1,
      price: (json['unit_price'] as num?)?.toDouble() ?? (json['price'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

/// Mirrors the backend's order status flow:
/// pending -> accepted -> preparing -> ready -> picked_up -> delivering ->
/// delivered -> completed (or cancelled during pending/accepted/preparing).
class OrderModel {
  final String id;
  final String orderNumber;
  final String restaurantId;
  final String restaurantName;
  final String restaurantImage;
  final String? driverId;
  final double? deliveryLat;
  final double? deliveryLng;
  final double subtotal;
  final double deliveryFee;
  final double total;
  final String status;
  final DateTime createdAt;
  final List<OrderItemModel> items;

  const OrderModel({
    required this.id,
    this.orderNumber = '',
    this.restaurantId = '',
    required this.restaurantName,
    required this.restaurantImage,
    this.driverId,
    this.deliveryLat,
    this.deliveryLng,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    required this.status,
    required this.createdAt,
    this.items = const [],
  });

  // Matches the backend's own gate (Review.OrderID is unique): only a
  // delivered/completed order can be rated at all.
  bool get isReviewable => const ['delivered', 'completed'].contains(status);

  // Once a rider has picked up the food, self-service cancellation is no
  // longer offered — same rule real delivery apps use, since the merchant
  // and driver have already committed real-world effort/cost by that point.
  // Cancelling a picked-up order still exists as a workflow (see
  // packages/state_machine's PickedUp/Delivering -> Cancelled transitions),
  // but it's support/driver-initiated, not a customer self-service button.
  bool get isCancellable => const ['pending', 'accepted', 'preparing', 'ready'].contains(status);

  String get statusLabel => switch (status) {
        'pending' => 'Order Placed',
        'accepted' => 'Accepted',
        'preparing' => 'Preparing',
        'ready' => 'Ready for Pickup',
        'picked_up' => 'Picked Up',
        'delivering' => 'On the way',
        'delivered' => 'Delivered',
        'completed' => 'Completed',
        'cancelled' => 'Cancelled',
        _ => status,
      };

  OrderModel copyWith({String? status}) {
    return OrderModel(
      id: id,
      orderNumber: orderNumber,
      restaurantId: restaurantId,
      restaurantName: restaurantName,
      restaurantImage: restaurantImage,
      driverId: driverId,
      deliveryLat: deliveryLat,
      deliveryLng: deliveryLng,
      subtotal: subtotal,
      deliveryFee: deliveryFee,
      total: total,
      status: status ?? this.status,
      createdAt: createdAt,
      items: items,
    );
  }

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: (json['id'] ?? '').toString(),
      orderNumber: json['order_number'] as String? ?? json['number'] as String? ?? '',
      restaurantId: (json['restaurant_id'] ?? json['restaurant']?['id'] ?? '').toString(),
      restaurantName: json['restaurant_name'] as String? ?? json['restaurant']?['name'] as String? ?? 'Restaurant',
      restaurantImage: json['restaurant_image'] as String? ?? json['restaurant']?['image_url'] as String? ?? '',
      driverId: json['driver_id']?.toString(),
      deliveryLat: (json['delivery_lat'] as num?)?.toDouble(),
      deliveryLng: (json['delivery_lng'] as num?)?.toDouble(),
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      deliveryFee: (json['delivery_fee'] as num?)?.toDouble() ?? 0.0,
      total: (json['total'] as num?)?.toDouble() ?? (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? 'pending',
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : DateTime.now(),
      items: (json['items'] as List<dynamic>?)?.map((e) => OrderItemModel.fromJson(e as Map<String, dynamic>)).toList() ?? const [],
    );
  }
}
