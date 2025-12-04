// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'employee_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EmployeeModel _$EmployeeModelFromJson(Map<String, dynamic> json) =>
    EmployeeModel(
      id: (json['id'] as num).toInt(),
      companyId: (json['company_id'] as num).toInt(),
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      position: json['position'] as String?,
      employeeNumber: json['employee_number'] as String?,
      hireDate: json['hire_date'] as String?,
      hourlyRate: (json['hourly_rate'] as num?)?.toDouble(),
      address: json['address'] as String?,
      city: json['city'] as String?,
      country: json['country'] as String?,
      birthDate: json['birth_date'] as String?,
      idNumber: json['id_number'] as String?,
      notes: json['notes'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );

Map<String, dynamic> _$EmployeeModelToJson(EmployeeModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'company_id': instance.companyId,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'email': instance.email,
      'phone': instance.phone,
      'position': instance.position,
      'employee_number': instance.employeeNumber,
      'hire_date': instance.hireDate,
      'hourly_rate': instance.hourlyRate,
      'address': instance.address,
      'city': instance.city,
      'country': instance.country,
      'birth_date': instance.birthDate,
      'id_number': instance.idNumber,
      'notes': instance.notes,
      'is_active': instance.isActive,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };
