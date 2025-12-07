import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'project_model.dart';
import 'user_model.dart';
import 'employee_model.dart';

part 'task_model.g.dart';

@JsonSerializable()
class TaskModel {
  @JsonKey(fromJson: _intFromJson)
  final int id;
  @JsonKey(name: 'project_id', fromJson: _intFromJson)
  final int projectId;
  @JsonKey(name: 'created_by', fromJson: _intFromJson)
  final int createdBy;
  @JsonKey(name: 'assigned_to', fromJson: _intNullableFromJson)
  final int? assignedTo;
  final String title;
  final String? description;
  final String? category;
  final String status;
  final String priority;
  @JsonKey(name: 'start_date')
  final String? startDate;
  final String? deadline;
  @JsonKey(fromJson: _progressFromJson)
  final int progress;
  final String? notes;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  // Relations
  final ProjectModel? project;
  final UserModel? creator;
  final EmployeeModel? assignedEmployee;

  TaskModel({
    required this.id,
    required this.projectId,
    required this.createdBy,
    this.assignedTo,
    required this.title,
    this.description,
    this.category,
    required this.status,
    required this.priority,
    this.startDate,
    this.deadline,
    this.progress = 0,
    this.notes,
    this.createdAt,
    this.updatedAt,
    this.project,
    this.creator,
    this.assignedEmployee,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) =>
      _$TaskModelFromJson(json);

  Map<String, dynamic> toJson() => _$TaskModelToJson(this);

  // Helper functions to convert from JSON (handles both String and num)
  static int _intFromJson(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toInt();
    if (value is String) {
      final parsed = int.tryParse(value);
      return parsed ?? 0;
    }
    return 0;
  }

  static int? _intNullableFromJson(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toInt();
    if (value is String) {
      final parsed = int.tryParse(value);
      return parsed;
    }
    return null;
  }

  static int _progressFromJson(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toInt();
    if (value is String) {
      // Remove any percentage sign and parse
      final cleaned = value.replaceAll('%', '').trim();
      return int.tryParse(cleaned) ?? 0;
    }
    return 0;
  }

  String get statusLabel {
    switch (status) {
      case 'a_faire':
        return 'À faire';
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

  String get priorityLabel {
    switch (priority) {
      case 'basse':
        return 'Basse';
      case 'moyenne':
        return 'Moyenne';
      case 'haute':
        return 'Haute';
      case 'urgente':
        return 'Urgente';
      default:
        return priority;
    }
  }

  Color get statusColor {
    switch (status) {
      case 'a_faire':
        return Colors.grey;
      case 'en_cours':
        return Colors.blue;
      case 'termine':
        return Colors.green;
      case 'bloque':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color get priorityColor {
    switch (priority) {
      case 'basse':
        return Colors.green;
      case 'moyenne':
        return Colors.blue;
      case 'haute':
        return Colors.orange;
      case 'urgente':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  bool get isOverdue {
    if (deadline == null || status == 'termine') return false;
    try {
      final deadlineDate = DateTime.parse(deadline!);
      return DateTime.now().isAfter(deadlineDate);
    } catch (e) {
      return false;
    }
  }

  bool get isDueSoon {
    if (deadline == null || status == 'termine') return false;
    try {
      final deadlineDate = DateTime.parse(deadline!);
      final now = DateTime.now();
      final difference = deadlineDate.difference(now).inDays;
      return difference <= 3 && difference >= 0;
    } catch (e) {
      return false;
    }
  }
}
