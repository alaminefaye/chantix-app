import 'package:json_annotation/json_annotation.dart';

part 'employee_model.g.dart';

@JsonSerializable()
class EmployeeModel {
  @JsonKey(fromJson: _intFromJson)
  final int id;
  @JsonKey(name: 'company_id', fromJson: _intFromJson)
  final int companyId;
  @JsonKey(name: 'first_name')
  final String firstName;
  @JsonKey(name: 'last_name')
  final String lastName;
  final String? email;
  final String? phone;
  final String? position;
  @JsonKey(name: 'employee_number')
  final String? employeeNumber;
  @JsonKey(name: 'hire_date')
  final String? hireDate;
  @JsonKey(name: 'hourly_rate', fromJson: _doubleFromJsonNullable)
  final double? hourlyRate;
  final String? address;
  final String? city;
  final String? country;
  @JsonKey(name: 'birth_date')
  final String? birthDate;
  @JsonKey(name: 'id_number')
  final String? idNumber;
  final String? notes;
  @JsonKey(name: 'is_active', fromJson: _boolFromJson)
  final bool isActive;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  EmployeeModel({
    required this.id,
    required this.companyId,
    required this.firstName,
    required this.lastName,
    this.email,
    this.phone,
    this.position,
    this.employeeNumber,
    this.hireDate,
    this.hourlyRate,
    this.address,
    this.city,
    this.country,
    this.birthDate,
    this.idNumber,
    this.notes,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory EmployeeModel.fromJson(Map<String, dynamic> json) =>
      _$EmployeeModelFromJson(json);

  Map<String, dynamic> toJson() => _$EmployeeModelToJson(this);

  static int _intFromJson(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) {
      final parsed = int.tryParse(value);
      return parsed ?? 0;
    }
    return 0;
  }

  static double? _doubleFromJsonNullable(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    if (value is String) {
      // Gérer les formats avec virgule (ex: "1000,00")
      final cleaned = value.replaceAll(',', '.');
      final parsed = double.tryParse(cleaned);
      return parsed;
    }
    return null;
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

  String get fullName => '$firstName $lastName';
}

