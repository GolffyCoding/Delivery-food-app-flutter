import 'package:flutter/material.dart';
import 'package:opendelivery_core/opendelivery_core.dart';
import 'package:opendelivery_design_system/opendelivery_design_system.dart';
import 'package:opendelivery_shared_widgets/opendelivery_shared_widgets.dart';
import 'package:merchant_app/data/review/review_repository.dart';
import 'package:merchant_app/di/injection.dart';
import 'package:merchant_app/domain/models/review_model.dart';

class MerchantReviewsPage extends StatefulWidget {
  final String restaurantId;
  const MerchantReviewsPage({super.key, required this.restaurantId});
  static const String route = '/merchant-reviews';

  @override
  State<MerchantReviewsPage> createState() => _MerchantReviewsPageState();
}

class _MerchantReviewsPageState extends State<MerchantReviewsPage> {
  RatingSummaryModel? _summary;
  List<ReviewModel>? _reviews;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repository = getIt<ReviewRepository>();
    final summaryResult = await repository.summary(widget.restaurantId);
    final reviewsResult = await repository.listByRestaurant(widget.restaurantId);
    if (!mounted) return;
    setState(() {
      summaryResult.when(success: (s) => _summary = s, failure: (_) {});
      reviewsResult.when(success: (r) => _reviews = r, failure: (_) => _reviews = const []);
    });
  }

  Future<void> _reply(ReviewModel review) async {
    final controller = TextEditingController(text: review.restaurantReply);
    final reply = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reply to Review'),
        content: TextField(controller: controller, maxLines: 4, decoration: const InputDecoration(hintText: 'Write a reply...')),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.of(dialogContext).pop(controller.text.trim()), child: const Text('Send')),
        ],
      ),
    );
    if (reply == null || reply.isEmpty || !mounted) return;

    final result = await getIt<ReviewRepository>().reply(widget.restaurantId, review.id, reply);
    if (!mounted) return;
    result.when(
      success: (_) {
        context.showSnackBar('Reply sent');
        _load();
      },
      failure: (failure) => context.showSnackBar(failure.message, isError: true),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reviews = _reviews;
    return Scaffold(
      appBar: const AppAppBar(title: 'Customer Reviews', showBackButton: true),
      body: reviews == null
          ? const AppLoadingIndicator()
          : Column(
              children: [
                if (_summary != null && _summary!.count > 0)
                  Padding(
                    padding: AppSpacing.screenPadding,
                    child: Row(
                      children: [
                        const Icon(Icons.star_rounded, color: AppColors.starFilled),
                        const SizedBox(width: 6),
                        Text('${_summary!.average.toStringAsFixed(1)} average · ${_summary!.count} reviews', style: context.textTheme.titleSmall),
                      ],
                    ),
                  ),
                Expanded(
                  child: reviews.isEmpty
                      ? const EmptyStateView(icon: Icons.reviews_outlined, title: 'No reviews yet')
                      : ListView.builder(
                          padding: AppSpacing.screenPadding,
                          itemCount: reviews.length,
                          itemBuilder: (context, index) {
                            final review = reviews[index];
                            return AppCard(
                              margin: const EdgeInsets.only(bottom: AppSpacing.md),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  StarRating(rating: review.rating.toDouble(), size: 18),
                                  if (review.comment.isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    Text(review.comment),
                                  ],
                                  if (review.hasReply) ...[
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.all(AppSpacing.sm),
                                      decoration: BoxDecoration(color: AppColors.neutral100, borderRadius: AppRadius.smBorder),
                                      child: Text('Your reply: ${review.restaurantReply}', style: context.textTheme.bodySmall),
                                    ),
                                  ],
                                  const SizedBox(height: 8),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: AppTextButton(text: review.hasReply ? 'Edit Reply' : 'Reply', onPressed: () => _reply(review)),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
