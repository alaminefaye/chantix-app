import 'package:json_annotation/json_annotation.dart';
import 'employee_model.dart';

part 'project_employee_model.g.dart';

@JsonSerializable()
class ProjectEmployeeModel {
  @JsonKey(fromJson: _employeeFromJson)
  final EmployeeModel employee;
  @JsonKey(name: 'assigned_date')
  final String? assignedDate;
  @JsonKey(name: 'end_date')
  final String? endDate;
  final String? notes;
  @JsonKey(name: 'is_active', fromJson: _boolFromJson)
  final bool isActive;

  ProjectEmployeeModel({
    required this.employee,
    this.assignedDate,
    this.endDate,
    this.notes,
    required this.isActive,
  });

  factory ProjectEmployeeModel.fromJson(Map<String, dynamic> json) =>
      _$ProjectEmployeeModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProjectEmployeeModelToJson(this);

  static EmployeeModel _employeeFromJson(dynamic value) {
    if (value is Map<String, dynamic>) {
      return EmployeeModel.fromJson(value);
    }
    throw Exception('Employee data format not supported');
  }

  static bool _boolFromJson(dynamic value) {
    if (value == null) return true; // Par défaut, actif
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) {
      return value == '1' || value.toLowerCase() == 'true';
    }
    return true;
  }
}

