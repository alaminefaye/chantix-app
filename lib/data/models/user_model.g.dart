// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
      id: UserModel._idFromJson(json['id']),
      name: json['name'] as String,
      email: json['email'] as String,
      isSuperAdmin: json['is_super_admin'] as bool? ?? false,
      isVerified: json['is_verified'] as bool? ?? false,
      currentCompanyId:
          UserModel._currentCompanyIdFromJson(json['current_company_id']),
      avatar: json['avatar'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'is_super_admin': instance.isSuperAdmin,
      'is_verified': instance.isVerified,
      'current_company_id': instance.currentCompanyId,
      'avatar': instance.avatar,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };
