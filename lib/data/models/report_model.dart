import 'package:json_annotation/json_annotation.dart';
import 'project_model.dart';
import 'user_model.dart';

part 'report_model.g.dart';

@JsonSerializable()
class ReportModel {
  final int id;
  @JsonKey(name: 'project_id')
  final int projectId;
  @JsonKey(name: 'created_by')
  final int createdBy;
  final String type;
  @JsonKey(name: 'report_date')
  final String reportDate;
  @JsonKey(name: 'end_date')
  final String? endDate;
  final Map<String, dynamic>? data;
  @JsonKey(name: 'file_path')
  final String? filePath;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  // Relations
  final ProjectModel? project;
  final UserModel? creator;

  ReportModel({
    required this.id,
    required this.projectId,
    required this.createdBy,
    required this.type,
    required this.reportDate,
    this.endDate,
    this.data,
    this.filePath,
    this.createdAt,
    this.updatedAt,
    this.project,
    this.creator,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) =>
      _$ReportModelFromJson(json);

  Map<String, dynamic> toJson() => _$ReportModelToJson(this);

  String get typeLabel {
    switch (type) {
      case 'journalier':
        return 'Rapport Journalier';
      case 'hebdomadaire':
        return 'Rapport Hebdomadaire';
      default:
        return type;
    }
  }
}

