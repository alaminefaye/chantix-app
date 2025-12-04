import 'package:json_annotation/json_annotation.dart';
import 'employee_model.dart';

part 'attendance_model.g.dart';

@JsonSerializable()
class AttendanceModel {
  final int id;
  @JsonKey(name: 'project_id')
  final int projectId;
  @JsonKey(name: 'employee_id')
  final int employeeId;
  @JsonKey(name: 'check_in_time')
  final String? checkInTime;
  @JsonKey(name: 'check_out_time')
  final String? checkOutTime;
  @JsonKey(name: 'check_in_latitude')
  final double? checkInLatitude;
  @JsonKey(name: 'check_in_longitude')
  final double? checkInLongitude;
  @JsonKey(name: 'check_out_latitude')
  final double? checkOutLatitude;
  @JsonKey(name: 'check_out_longitude')
  final double? checkOutLongitude;
  @JsonKey(name: 'check_in_photo')
  final String? checkInPhoto;
  @JsonKey(name: 'check_out_photo')
  final String? checkOutPhoto;
  @JsonKey(name: 'hours_worked')
  final double? hoursWorked;
  @JsonKey(name: 'overtime_hours')
  final double? overtimeHours;
  final String? notes;
  @JsonKey(name: 'is_absence')
  final bool isAbsence;
  @JsonKey(name: 'absence_reason')
  final String? absenceReason;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;
  
  // Relations
  final EmployeeModel? employee;

  AttendanceModel({
    required this.id,
    required this.projectId,
    required this.employeeId,
    this.checkInTime,
    this.checkOutTime,
    this.checkInLatitude,
    this.checkInLongitude,
    this.checkOutLatitude,
    this.checkOutLongitude,
    this.checkInPhoto,
    this.checkOutPhoto,
    this.hoursWorked,
    this.overtimeHours,
    this.notes,
    this.isAbsence = false,
    this.absenceReason,
    this.createdAt,
    this.updatedAt,
    this.employee,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) =>
      _$AttendanceModelFromJson(json);

  Map<String, dynamic> toJson() => _$AttendanceModelToJson(this);
}

