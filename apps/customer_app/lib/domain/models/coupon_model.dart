class CouponModel {
  final String id;
  final String code;
  final String discountType; // 'fixed' | 'percentage'
  final double discountValue;
  final double minPurchase;
  final double maxDiscount;
  final DateTime expiresAt;

  const CouponModel({
    required this.id,
    required this.code,
    required this.discountType,
    required this.discountValue,
    this.minPurchase = 0,
    this.maxDiscount = 0,
    required this.expiresAt,
  });

  String get summary => discountType == 'percentage'
      ? '${discountValue.toStringAsFixed(0)}% off${maxDiscount > 0 ? ' (up to \$${maxDiscount.toStringAsFixed(0)})' : ''}'
      : '\$${discountValue.toStringAsFixed(0)} off';

  factory CouponModel.fromJson(Map<String, dynamic> json) => CouponModel(
        id: (json['id'] ?? '').toString(),
        code: json['code'] as String? ?? '',
        discountType: json['discount_type'] as String? ?? 'fixed',
        discountValue: (json['discount_value'] as num?)?.toDouble() ?? 0,
        minPurchase: (json['min_purchase'] as num?)?.toDouble() ?? 0,
        maxDiscount: (json['max_discount'] as num?)?.toDouble() ?? 0,
        expiresAt: json['expires_at'] != null ? DateTime.tryParse(json['expires_at'] as String) ?? DateTime.now() : DateTime.now(),
      );
}

/// Mirrors the backend's `PreviewResult` — importantly it always carries
/// [minPurchase], even when [eligible] is false, so the UI can say exactly
/// why a code doesn't apply yet ("add $8 more") instead of a bare rejection
/// discovered only at checkout.
class CouponPreview {
  final String code;
  final bool eligible;
  final double discount;
  final double minPurchase;
  final String? reason;

  const CouponPreview({
    required this.code,
    required this.eligible,
    this.discount = 0,
    this.minPurchase = 0,
    this.reason,
  });

  factory CouponPreview.fromJson(Map<String, dynamic> json) => CouponPreview(
        code: json['code'] as String? ?? '',
        eligible: json['eligible'] as bool? ?? false,
        discount: (json['discount'] as num?)?.toDouble() ?? 0,
        minPurchase: (json['min_purchase'] as num?)?.toDouble() ?? 0,
        reason: json['reason'] as String?,
      );
}
