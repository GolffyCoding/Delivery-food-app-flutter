import 'package:equatable/equatable.dart';

/// Paginated API response wrapper.
class PaginatedResponse<T> extends Equatable {
  final List<T> items;
  final int totalItems;
  final int currentPage;
  final int totalPages;
  final bool hasNextPage;

  const PaginatedResponse({
    required this.items,
    required this.totalItems,
    required this.currentPage,
    required this.totalPages,
    required this.hasNextPage,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    final items = (json['items'] as List<dynamic>)
        .map((e) => fromJsonT(e as Map<String, dynamic>))
        .toList();

    return PaginatedResponse(
      items: items,
      totalItems: json['totalItems'] as int? ?? 0,
      currentPage: json['currentPage'] as int? ?? 1,
      totalPages: json['totalPages'] as int? ?? 1,
      hasNextPage: json['hasNextPage'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [items, totalItems, currentPage, totalPages, hasNextPage];
}
