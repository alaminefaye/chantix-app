// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProjectModel _$ProjectModelFromJson(Map<String, dynamic> json) => ProjectModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      description: json['description'] as String?,
      address: json['address'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      startDate: json['start_date'] as String?,
      endDate: json['end_date'] as String?,
      budget: (json['budget'] as num).toDouble(),
      status: json['status'] as String,
      progress: (json['progress'] as num).toInt(),
      clientName: json['client_name'] as String?,
      clientContact: json['client_contact'] as String?,
      companyId: (json['company_id'] as num).toInt(),
      createdBy: (json['created_by'] as num).toInt(),
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      creator: json['creator'] == null
          ? null
          : UserModel.fromJson(json['creator'] as Map<String, dynamic>),
      company: json['company'] == null
          ? null
          : CompanyModel.fromJson(json['company'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ProjectModelToJson(ProjectModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'address': instance.address,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'start_date': instance.startDate,
      'end_date': instance.endDate,
      'budget': instance.budget,
      'status': instance.status,
      'progress': instance.progress,
      'client_name': instance.clientName,
      'client_contact': instance.clientContact,
      'company_id': instance.companyId,
      'created_by': instance.createdBy,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
      'creator': instance.creator,
      'company': instance.company,
    };
