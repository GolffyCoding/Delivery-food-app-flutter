import 'package:equatable/equatable.dart';

class NotificationEntity extends Equatable {
  final String id;
  final String title;
  final String body;
  final String? imageUrl;
  final bool isRead;
  final String type;
  final DateTime createdAt;
  final String? referenceId;

  const NotificationEntity({
    required this.id,
    required this.title,
    required this.body,
    this.imageUrl,
    this.isRead = false,
    required this.type,
    required this.createdAt,
    this.referenceId,
  });

  @override
  List<Object?> get props => [id, title, body, isRead, type, createdAt];
}
