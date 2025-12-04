// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CommentModel _$CommentModelFromJson(Map<String, dynamic> json) => CommentModel(
      id: (json['id'] as num).toInt(),
      projectId: (json['project_id'] as num).toInt(),
      userId: (json['user_id'] as num).toInt(),
      parentId: (json['parent_id'] as num?)?.toInt(),
      content: json['content'] as String,
      mentionedUsers: (json['mentioned_users'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
      attachments: (json['attachments'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList(),
      isRead: json['is_read'] as bool? ?? false,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      project: json['project'] == null
          ? null
          : ProjectModel.fromJson(json['project'] as Map<String, dynamic>),
      user: json['user'] == null
          ? null
          : UserModel.fromJson(json['user'] as Map<String, dynamic>),
      replies: (json['replies'] as List<dynamic>?)
          ?.map((e) => CommentModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CommentModelToJson(CommentModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'project_id': instance.projectId,
      'user_id': instance.userId,
      'parent_id': instance.parentId,
      'content': instance.content,
      'mentioned_users': instance.mentionedUsers,
      'attachments': instance.attachments,
      'is_read': instance.isRead,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
      'project': instance.project,
      'user': instance.user,
      'replies': instance.replies,
    };
