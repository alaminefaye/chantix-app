import 'package:json_annotation/json_annotation.dart';

part 'employee_model.g.dart';

@JsonSerializable()
class EmployeeModel {
  final int id;
  @JsonKey(name: 'company_id')
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
  @JsonKey(name: 'hourly_rate')
  final double? hourlyRate;
  final String? address;
  final String? city;
  final String? country;
  @JsonKey(name: 'birth_date')
  final String? birthDate;
  @JsonKey(name: 'id_number')
  final String? idNumber;
  final String? notes;
  @JsonKey(name: 'is_active')
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

  String get fullName => '$firstName $lastName';
}

