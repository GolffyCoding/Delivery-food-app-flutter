import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:opendelivery_core/opendelivery_core.dart';
import 'package:opendelivery_design_system/opendelivery_design_system.dart';
import 'package:opendelivery_shared_widgets/opendelivery_shared_widgets.dart';
import 'package:customer_app/data/coupon/coupon_repository.dart';
import 'package:customer_app/data/notifications/notification_repository.dart';
import 'package:customer_app/di/injection.dart';
import 'package:customer_app/domain/models/category_model.dart';
import 'package:customer_app/domain/models/coupon_model.dart';
import 'package:customer_app/domain/models/restaurant_model.dart';
import 'package:customer_app/features/home/presentation/bloc/home_bloc.dart';
import 'package:customer_app/features/home/presentation/widgets/restaurant_card.dart';
import 'package:customer_app/features/home/presentation/pages/restaurant_detail_page.dart';
import 'package:customer_app/features/home/presentation/pages/search_page.dart';
import 'package:customer_app/features/notifications/presentation/pages/notifications_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  static const String route = '/home';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                floating: true,
                title: Row(
                  children: [
                    Icon(Icons.location_on_rounded, color: context.colorScheme.primary, size: 20),
                    const SizedBox(width: 4),
                    Expanded(child: Text('Deliver to 123 Main St', style: context.textTheme.labelLarge, overflow: TextOverflow.ellipsis)),
                    const Icon(Icons.keyboard_arrow_down_rounded),
                  ],
                ),
                actions: const [_NotificationsBellButton()],
              ),
              if (state is HomeLoading)
                const SliverFillRemaining(child: AppLoadingIndicator())
              else if (state is HomeError)
                SliverFillRemaining(
                  child: ErrorView(
                    failure: UnknownFailure(message: state.message),
                    onRetry: () => context.read<HomeBloc>().add(const HomeLoad()),
                  ),
                )
              else if (state is HomeLoaded) ...[
                SliverToBoxAdapter(child: _buildSearchBar(context)),
                if (state.featuredRestaurants.isNotEmpty) SliverToBoxAdapter(child: _buildFeaturedBanner(context, state.featuredRestaurants)),
                const SliverToBoxAdapter(child: _TopCouponBanner()),
                SliverToBoxAdapter(child: _buildCategories(context, state.categories)),
                const SliverToBoxAdapter(child: AppSectionHeader(title: 'Popular Near You')),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => RestaurantCard(
                      restaurant: state.restaurants[index],
                      onTap: () => context.push('${RestaurantDetailPage.route}/${state.restaurants[index].id}'),
                    ),
                    childCount: state.restaurants.length,
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 80)),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      child: InkWell(
        onTap: () => context.push(SearchPage.route),
        child: Container(
          padding: AppSpacing.inputPadding,
          decoration: BoxDecoration(
            color: context.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: AppRadius.mdBorder,
          ),
          child: Row(
            children: [
              Icon(Icons.search, color: context.colorScheme.outline),
              const SizedBox(width: AppSpacing.md),
              Text('Search for food or restaurants', style: context.textTheme.bodyMedium?.copyWith(color: context.colorScheme.outline)),
            ],
          ),
        ),
      ),
    );
  }

  // A single, clearly-labeled "Sponsored" strip — no popups, no dismiss
  // button to fight with, no interruption of the ordering flow. This is the
  // one merchant-promotion surface in the whole app, backed by the
  // restaurant's own `is_featured` flag (admin/merchant-controlled), not a
  // third-party ad network.
  Widget _buildFeaturedBanner(BuildContext context, List<RestaurantModel> featured) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.sm),
          child: Text('Sponsored', style: context.textTheme.labelMedium?.copyWith(color: context.colorScheme.outline)),
        ),
        SizedBox(
          height: 140,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            scrollDirection: Axis.horizontal,
            itemCount: featured.length,
            separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
            itemBuilder: (context, index) {
              final restaurant = featured[index];
              return InkWell(
                borderRadius: AppRadius.lgBorder,
                onTap: () => context.push('${RestaurantDetailPage.route}/${restaurant.id}'),
                child: Container(
                  width: 260,
                  decoration: BoxDecoration(borderRadius: AppRadius.lgBorder, color: context.colorScheme.surfaceContainerHighest),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      AppNetworkImage(imageUrl: restaurant.imageUrl, borderRadius: BorderRadius.zero),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(AppSpacing.sm),
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black87]),
                          ),
                          child: Text(restaurant.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategories(BuildContext context, List<CategoryModel> categories) {
    return SizedBox(
      height: 100,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
        itemBuilder: (context, index) {
          final cat = categories[index];
          return Column(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  borderRadius: AppRadius.lgBorder,
                  image: DecorationImage(image: NetworkImage(cat.imageUrl), fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(cat.name, style: context.textTheme.labelSmall),
            ],
          );
        },
      ),
    );
  }

}

// Shows the single best active coupon (real data from CouponRepository, not
// a made-up promo string) using the shared AppPromoBanner — nothing to
// dismiss, nothing that pops over content, just a way to notice a real
// discount exists before going to checkout.
class _TopCouponBanner extends StatefulWidget {
  const _TopCouponBanner();

  @override
  State<_TopCouponBanner> createState() => _TopCouponBannerState();
}

class _TopCouponBannerState extends State<_TopCouponBanner> {
  CouponModel? _coupon;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final result = await getIt<CouponRepository>().listActive();
    if (!mounted) return;
    result.when(
      success: (coupons) => setState(() => _coupon = coupons.isEmpty ? null : coupons.first),
      failure: (_) {},
    );
  }

  @override
  Widget build(BuildContext context) {
    final coupon = _coupon;
    if (coupon == null) return const SizedBox.shrink();
    return AppPromoBanner(
      title: 'Coupon available',
      amount: coupon.summary,
      subtitle: coupon.minPurchase > 0 ? 'On orders over \$${coupon.minPurchase.toStringAsFixed(0)} · Code: ${coupon.code}' : 'Code: ${coupon.code}',
      ctaLabel: 'Order now',
      onTap: () => context.push(SearchPage.route),
    );
  }
}

class _NotificationsBellButton extends StatefulWidget {
  const _NotificationsBellButton();

  @override
  State<_NotificationsBellButton> createState() => _NotificationsBellButtonState();
}

class _NotificationsBellButtonState extends State<_NotificationsBellButton> {
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    final result = await getIt<NotificationRepository>().unreadCount();
    if (!mounted) return;
    result.when(
      success: (count) => setState(() => _unreadCount = count),
      failure: (_) {}, // badge just stays stale on failure — not worth a snackbar
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Badge(
        label: Text('$_unreadCount'),
        isLabelVisible: _unreadCount > 0,
        child: const Icon(Icons.notifications_outlined),
      ),
      onPressed: () async {
        await context.push(NotificationsPage.route);
        _refresh();
      },
    );
  }
}
