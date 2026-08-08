import 'package:flutter/material.dart';

/// Widget for displaying route info.
class RouteInfoWidget extends StatelessWidget {
  final String distance;
  final String duration;
  final VoidCallback? onTapNavigate;

  const RouteInfoWidget({super.key, required this.distance, required this.duration, this.onTapNavigate});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.route, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Text('$distance · $duration', style: Theme.of(context).textTheme.labelMedium),
          if (onTapNavigate != null) ...[
            const SizedBox(width: 12),
            InkWell(
              onTap: onTapNavigate,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, borderRadius: BorderRadius.circular(8)),
                child: Text('Navigate', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.onPrimary)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
