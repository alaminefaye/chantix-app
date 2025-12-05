import 'package:json_annotation/json_annotation.dart';
import 'user_model.dart';
import 'company_model.dart';

part 'project_model.g.dart';

@JsonSerializable()
class ProjectModel {
  @JsonKey(fromJson: _intFromJson)
  final int id;
  final String name;
  final String? description;
  final String? address;
  final double? latitude;
  final double? longitude;
  @JsonKey(name: 'start_date')
  final String? startDate;
  @JsonKey(name: 'end_date')
  final String? endDate;
  @JsonKey(fromJson: _budgetFromJson)
  final double budget;
  final String status;
  @JsonKey(fromJson: _intFromJson)
  final int progress;
  @JsonKey(name: 'client_name')
  final String? clientName;
  @JsonKey(name: 'client_contact')
  final String? clientContact;
  @JsonKey(name: 'company_id', fromJson: _intFromJson)
  final int companyId;
  @JsonKey(name: 'created_by', fromJson: _intFromJson)
  final int createdBy;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;
  
  // Relations
  final UserModel? creator;
  final CompanyModel? company;

  ProjectModel({
    required this.id,
    required this.name,
    this.description,
    this.address,
    this.latitude,
    this.longitude,
    this.startDate,
    this.endDate,
    required this.budget,
    required this.status,
    required this.progress,
    this.clientName,
    this.clientContact,
    required this.companyId,
    required this.createdBy,
    this.createdAt,
    this.updatedAt,
    this.creator,
    this.company,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) =>
      _$ProjectModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProjectModelToJson(this);

  static double _budgetFromJson(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value);
      return parsed ?? 0.0;
    }
    return 0.0;
  }

  static int _intFromJson(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toInt();
    if (value is String) {
      final parsed = int.tryParse(value);
      return parsed ?? 0;
    }
    return 0;
  }

  String get statusLabel {
    switch (status) {
      case 'non_demarre':
        return 'Non démarré';
      case 'en_cours':
        return 'En cours';
      case 'termine':
        return 'Terminé';
      case 'bloque':
        return 'Bloqué';
      default:
        return status;
    }
  }
}

