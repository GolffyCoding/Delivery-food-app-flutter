import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:opendelivery_core/opendelivery_core.dart';
import 'package:opendelivery_design_system/opendelivery_design_system.dart';
import 'package:opendelivery_shared_widgets/opendelivery_shared_widgets.dart';
import 'package:customer_app/data/review/review_repository.dart';
import 'package:customer_app/di/injection.dart';
import 'package:customer_app/domain/models/food_item_model.dart';
import 'package:customer_app/domain/models/review_model.dart';
import 'package:customer_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:customer_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:customer_app/features/home/presentation/bloc/restaurant_bloc.dart';
import 'package:customer_app/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:customer_app/features/home/presentation/pages/food_detail_page.dart';

class RestaurantDetailPage extends StatelessWidget {
  final String restaurantId;
  const RestaurantDetailPage({super.key, required this.restaurantId});
  static const String route = '/restaurant';

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RestaurantBloc, RestaurantState>(
      builder: (context, state) {
        if (state is RestaurantLoading || state is RestaurantInitial) {
          return const Scaffold(body: AppLoadingIndicator());
        }
        if (state is RestaurantError) {
          return Scaffold(body: ErrorView(failure: UnknownFailure(message: state.message)));
        }
        final loaded = state as RestaurantLoaded;

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: AppNetworkImage(imageUrl: loaded.restaurant.imageUrl, borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16))),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: AppSpacing.screenPadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(loaded.restaurant.name, style: context.textTheme.headlineSmall),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, color: AppColors.starFilled, size: 20),
                          Text('${loaded.restaurant.rating} (${loaded.restaurant.reviewCount})', style: context.textTheme.labelLarge),
                          const SizedBox(width: AppSpacing.lg),
                          Icon(Icons.schedule_rounded, size: 18, color: context.colorScheme.outline),
                          Text('${loaded.restaurant.deliveryTime} min', style: context.textTheme.labelLarge),
                        ],
                      ),
                      const Divider(height: 32),
                      Text('Menu', style: context.textTheme.titleMedium),
                    ],
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _FoodTile(
                    food: loaded.menu[index],
                    onAdd: () => context.read<CartBloc>().add(CartAddItem(loaded.menu[index])),
                    onTap: () => context.push(FoodDetailPage.route, extra: loaded.menu[index]),
                  ),
                  childCount: loaded.menu.length,
                ),
              ),
              SliverToBoxAdapter(
                child: _ReviewsSection(
                  restaurantId: restaurantId,
                  currentUserId: switch (context.watch<AuthBloc>().state) {
                    AuthAuthenticated(:final user) => user.id,
                    _ => null,
                  },
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        );
      },
    );
  }
}

class _ReviewsSection extends StatefulWidget {
  final String restaurantId;
  final String? currentUserId;
  const _ReviewsSection({required this.restaurantId, this.currentUserId});

  @override
  State<_ReviewsSection> createState() => _ReviewsSectionState();
}

enum _ReviewSort {
  newest('Newest'),
  highest('Highest rated'),
  lowest('Lowest rated');

  const _ReviewSort(this.label);
  final String label;
}

class _ReviewsSectionState extends State<_ReviewsSection> {
  RatingSummaryModel? _summary;
  List<ReviewModel>? _reviews;
  _ReviewSort _sort = _ReviewSort.newest;
  int? _starFilter;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repository = getIt<ReviewRepository>();
    final results = await Future.wait([repository.summary(widget.restaurantId), repository.listByRestaurant(widget.restaurantId)]);
    if (!mounted) return;
    final summaryResult = results[0] as Result<RatingSummaryModel, Failure>;
    final reviewsResult = results[1] as Result<List<ReviewModel>, Failure>;
    setState(() {
      summaryResult.when(success: (s) => _summary = s, failure: (_) {});
      reviewsResult.when(success: (r) => _reviews = r, failure: (_) => _reviews = const []);
    });
  }

  // Sorted/filtered from the exact list already on screen, same reasoning as
  // the search-page fee filter: a filter chip's claim and what's actually
  // shown must never drift apart.
  List<ReviewModel> get _displayedReviews {
    final reviews = _reviews;
    if (reviews == null) return const [];
    final filtered = _starFilter == null ? reviews : reviews.where((r) => r.rating == _starFilter).toList();
    final sorted = [...filtered];
    switch (_sort) {
      case _ReviewSort.newest:
        sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      case _ReviewSort.highest:
        sorted.sort((a, b) => b.rating.compareTo(a.rating));
      case _ReviewSort.lowest:
        sorted.sort((a, b) => a.rating.compareTo(b.rating));
    }
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    final reviews = _reviews;
    if (reviews == null) {
      return const Padding(padding: EdgeInsets.symmetric(vertical: AppSpacing.xl), child: Center(child: CircularProgressIndicator()));
    }

    return Padding(
      padding: AppSpacing.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 32),
          Row(
            children: [
              Text('Reviews', style: context.textTheme.titleMedium),
              if (_summary != null && _summary!.count > 0) ...[
                const SizedBox(width: AppSpacing.sm),
                Text('${_summary!.average.toStringAsFixed(1)} (${_summary!.count})', style: context.textTheme.bodyMedium?.copyWith(color: context.colorScheme.outline)),
              ],
            ],
          ),
          if (reviews.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  PopupMenuButton<_ReviewSort>(
                    initialValue: _sort,
                    onSelected: (value) => setState(() => _sort = value),
                    itemBuilder: (context) => [for (final sort in _ReviewSort.values) PopupMenuItem(value: sort, child: Text(sort.label))],
                    child: Chip(label: Text(_sort.label), avatar: const Icon(Icons.sort_rounded, size: 16)),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  ChoiceChip(label: const Text('All'), selected: _starFilter == null, onSelected: (_) => setState(() => _starFilter = null)),
                  for (var star = 5; star >= 1; star--)
                    if ((_summary?.distribution[star] ?? 0) > 0)
                      Padding(
                        padding: const EdgeInsets.only(left: AppSpacing.sm),
                        child: ChoiceChip(
                          label: Text('$star★ (${_summary!.distribution[star]})'),
                          selected: _starFilter == star,
                          onSelected: (_) => setState(() => _starFilter = star),
                        ),
                      ),
                ],
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          if (reviews.isEmpty)
            Text('No reviews yet', style: context.textTheme.bodyMedium?.copyWith(color: context.colorScheme.outline))
          else if (_displayedReviews.isEmpty)
            Text('No reviews match this filter', style: context.textTheme.bodyMedium?.copyWith(color: context.colorScheme.outline))
          else
            for (final review in _displayedReviews) _ReviewTile(review: review, isOwn: review.userId == widget.currentUserId),
        ],
      ),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  final ReviewModel review;
  final bool isOwn;
  const _ReviewTile({required this.review, this.isOwn = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              StarRating(rating: review.rating.toDouble(), size: 16),
              if (isOwn) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: AppColors.brandAccent, borderRadius: AppRadius.smBorder),
                  child: const Text('Your review', style: TextStyle(fontSize: 11, color: AppColors.brandPrimary)),
                ),
              ],
            ],
          ),
          if (review.comment.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(review.comment, style: context.textTheme.bodyMedium),
          ],
          if (review.restaurantReply.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(color: AppColors.neutral100, borderRadius: AppRadius.smBorder),
              child: Text('Reply from restaurant: ${review.restaurantReply}', style: context.textTheme.bodySmall),
            ),
          ],
          const Divider(height: 24),
        ],
      ),
    );
  }
}

class _FoodTile extends StatelessWidget {
  final FoodItemModel food;
  final VoidCallback onAdd;
  final VoidCallback onTap;

  const _FoodTile({required this.food, required this.onAdd, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(food.name, style: context.textTheme.titleSmall),
                  const SizedBox(height: 4),
                  Text(food.description, style: context.textTheme.bodySmall?.copyWith(color: context.colorScheme.outline), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: AppSpacing.sm),
                  if (food.tags.isNotEmpty) Wrap(spacing: 6, children: food.tags.map((t) => AppBadge(label: t)).toList()),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      if (food.hasDiscount) ...[
                        Text('\$${food.price.toStringAsFixed(2)}', style: context.textTheme.bodySmall?.copyWith(decoration: TextDecoration.lineThrough, color: context.colorScheme.outline)),
                        const SizedBox(width: 6),
                      ],
                      Text('\$${food.currentPrice.toStringAsFixed(2)}', style: context.textTheme.titleSmall?.copyWith(color: AppColors.brandPrimary, fontWeight: FontWeight.bold)),
                      if (food.hasDiscount) ...[
                        const SizedBox(width: 6),
                        AppDiscountBadge(percent: food.discountPercent, small: true),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Stack(
              clipBehavior: Clip.none,
              children: [
                AppNetworkImage(imageUrl: food.imageUrl, width: 90, height: 90, borderRadius: AppRadius.mdBorder),
                Positioned(
                  bottom: -8,
                  right: -8,
                  child: Material(
                    color: context.colorScheme.primary,
                    borderRadius: AppRadius.fullBorder,
                    child: InkWell(
                      onTap: onAdd,
                      borderRadius: AppRadius.fullBorder,
                      child: const Padding(padding: EdgeInsets.all(8), child: Icon(Icons.add, color: Colors.white, size: 20)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
