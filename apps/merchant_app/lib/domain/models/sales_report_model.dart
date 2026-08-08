import 'package:equatable/equatable.dart';

class TopSellingItem extends Equatable {
  final String name;
  final int qtySold;
  final double revenue;
  const TopSellingItem({required this.name, required this.qtySold, required this.revenue});

  @override
  List<Object?> get props => [name, qtySold, revenue];
}

class SalesReportModel extends Equatable {
  final double totalRevenue;
  final int totalOrders;
  final double averageOrderValue;
  final List<TopSellingItem> topItems;

  const SalesReportModel({
    required this.totalRevenue,
    required this.totalOrders,
    required this.averageOrderValue,
    required this.topItems,
  });

  @override
  List<Object?> get props => [totalRevenue, totalOrders, averageOrderValue];
}
