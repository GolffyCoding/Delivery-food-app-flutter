import 'package:flutter/material.dart';
import 'package:opendelivery_core/opendelivery_core.dart';
import 'package:opendelivery_design_system/opendelivery_design_system.dart';
import 'package:opendelivery_shared_widgets/opendelivery_shared_widgets.dart';
import 'package:driver_app/data/driver_repository.dart';
import 'package:driver_app/di/injection.dart';

class EarningsPage extends StatefulWidget {
  const EarningsPage({super.key});
  static const String route = '/earnings';

  @override
  State<EarningsPage> createState() => _EarningsPageState();
}

class _EarningsPageState extends State<EarningsPage> {
  late Future<Result<Map<String, dynamic>, Failure>> _future;

  @override
  void initState() {
    super.initState();
    _future = getIt<DriverRepository>().earnings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppAppBar(title: 'Earnings'),
      body: FutureBuilder<Result<Map<String, dynamic>, Failure>>(
        future: _future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const AppLoadingIndicator();
          return snapshot.data!.when(
            success: (data) {
              // Backend shape is `{"earnings": [...] | null, "total": number}` —
              // no fee/tip breakdown is provided.
              final total = (data['total'] as num?)?.toDouble() ?? 0.0;
              final entries = data['earnings'] as List<dynamic>? ?? const [];

              return ListView(
                padding: AppSpacing.screenPadding,
                children: [
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Total', style: context.textTheme.labelLarge?.copyWith(color: context.colorScheme.outline)),
                        const SizedBox(height: AppSpacing.sm),
                        Text('\$${total.toStringAsFixed(2)}', style: context.textTheme.headlineLarge?.copyWith(color: AppColors.brandPrimary, fontWeight: FontWeight.bold)),
                        const Divider(height: 32),
                        _EarningRow(label: 'Completed Deliveries', value: '${entries.length}'),
                      ],
                    ),
                  ),
                ],
              );
            },
            failure: (failure) => ErrorView(failure: failure),
          );
        },
      ),
    );
  }
}

class _EarningRow extends StatelessWidget {
  final String label;
  final String value;
  const _EarningRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: context.textTheme.bodyLarge),
          Text(value, style: context.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
