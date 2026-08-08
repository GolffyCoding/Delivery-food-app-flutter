import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';

/// Metadata returned alongside paginated list endpoints.
class ApiMeta extends Equatable {
  final int? page;
  final int? perPage;
  final int? total;
  final int? totalPages;
  final bool? hasMore;

  const ApiMeta({this.page, this.perPage, this.total, this.totalPages, this.hasMore});

  factory ApiMeta.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const ApiMeta();
    return ApiMeta(
      page: json['page'] as int?,
      perPage: json['per_page'] as int?,
      total: json['total'] as int?,
      totalPages: json['total_pages'] as int?,
      hasMore: json['has_more'] as bool?,
    );
  }

  @override
  List<Object?> get props => [page, perPage, total, totalPages, hasMore];
}

/// The OpenDelivery backend wraps every response as:
/// `{"success": bool, "data": ..., "error": {"code","message"}, "meta": {...}}`
class ApiResponse<T> extends Equatable {
  final bool success;
  final T? data;
  final String? errorCode;
  final String? errorMessage;
  final ApiMeta meta;
  final int? statusCode;

  const ApiResponse({
    required this.success,
    this.data,
    this.errorCode,
    this.errorMessage,
    this.meta = const ApiMeta(),
    this.statusCode,
  });

  factory ApiResponse.fromResponse(
    Response<Map<String, dynamic>> response,
    T? Function(dynamic)? decoder,
  ) {
    final body = response.data;
    final error = body?['error'] as Map<String, dynamic>?;
    final rawData = body?['data'];
    return ApiResponse(
      success: body?['success'] as bool? ?? (response.statusCode != null && response.statusCode! < 300),
      data: decoder != null ? decoder(rawData) : rawData as T?,
      errorCode: error?['code'] as String?,
      errorMessage: error?['message'] as String?,
      meta: ApiMeta.fromJson(body?['meta'] as Map<String, dynamic>?),
      statusCode: response.statusCode,
    );
  }

  @override
  List<Object?> get props => [success, data, errorCode, errorMessage, statusCode];
}
