import 'package:flutter/material.dart';
import 'package:opendelivery_design_system/opendelivery_design_system.dart';

/// Star rating display widget.
class StarRating extends StatelessWidget {
  final double rating;
  final int reviewCount;
  final double size;
  final VoidCallback? onTap;

  const StarRating({super.key, required this.rating, this.reviewCount = 0, this.size = 16, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(5, (index) {
              if (index < rating.floor()) {
                return Icon(Icons.star_rounded, color: AppColors.starFilled, size: size);
              } else if (index < rating) {
                return Icon(Icons.star_half_rounded, color: AppColors.starFilled, size: size);
              } else {
                return Icon(Icons.star_rounded, color: AppColors.starEmpty, size: size);
              }
            }),
          ),
          if (reviewCount > 0) ...[
            const SizedBox(width: 4),
            Text(
              '($reviewCount)',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.outline),
            ),
          ],
        ],
      ),
    );
  }
}
