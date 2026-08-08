import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:opendelivery_core/opendelivery_core.dart';
import 'package:opendelivery_design_system/opendelivery_design_system.dart';
import 'package:opendelivery_shared_widgets/opendelivery_shared_widgets.dart';
import 'package:customer_app/data/restaurant/restaurant_repository.dart';
import 'package:customer_app/di/injection.dart';
import 'package:customer_app/domain/models/restaurant_model.dart';
import 'package:customer_app/features/home/presentation/pages/restaurant_detail_page.dart';
import 'package:customer_app/features/home/presentation/widgets/restaurant_card.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});
  static const String route = '/search';

  @override
  State<SearchPage> createState() => _SearchPageState();
}

enum _FeeFilter {
  any('Any fee', null),
  free('Free delivery', 0),
  under2('Under \$2', 2),
  under5('Under \$5', 5);

  const _FeeFilter(this.label, this.maxFee);
  final String label;
  final double? maxFee;

  bool matches(RestaurantModel r) => maxFee == null || r.deliveryFee <= maxFee!;
}

class _SearchPageState extends State<SearchPage> {
  final _debouncer = Debouncer(delay: const Duration(milliseconds: AppConstants.searchDebounceMs));
  List<RestaurantModel>? _results;
  bool _isLoading = false;
  _FeeFilter _feeFilter = _FeeFilter.any;
  bool _openOnly = false;

  // Filtering happens client-side against the exact list already shown, on
  // purpose: a real, widely-upvoted complaint about the app this project is
  // modeled on is a delivery-fee filter whose results didn't actually match
  // the range selected. Deriving the visible list straight from the filter
  // predicate makes that mismatch structurally impossible here.
  List<RestaurantModel> get _filteredResults {
    final results = _results;
    if (results == null) return const [];
    return results.where((r) => _feeFilter.matches(r) && (!_openOnly || r.isOpen)).toList();
  }

  void _onQueryChanged(String query) {
    if (query.trim().length < AppConstants.minSearchQueryLength) {
      setState(() => _results = null);
      return;
    }
    _debouncer.run(() async {
      setState(() => _isLoading = true);
      final result = await getIt<RestaurantRepository>().search(query.trim());
      if (!mounted) return;
      result.when(
        success: (restaurants) => setState(() {
          _results = restaurants;
          _isLoading = false;
        }),
        failure: (failure) {
          setState(() => _isLoading = false);
          context.showSnackBar(failure.message, isError: true);
        },
      );
    });
  }

  @override
  void dispose() {
    _debouncer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppTextField(
          hint: 'Search restaurants or dishes...',
          autoFocus: true,
          showClearButton: true,
          onChanged: _onQueryChanged,
        ),
      ),
      body: _isLoading
          ? const AppLoadingIndicator()
          : _results == null
              ? const EmptyStateView(icon: Icons.search_rounded, title: 'Search for a restaurant', subtitle: 'Try a name or a dish')
              : Column(
                  children: [
                    _buildFilterBar(),
                    Expanded(
                      child: _filteredResults.isEmpty
                          ? const EmptyStateView(icon: Icons.search_off_rounded, title: 'No results found')
                          : ListView.builder(
                              padding: const EdgeInsets.only(top: AppSpacing.md),
                              itemCount: _filteredResults.length,
                              itemBuilder: (context, index) {
                                final r = _filteredResults[index];
                                return RestaurantCard(
                                  restaurant: r,
                                  margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
                                  onTap: () => context.push('${RestaurantDetailPage.route}/${r.id}'),
                                );
                              },
                            ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildFilterBar() {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
        children: [
          for (final filter in _FeeFilter.values)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: ChoiceChip(
                label: Text(filter.label),
                selected: _feeFilter == filter,
                onSelected: (_) => setState(() => _feeFilter = filter),
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: FilterChip(
              label: const Text('Open now'),
              selected: _openOnly,
              onSelected: (value) => setState(() => _openOnly = value),
            ),
          ),
        ],
      ),
    );
  }
}
