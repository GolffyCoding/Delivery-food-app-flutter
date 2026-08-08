import 'package:flutter/material.dart';
import 'package:opendelivery_design_system/opendelivery_design_system.dart';

/// A single gradient promo strip (e.g. "here's a real coupon you can claim
/// right now") — deliberately not a carousel of ad slides or anything with
/// a dismiss button to fight with. One clear call to action, backed by real
/// data the caller supplies (never fabricated copy).
class AppPromoBanner extends StatelessWidget {
  final String title;
  final String amount;
  final String subtitle;
  final String ctaLabel;
  final VoidCallback? onTap;
  final List<Color> gradientColors;

  const AppPromoBanner({
    super.key,
    required this.title,
    required this.amount,
    required this.subtitle,
    this.ctaLabel = 'Apply',
    this.onTap,
    this.gradientColors = const [AppColors.brandPrimary, AppColors.brandPrimaryDark],
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.lgBorder,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradientColors, begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: AppRadius.lgBorder,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Text(amount, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 11)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              decoration: BoxDecoration(color: Colors.white, borderRadius: AppRadius.mdBorder),
              child: Text(ctaLabel, style: TextStyle(color: gradientColors.first, fontSize: 12, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }
}
