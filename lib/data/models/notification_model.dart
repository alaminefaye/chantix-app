import 'package:json_annotation/json_annotation.dart';

part 'notification_model.g.dart';

@JsonSerializable()
class NotificationModel {
  @JsonKey(fromJson: _intFromJson)
  final int id;
  @JsonKey(name: 'user_id', fromJson: _intFromJson)
  final int userId;
  @JsonKey(name: 'project_id', fromJson: _intFromJsonNullable)
  final int? projectId;
  final String type;
  final String title;
  final String message;
  final String? link;
  @JsonKey(name: 'is_read')
  final bool isRead;
  @JsonKey(name: 'read_at', fromJson: _dateTimeFromJson)
  final DateTime? readAt;
  final Map<String, dynamic>? data;
  @JsonKey(name: 'created_at', fromJson: _dateTimeFromJsonRequired)
  final DateTime createdAt;
  @JsonKey(name: 'updated_at', fromJson: _dateTimeFromJsonRequired)
  final DateTime updatedAt;

  static DateTime? _dateTimeFromJson(dynamic value) {
    if (value == null) return null;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  static DateTime _dateTimeFromJsonRequired(dynamic value) {
    if (value is String) {
      return DateTime.parse(value);
    }
    return DateTime.now();
  }

  static int _intFromJson(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }

  static int? _intFromJsonNullable(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) {
      return int.tryParse(value);
    }
    return null;
  }

  NotificationModel({
    required this.id,
    required this.userId,
    this.projectId,
    required this.type,
    required this.title,
    required this.message,
    this.link,
    required this.isRead,
    this.readAt,
    this.data,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationModelFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationModelToJson(this);

  // Helper pour obtenir l'icône selon le type
  String getIcon() {
    switch (type) {
      case 'material_created':
      case 'material_updated':
      case 'material_stock_increased':
      case 'material_stock_decreased':
      case 'material_low_stock':
      case 'material_deleted':
        return 'inventory_2';
      case 'task_assigned':
      case 'task_completed':
        return 'checklist';
      case 'progress_update':
        return 'trending_up';
      case 'expense_added':
      case 'expense_updated':
        return 'attach_money';
      case 'comment':
      case 'mention':
        return 'comment';
      case 'project_created':
      case 'project_updated':
        return 'construction';
      default:
        return 'notifications';
    }
  }

  // Helper pour obtenir la couleur selon le type
  int getColorValue() {
    switch (type) {
      case 'material_low_stock':
        return 0xFFFF6B6B; // Rouge
      case 'material_stock_increased':
        return 0xFF51CF66; // Vert
      case 'task_completed':
        return 0xFF51CF66; // Vert
      case 'material_stock_decreased':
        return 0xFFFFD93D; // Jaune
      default:
        return 0xFF4DABF7; // Bleu
    }
  }
}

