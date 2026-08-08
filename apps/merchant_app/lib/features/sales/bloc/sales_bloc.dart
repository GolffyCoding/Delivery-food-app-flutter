import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:merchant_app/domain/models/sales_report_model.dart';

enum SalesPeriod { today, week, month }

sealed class SalesEvent {}

class LoadSales extends SalesEvent {
  final SalesPeriod period;
  LoadSales(this.period);
}

class SalesState {
  final SalesPeriod selectedPeriod;
  final bool isLoading;
  final SalesReportModel? report;
  const SalesState({this.selectedPeriod = SalesPeriod.today, this.isLoading = false, this.report});
}

class SalesBloc extends Bloc<SalesEvent, SalesState> {
  SalesBloc() : super(const SalesState()) {
    on<LoadSales>(_onLoad);
  }

  Future<void> _onLoad(LoadSales event, Emitter<SalesState> emit) async {
    emit(SalesState(selectedPeriod: event.period, isLoading: true));
    await Future.delayed(const Duration(milliseconds: 500));

    final mockReport = SalesReportModel(
      totalRevenue: event.period == SalesPeriod.today ? 1250.50 : (event.period == SalesPeriod.week ? 8500.00 : 35000.00),
      totalOrders: event.period == SalesPeriod.today ? 45 : (event.period == SalesPeriod.week ? 312 : 1250),
      averageOrderValue: event.period == SalesPeriod.today ? 27.78 : 28.00,
      topItems: const [
        TopSellingItem(name: 'Margherita Pizza', qtySold: 25, revenue: 324.75),
        TopSellingItem(name: 'Caesar Salad', qtySold: 18, revenue: 161.82),
        TopSellingItem(name: 'Tiramisu', qtySold: 15, revenue: 119.85),
      ],
    );

    emit(SalesState(selectedPeriod: event.period, isLoading: false, report: mockReport));
  }
}
