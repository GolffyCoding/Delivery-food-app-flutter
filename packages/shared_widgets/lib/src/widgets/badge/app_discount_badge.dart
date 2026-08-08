import 'package:flutter/material.dart';
import 'package:opendelivery_design_system/opendelivery_design_system.dart';

/// A small "-N%" pill for discounted prices. Dynamic in size and color so
/// it reads consistently whether it's overlaid on a food card, a checkout
/// line item, or a coupon summary.
class AppDiscountBadge extends StatelessWidget {
  final int percent;
  final bool small;
  final Color background;
  final Color foreground;

  const AppDiscountBadge({
    super.key,
    required this.percent,
    this.small = false,
    this.background = AppColors.errorLight,
    this.foreground = AppColors.error,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: small ? 4 : 6, vertical: small ? 2 : 3),
      decoration: BoxDecoration(color: background, borderRadius: AppRadius.smBorder),
      child: Text(
        '-$percent%',
        style: TextStyle(fontSize: small ? 10 : 12, fontWeight: FontWeight.w700, color: foreground),
      ),
    );
  }
}
