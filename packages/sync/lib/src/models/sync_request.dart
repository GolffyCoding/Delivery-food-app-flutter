import 'package:equatable/equatable.dart';

/// Represents a network request waiting to be synced when back online.
class SyncRequest extends Equatable {
  final String localId;

  /// Prevents double-processing on the backend if a retry happens after a
  /// partial success (e.g. app crashed after the server processed the order
  /// but before the client got the response).
  final String idempotencyKey;

  final String path;
  final Map<String, dynamic>? body;
  final int retryCount;
  final int maxRetries;
  final DateTime createdAt;

  const SyncRequest({
    required this.localId,
    required this.idempotencyKey,
    required this.path,
    this.body,
    this.retryCount = 0,
    this.maxRetries = 3,
    required this.createdAt,
  });

  bool get shouldRetry => retryCount < maxRetries;

  SyncRequest copyWith({int? retryCount}) {
    return SyncRequest(
      localId: localId,
      idempotencyKey: idempotencyKey,
      path: path,
      body: body,
      retryCount: retryCount ?? this.retryCount,
      maxRetries: maxRetries,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'localId': localId,
        'idempotencyKey': idempotencyKey,
        'path': path,
        'body': body,
        'retryCount': retryCount,
        'maxRetries': maxRetries,
        'createdAt': createdAt.toIso8601String(),
      };

  factory SyncRequest.fromJson(Map<String, dynamic> json) => SyncRequest(
        localId: json['localId'] as String,
        idempotencyKey: json['idempotencyKey'] as String,
        path: json['path'] as String,
        body: json['body'] as Map<String, dynamic>?,
        retryCount: json['retryCount'] as int? ?? 0,
        maxRetries: json['maxRetries'] as int? ?? 3,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  @override
  List<Object?> get props => [localId, idempotencyKey, path, retryCount];
}
