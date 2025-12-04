// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'progress_update_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProgressUpdateModel _$ProgressUpdateModelFromJson(Map<String, dynamic> json) =>
    ProgressUpdateModel(
      id: (json['id'] as num).toInt(),
      projectId: (json['project_id'] as num).toInt(),
      userId: (json['user_id'] as num).toInt(),
      progress: (json['progress'] as num).toInt(),
      description: json['description'] as String?,
      audioReport: json['audio_report'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      photos:
          (json['photos'] as List<dynamic>?)?.map((e) => e as String).toList(),
      videos:
          (json['videos'] as List<dynamic>?)?.map((e) => e as String).toList(),
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      user: json['user'] == null
          ? null
          : UserModel.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ProgressUpdateModelToJson(
        ProgressUpdateModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'project_id': instance.projectId,
      'user_id': instance.userId,
      'progress': instance.progress,
      'description': instance.description,
      'audio_report': instance.audioReport,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'photos': instance.photos,
      'videos': instance.videos,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
      'user': instance.user,
    };
