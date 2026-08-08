import 'package:flutter/material.dart';
import 'package:opendelivery_design_system/opendelivery_design_system.dart';

/// An interactive 1-5 star picker, distinct from [StarRating] (display-only):
/// each star is independently tappable and reports the selected value, for
/// "rate your order" / "leave a review" style flows.
class StarRatingInput extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  final double size;
  final int maxStars;

  const StarRatingInput({
    super.key,
    required this.value,
    required this.onChanged,
    this.size = 32,
    this.maxStars = 5,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 1; i <= maxStars; i++)
          IconButton(
            icon: Icon(
              i <= value ? Icons.star_rounded : Icons.star_border_rounded,
              color: AppColors.starFilled,
              size: size,
            ),
            onPressed: () => onChanged(i),
          ),
      ],
    );
  }
}
