import 'package:json_annotation/json_annotation.dart';
import 'project_model.dart';
import 'user_model.dart';
import 'material_model.dart';
import 'employee_model.dart';

part 'expense_model.g.dart';

@JsonSerializable()
class ExpenseModel {
  @JsonKey(fromJson: _intFromJson)
  final int id;
  @JsonKey(name: 'project_id', fromJson: _intFromJson)
  final int projectId;
  @JsonKey(name: 'created_by', fromJson: _intFromJson)
  final int createdBy;
  final String type;
  final String title;
  final String? description;
  @JsonKey(fromJson: _amountFromJson)
  final double amount;
  @JsonKey(name: 'expense_date')
  final String expenseDate;
  final String? supplier;
  @JsonKey(name: 'invoice_number')
  final String? invoiceNumber;
  @JsonKey(name: 'invoice_date')
  final String? invoiceDate;
  @JsonKey(name: 'invoice_file')
  final String? invoiceFile;
  @JsonKey(name: 'material_id', fromJson: _intFromJsonNullable)
  final int? materialId;
  @JsonKey(name: 'employee_id', fromJson: _intFromJsonNullable)
  final int? employeeId;
  final String? notes;
  @JsonKey(name: 'is_paid')
  final bool isPaid;
  @JsonKey(name: 'paid_date')
  final String? paidDate;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  // Relations
  final ProjectModel? project;
  final UserModel? creator;
  final MaterialModel? material;
  final EmployeeModel? employee;

  ExpenseModel({
    required this.id,
    required this.projectId,
    required this.createdBy,
    required this.type,
    required this.title,
    this.description,
    required this.amount,
    required this.expenseDate,
    this.supplier,
    this.invoiceNumber,
    this.invoiceDate,
    this.invoiceFile,
    this.materialId,
    this.employeeId,
    this.notes,
    this.isPaid = false,
    this.paidDate,
    this.createdAt,
    this.updatedAt,
    this.project,
    this.creator,
    this.material,
    this.employee,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) =>
      _$ExpenseModelFromJson(json);

  Map<String, dynamic> toJson() => _$ExpenseModelToJson(this);

  static double _amountFromJson(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value);
      return parsed ?? 0.0;
    }
    return 0.0;
  }

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

  static int? _intFromJsonNullable(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) {
      final parsed = int.tryParse(value);
      return parsed;
    }
    return null;
  }

  String get typeLabel {
    switch (type) {
      case 'materiaux':
        return 'Matériaux';
      case 'transport':
        return 'Transport';
      case 'main_oeuvre':
        return 'Main-d\'œuvre';
      case 'location':
        return 'Location machines';
      case 'autres':
        return 'Autres';
      default:
        return type;
    }
  }
}

