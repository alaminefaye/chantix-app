// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project_employee_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProjectEmployeeModel _$ProjectEmployeeModelFromJson(
        Map<String, dynamic> json) =>
    ProjectEmployeeModel(
      employee: ProjectEmployeeModel._employeeFromJson(json['employee']),
      assignedDate: json['assigned_date'] as String?,
      endDate: json['end_date'] as String?,
      notes: json['notes'] as String?,
      isActive: ProjectEmployeeModel._boolFromJson(json['is_active']),
    );

Map<String, dynamic> _$ProjectEmployeeModelToJson(
        ProjectEmployeeModel instance) =>
    <String, dynamic>{
      'employee': instance.employee,
      'assigned_date': instance.assignedDate,
      'end_date': instance.endDate,
      'notes': instance.notes,
      'is_active': instance.isActive,
    };
