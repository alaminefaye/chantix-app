// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExpenseModel _$ExpenseModelFromJson(Map<String, dynamic> json) => ExpenseModel(
      id: ExpenseModel._intFromJson(json['id']),
      projectId: ExpenseModel._intFromJson(json['project_id']),
      createdBy: ExpenseModel._intFromJson(json['created_by']),
      type: json['type'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      amount: ExpenseModel._amountFromJson(json['amount']),
      expenseDate: json['expense_date'] as String,
      supplier: json['supplier'] as String?,
      invoiceNumber: json['invoice_number'] as String?,
      invoiceDate: json['invoice_date'] as String?,
      invoiceFile: json['invoice_file'] as String?,
      materialId: ExpenseModel._intFromJsonNullable(json['material_id']),
      employeeId: ExpenseModel._intFromJsonNullable(json['employee_id']),
      notes: json['notes'] as String?,
      isPaid: json['is_paid'] as bool? ?? false,
      paidDate: json['paid_date'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      project: json['project'] == null
          ? null
          : ProjectModel.fromJson(json['project'] as Map<String, dynamic>),
      creator: json['creator'] == null
          ? null
          : UserModel.fromJson(json['creator'] as Map<String, dynamic>),
      material: json['material'] == null
          ? null
          : MaterialModel.fromJson(json['material'] as Map<String, dynamic>),
      employee: json['employee'] == null
          ? null
          : EmployeeModel.fromJson(json['employee'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ExpenseModelToJson(ExpenseModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'project_id': instance.projectId,
      'created_by': instance.createdBy,
      'type': instance.type,
      'title': instance.title,
      'description': instance.description,
      'amount': instance.amount,
      'expense_date': instance.expenseDate,
      'supplier': instance.supplier,
      'invoice_number': instance.invoiceNumber,
      'invoice_date': instance.invoiceDate,
      'invoice_file': instance.invoiceFile,
      'material_id': instance.materialId,
      'employee_id': instance.employeeId,
      'notes': instance.notes,
      'is_paid': instance.isPaid,
      'paid_date': instance.paidDate,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
      'project': instance.project,
      'creator': instance.creator,
      'material': instance.material,
      'employee': instance.employee,
    };
