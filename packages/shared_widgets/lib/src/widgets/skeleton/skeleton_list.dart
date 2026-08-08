import 'package:flutter/material.dart';
import 'package:opendelivery_shared_widgets/opendelivery_shared_widgets.dart';

/// Generates a list of skeleton cards for loading states.
class SkeletonList extends StatelessWidget {
  final int itemCount;
  final Widget Function(BuildContext, int) skeletonBuilder;

  const SkeletonList({super.key, this.itemCount = 6, required this.skeletonBuilder});

  factory SkeletonList.restaurant({Key? key, int count = 6}) {
    return SkeletonList(key: key, itemCount: count, skeletonBuilder: (_, __) => const SkeletonRestaurantCard());
  }

  factory SkeletonList.food({Key? key, int count = 6}) {
    return SkeletonList(key: key, itemCount: count, skeletonBuilder: (_, __) => const SkeletonFoodCard());
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: itemCount,
      itemBuilder: skeletonBuilder,
    );
  }
}
