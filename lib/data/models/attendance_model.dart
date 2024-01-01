import 'package:json_annotation/json_annotation.dart';
import 'employee_model.dart';

part 'attendance_model.g.dart';

@JsonSerializable()
class AttendanceModel {
  @JsonKey(fromJson: _intFromJson)
  final int id;
  @JsonKey(name: 'project_id', fromJson: _intFromJson)
  final int projectId;
  @JsonKey(name: 'employee_id', fromJson: _intFromJson)
  final int employeeId;
  @JsonKey(name: 'check_in_time')
  final String? checkInTime;
  @JsonKey(name: 'check_out_time')
  final String? checkOutTime;
  @JsonKey(name: 'check_in_latitude', fromJson: _doubleFromJsonNullable)
  final double? checkInLatitude;
  @JsonKey(name: 'check_in_longitude', fromJson: _doubleFromJsonNullable)
  final double? checkInLongitude;
  @JsonKey(name: 'check_out_latitude', fromJson: _doubleFromJsonNullable)
  final double? checkOutLatitude;
  @JsonKey(name: 'check_out_longitude', fromJson: _doubleFromJsonNullable)
  final double? checkOutLongitude;
  @JsonKey(name: 'check_in_photo')
  final String? checkInPhoto;
  @JsonKey(name: 'check_out_photo')
  final String? checkOutPhoto;
  @JsonKey(name: 'hours_worked', fromJson: _doubleFromJsonNullable)
  final double? hoursWorked;
  @JsonKey(name: 'overtime_hours', fromJson: _doubleFromJsonNullable)
  final double? overtimeHours;
  final String? notes;
  @JsonKey(name: 'is_absence', fromJson: _boolFromJson)
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

  // Fonctions de conversion pour gérer les strings et les nombres
  static int _intFromJson(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toInt();
    if (value is String) {
      final parsed = int.tryParse(value);
      return parsed ?? 0;
    }
    return 0;
  }

  static double? _doubleFromJsonNullable(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value);
      return parsed;
    }
    return null;
  }

  static bool _boolFromJson(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is String) {
      return value.toLowerCase() == 'true' || value == '1';
    }
    if (value is num) {
      return value != 0;
    }
    return false;
  }
}
