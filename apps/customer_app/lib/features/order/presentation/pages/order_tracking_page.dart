import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opendelivery_core/opendelivery_core.dart';
import 'package:opendelivery_design_system/opendelivery_design_system.dart';
import 'package:opendelivery_shared_widgets/opendelivery_shared_widgets.dart';
import 'package:customer_app/data/review/review_repository.dart';
import 'package:customer_app/di/injection.dart';
import 'package:customer_app/domain/models/order_model.dart';
import 'package:customer_app/features/order/presentation/bloc/order_tracking_bloc.dart';

class OrderTrackingPage extends StatelessWidget {
  final String orderId;
  const OrderTrackingPage({super.key, required this.orderId});
  static const String route = '/order';

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OrderTrackingBloc, OrderTrackingState>(
      listener: (context, state) {
        if (state is OrderTrackingLoaded && state.cancelError != null) {
          context.showSnackBar(state.cancelError!, isError: true);
        }
      },
      builder: (context, state) {
        if (state is! OrderTrackingLoaded) {
          return const Scaffold(body: AppLoadingIndicator());
        }
        final order = state.order;

        if (order.status == 'cancelled') {
          return Scaffold(
            appBar: const AppAppBar(title: 'Order', showBackButton: true),
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.cancel_rounded, size: 64, color: AppColors.error),
                  const SizedBox(height: AppSpacing.lg),
                  Text('Order Cancelled', style: context.textTheme.headlineSmall),
                ],
              ),
            ),
          );
        }

        // pending -> accepted -> preparing -> ready -> picked_up -> delivering -> delivered/completed
        const flow = ['pending', 'accepted', 'preparing', 'ready', 'picked_up', 'delivering', 'delivered'];
        var currentIndex = flow.indexOf(order.status);
        if (order.status == 'completed') currentIndex = flow.length - 1;

        return Scaffold(
          appBar: AppAppBar(title: order.orderNumber.isNotEmpty ? 'Order #${order.orderNumber}' : 'Order #${order.id}', showBackButton: true),
          body: Column(
            children: [
              Container(
                height: 220,
                margin: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(color: AppColors.neutral200, borderRadius: AppRadius.lgBorder),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.map_rounded, size: 48, color: context.colorScheme.outline),
                      const SizedBox(height: 8),
                      Text('Live Map Integration', style: context.textTheme.labelLarge?.copyWith(color: context.colorScheme.outline)),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(color: AppColors.infoLight, borderRadius: AppRadius.mdBorder),
                        child: Row(
                          children: [
                            const Icon(Icons.access_time_rounded, color: AppColors.info),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(child: Text(order.statusLabel, style: context.textTheme.labelLarge?.copyWith(color: AppColors.info))),
                            if (state.etaMinutes != null)
                              Text(
                                'Arriving in ~${state.etaMinutes} min',
                                style: context.textTheme.labelLarge?.copyWith(color: AppColors.info, fontWeight: FontWeight.bold),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Text('Order Status', style: context.textTheme.titleMedium),
                      const SizedBox(height: AppSpacing.lg),
                      for (var i = 0; i < flow.length; i++)
                        _TrackingStep(
                          title: _stepLabel(flow[i]),
                          subtitle: '',
                          isCompleted: currentIndex >= i,
                          isActive: currentIndex == i,
                        ),
                      if (order.isCancellable) ...[
                        AppOutlinedButton(
                          text: 'Cancel Order',
                          isLoading: state.isCancelling,
                          onPressed: () => context.read<OrderTrackingBloc>().add(const OrderTrackingCancel()),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                      ],
                      if (order.isReviewable) ...[
                        _RateOrderButton(order: order),
                        const SizedBox(height: AppSpacing.lg),
                      ],
                      const SizedBox(height: AppSpacing.xl),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _stepLabel(String status) => switch (status) {
        'pending' => 'Order Placed',
        'accepted' => 'Restaurant Accepted',
        'preparing' => 'Preparing',
        'ready' => 'Ready for Pickup',
        'picked_up' => 'Picked Up by Driver',
        'delivering' => 'On the Way',
        'delivered' => 'Delivered',
        _ => status,
      };
}

class _RateOrderButton extends StatefulWidget {
  final OrderModel order;
  const _RateOrderButton({required this.order});

  @override
  State<_RateOrderButton> createState() => _RateOrderButtonState();
}

class _RateOrderButtonState extends State<_RateOrderButton> {
  bool _hasRated = false;

  Future<void> _openRatingDialog() async {
    var rating = 5;
    final commentController = TextEditingController();

    final submitted = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: const Text('Rate Your Order'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              StarRatingInput(value: rating, onChanged: (v) => setDialogState(() => rating = v)),
              TextField(
                controller: commentController,
                maxLines: 3,
                decoration: const InputDecoration(hintText: 'Tell others about your experience (optional)'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.of(dialogContext).pop(true), child: const Text('Submit')),
          ],
        ),
      ),
    );

    if (submitted != true || !mounted) return;

    final result = await getIt<ReviewRepository>().create(
      orderId: widget.order.id,
      restaurantId: widget.order.restaurantId,
      driverId: widget.order.driverId,
      rating: rating,
      comment: commentController.text.trim(),
    );
    if (!mounted) return;

    result.when(
      success: (_) {
        setState(() => _hasRated = true);
        context.showSnackBar('Thanks for your feedback!');
      },
      failure: (failure) {
        // The backend enforces one review per order (order_id is unique) —
        // treat that specific case as "already done" rather than an error.
        if (failure is ConflictFailure) {
          setState(() => _hasRated = true);
        } else {
          context.showSnackBar(failure.message, isError: true);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_hasRated) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_rounded, color: AppColors.success, size: 18),
            SizedBox(width: 6),
            Text('You rated this order'),
          ],
        ),
      );
    }
    return AppOutlinedButton(text: 'Rate Your Order', onPressed: _openRatingDialog);
  }
}

class _TrackingStep extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isCompleted;
  final bool isActive;

  const _TrackingStep({required this.title, required this.subtitle, this.isCompleted = false, this.isActive = false});

  @override
  Widget build(BuildContext context) {
    final color = isCompleted ? AppColors.brandPrimary : context.colorScheme.outlineVariant;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(shape: BoxShape.circle, color: isCompleted ? color : Colors.transparent, border: Border.all(color: color, width: 2)),
                child: isCompleted ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
              ),
              Expanded(
                child: Container(width: 2, color: isActive ? AppColors.brandPrimary.withValues(alpha: 0.3) : context.colorScheme.outlineVariant.withValues(alpha: 0.3)),
              ),
            ],
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: context.textTheme.titleSmall?.copyWith(color: isCompleted ? null : context.colorScheme.outline)),
                  if (subtitle.isNotEmpty) Text(subtitle, style: context.textTheme.bodySmall?.copyWith(color: context.colorScheme.outline)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
