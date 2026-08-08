import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opendelivery_core/opendelivery_core.dart';
import 'package:opendelivery_design_system/opendelivery_design_system.dart';
import 'package:opendelivery_shared_widgets/opendelivery_shared_widgets.dart';
import 'package:merchant_app/di/injection.dart';
import 'package:merchant_app/features/sales/bloc/sales_bloc.dart';

class SalesReportPage extends StatelessWidget {
  const SalesReportPage({super.key});
  static const String route = '/sales';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<SalesBloc>()..add(LoadSales(SalesPeriod.today)),
      child: Scaffold(
        appBar: const AppAppBar(title: 'Sales Report'),
        body: BlocBuilder<SalesBloc, SalesState>(
          builder: (context, state) {
            if (state.isLoading || state.report == null) {
              return const AppLoadingIndicator();
            }
            final report = state.report!;
            return SingleChildScrollView(
              padding: AppSpacing.screenPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _PeriodSelector(),
                  const SizedBox(height: AppSpacing.xl),
                  _KpiCard(title: 'Total Revenue', value: '\$${report.totalRevenue.toStringAsFixed(2)}', icon: Icons.attach_money, color: AppColors.brandPrimary),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(child: _KpiCard(title: 'Total Orders', value: '${report.totalOrders}', icon: Icons.receipt_long, color: AppColors.info)),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(child: _KpiCard(title: 'Avg. Order', value: '\$${report.averageOrderValue.toStringAsFixed(2)}', icon: Icons.analytics, color: AppColors.warning)),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text('Top Selling Items', style: context.textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.md),
                  ...report.topItems.map((item) => AppCard(
                        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.name, style: context.textTheme.titleSmall),
                                  const SizedBox(height: 4),
                                  Text('${item.qtySold} sold', style: context.textTheme.bodySmall?.copyWith(color: context.colorScheme.outline)),
                                ],
                              ),
                            ),
                            Text('\$${item.revenue.toStringAsFixed(2)}', style: context.textTheme.titleSmall?.copyWith(color: AppColors.brandPrimary, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      )),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PeriodSelector extends StatelessWidget {
  const _PeriodSelector();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SalesBloc, SalesState>(
      builder: (context, state) {
        return SegmentedButton<SalesPeriod>(
          segments: const [
            ButtonSegment(value: SalesPeriod.today, label: Text('Today')),
            ButtonSegment(value: SalesPeriod.week, label: Text('This Week')),
            ButtonSegment(value: SalesPeriod.month, label: Text('This Month')),
          ],
          selected: {state.selectedPeriod},
          onSelectionChanged: (period) => context.read<SalesBloc>().add(LoadSales(period.first)),
        );
      },
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  const _KpiCard({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: AppRadius.mdBorder),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: context.textTheme.labelMedium?.copyWith(color: context.colorScheme.outline)),
                const SizedBox(height: 4),
                Text(value, style: context.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
