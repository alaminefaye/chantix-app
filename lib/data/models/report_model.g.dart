// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReportModel _$ReportModelFromJson(Map<String, dynamic> json) => ReportModel(
      id: (json['id'] as num).toInt(),
      projectId: (json['project_id'] as num).toInt(),
      createdBy: (json['created_by'] as num).toInt(),
      type: json['type'] as String,
      reportDate: json['report_date'] as String,
      endDate: json['end_date'] as String?,
      data: json['data'] as Map<String, dynamic>?,
      filePath: json['file_path'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      project: json['project'] == null
          ? null
          : ProjectModel.fromJson(json['project'] as Map<String, dynamic>),
      creator: json['creator'] == null
          ? null
          : UserModel.fromJson(json['creator'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ReportModelToJson(ReportModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'project_id': instance.projectId,
      'created_by': instance.createdBy,
      'type': instance.type,
      'report_date': instance.reportDate,
      'end_date': instance.endDate,
      'data': instance.data,
      'file_path': instance.filePath,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
      'project': instance.project,
      'creator': instance.creator,
    };
