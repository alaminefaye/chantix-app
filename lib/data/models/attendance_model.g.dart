// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AttendanceModel _$AttendanceModelFromJson(Map<String, dynamic> json) =>
    AttendanceModel(
      id: AttendanceModel._intFromJson(json['id']),
      projectId: AttendanceModel._intFromJson(json['project_id']),
      employeeId: AttendanceModel._intFromJson(json['employee_id']),
      checkInTime: json['check_in_time'] as String?,
      checkOutTime: json['check_out_time'] as String?,
      checkInLatitude:
          AttendanceModel._doubleFromJsonNullable(json['check_in_latitude']),
      checkInLongitude:
          AttendanceModel._doubleFromJsonNullable(json['check_in_longitude']),
      checkOutLatitude:
          AttendanceModel._doubleFromJsonNullable(json['check_out_latitude']),
      checkOutLongitude:
          AttendanceModel._doubleFromJsonNullable(json['check_out_longitude']),
      checkInPhoto: json['check_in_photo'] as String?,
      checkOutPhoto: json['check_out_photo'] as String?,
      hoursWorked:
          AttendanceModel._doubleFromJsonNullable(json['hours_worked']),
      overtimeHours:
          AttendanceModel._doubleFromJsonNullable(json['overtime_hours']),
      notes: json['notes'] as String?,
      isAbsence: json['is_absence'] == null
          ? false
          : AttendanceModel._boolFromJson(json['is_absence']),
      absenceReason: json['absence_reason'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      employee: json['employee'] == null
          ? null
          : EmployeeModel.fromJson(json['employee'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AttendanceModelToJson(AttendanceModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'project_id': instance.projectId,
      'employee_id': instance.employeeId,
      'check_in_time': instance.checkInTime,
      'check_out_time': instance.checkOutTime,
      'check_in_latitude': instance.checkInLatitude,
      'check_in_longitude': instance.checkInLongitude,
      'check_out_latitude': instance.checkOutLatitude,
      'check_out_longitude': instance.checkOutLongitude,
      'check_in_photo': instance.checkInPhoto,
      'check_out_photo': instance.checkOutPhoto,
      'hours_worked': instance.hoursWorked,
      'overtime_hours': instance.overtimeHours,
      'notes': instance.notes,
      'is_absence': instance.isAbsence,
      'absence_reason': instance.absenceReason,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
      'employee': instance.employee,
    };
