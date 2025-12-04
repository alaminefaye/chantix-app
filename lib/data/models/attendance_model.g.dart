// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AttendanceModel _$AttendanceModelFromJson(Map<String, dynamic> json) =>
    AttendanceModel(
      id: (json['id'] as num).toInt(),
      projectId: (json['project_id'] as num).toInt(),
      employeeId: (json['employee_id'] as num).toInt(),
      checkInTime: json['check_in_time'] as String?,
      checkOutTime: json['check_out_time'] as String?,
      checkInLatitude: (json['check_in_latitude'] as num?)?.toDouble(),
      checkInLongitude: (json['check_in_longitude'] as num?)?.toDouble(),
      checkOutLatitude: (json['check_out_latitude'] as num?)?.toDouble(),
      checkOutLongitude: (json['check_out_longitude'] as num?)?.toDouble(),
      checkInPhoto: json['check_in_photo'] as String?,
      checkOutPhoto: json['check_out_photo'] as String?,
      hoursWorked: (json['hours_worked'] as num?)?.toDouble(),
      overtimeHours: (json['overtime_hours'] as num?)?.toDouble(),
      notes: json['notes'] as String?,
      isAbsence: json['is_absence'] as bool? ?? false,
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
