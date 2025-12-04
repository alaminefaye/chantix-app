// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TaskModel _$TaskModelFromJson(Map<String, dynamic> json) => TaskModel(
      id: (json['id'] as num).toInt(),
      projectId: (json['project_id'] as num).toInt(),
      createdBy: (json['created_by'] as num).toInt(),
      assignedTo: (json['assigned_to'] as num?)?.toInt(),
      title: json['title'] as String,
      description: json['description'] as String?,
      category: json['category'] as String?,
      status: json['status'] as String,
      priority: json['priority'] as String,
      startDate: json['start_date'] as String?,
      deadline: json['deadline'] as String?,
      progress: (json['progress'] as num?)?.toInt() ?? 0,
      notes: json['notes'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      project: json['project'] == null
          ? null
          : ProjectModel.fromJson(json['project'] as Map<String, dynamic>),
      creator: json['creator'] == null
          ? null
          : UserModel.fromJson(json['creator'] as Map<String, dynamic>),
      assignedEmployee: json['assignedEmployee'] == null
          ? null
          : EmployeeModel.fromJson(
              json['assignedEmployee'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$TaskModelToJson(TaskModel instance) => <String, dynamic>{
      'id': instance.id,
      'project_id': instance.projectId,
      'created_by': instance.createdBy,
      'assigned_to': instance.assignedTo,
      'title': instance.title,
      'description': instance.description,
      'category': instance.category,
      'status': instance.status,
      'priority': instance.priority,
      'start_date': instance.startDate,
      'deadline': instance.deadline,
      'progress': instance.progress,
      'notes': instance.notes,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
      'project': instance.project,
      'creator': instance.creator,
      'assignedEmployee': instance.assignedEmployee,
    };
