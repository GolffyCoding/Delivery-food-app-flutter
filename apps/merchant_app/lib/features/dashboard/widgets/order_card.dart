import 'package:flutter/material.dart';
import 'package:opendelivery_core/opendelivery_core.dart';
import 'package:opendelivery_design_system/opendelivery_design_system.dart';
import 'package:opendelivery_state_machine/opendelivery_state_machine.dart';
import 'package:merchant_app/features/dashboard/bloc/merchant_order_bloc.dart';

class OrderCard extends StatelessWidget {
  final KanbanOrder order;
  final VoidCallback? onTap;
  final VoidCallback? onAction;
  final String actionLabel;
  final Color accentColor;

  const OrderCard({
    super.key,
    required this.order,
    this.onTap,
    this.onAction,
    required this.actionLabel,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    // A "Ready" order sitting uncollected gets cold fast — that clock is
    // more urgent, and different, from "time since the kitchen accepted it".
    final isWaitingForPickup = order.state is ReadyState;
    final relevantDuration = isWaitingForPickup ? order.waitingForPickupDuration : order.timeInState;
    final timeStr = _formatDuration(relevantDuration);
    final isUrgent = isWaitingForPickup ? relevantDuration.inMinutes >= 5 : relevantDuration.inMinutes >= 10;

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.mdBorder,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          border: Border.all(color: isUrgent ? AppColors.error : AppColors.neutral200, width: isUrgent ? 2 : 1),
          borderRadius: AppRadius.mdBorder,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('#${order.id}', style: context.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isUrgent ? AppColors.errorLight : AppColors.neutral100,
                    borderRadius: AppRadius.smBorder,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.schedule, size: 12, color: isUrgent ? AppColors.error : AppColors.neutral600),
                      const SizedBox(width: 2),
                      Text(
                        timeStr,
                        style: context.textTheme.labelSmall?.copyWith(
                          color: isUrgent ? AppColors.error : AppColors.neutral700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(order.customerName, style: context.textTheme.titleSmall),
            const SizedBox(height: AppSpacing.xs),
            Text(order.itemsSummary, style: context.textTheme.bodySmall?.copyWith(color: AppColors.neutral600), maxLines: 1, overflow: TextOverflow.ellipsis),
            if (order.assignedDriverName != null) ...[
              const Divider(height: 24),
              Row(
                children: [
                  const Icon(Icons.delivery_dining, size: 16, color: AppColors.brandPrimary),
                  const SizedBox(width: 4),
                  Text('Driver: ${order.assignedDriverName}', style: context.textTheme.labelSmall?.copyWith(color: AppColors.brandPrimary)),
                ],
              ),
            ],
            if (onAction != null) ...[
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: onAction,
                  style: FilledButton.styleFrom(backgroundColor: accentColor, padding: const EdgeInsets.symmetric(vertical: 12)),
                  child: Text(actionLabel, style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ] else ...[
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: null,
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.neutral300)),
                  child: Text(actionLabel, style: const TextStyle(color: AppColors.neutral500)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
