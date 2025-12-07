// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationModel _$NotificationModelFromJson(Map<String, dynamic> json) =>
    NotificationModel(
      id: NotificationModel._intFromJson(json['id']),
      userId: NotificationModel._intFromJson(json['user_id']),
      projectId: NotificationModel._intFromJsonNullable(json['project_id']),
      type: json['type'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      link: json['link'] as String?,
      isRead: json['is_read'] as bool,
      readAt: NotificationModel._dateTimeFromJson(json['read_at']),
      data: json['data'] as Map<String, dynamic>?,
      createdAt:
          NotificationModel._dateTimeFromJsonRequired(json['created_at']),
      updatedAt:
          NotificationModel._dateTimeFromJsonRequired(json['updated_at']),
    );

Map<String, dynamic> _$NotificationModelToJson(NotificationModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'project_id': instance.projectId,
      'type': instance.type,
      'title': instance.title,
      'message': instance.message,
      'link': instance.link,
      'is_read': instance.isRead,
      'read_at': instance.readAt?.toIso8601String(),
      'data': instance.data,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };
