import 'package:json_annotation/json_annotation.dart';
import 'user_model.dart';

part 'progress_update_model.g.dart';

// Converters pour gérer les conversions String/num
int _intFromJson(dynamic value) {
  if (value is int) return value;
  if (value is String) return int.tryParse(value) ?? 0;
  if (value is num) return value.toInt();
  return 0;
}

double? _doubleFromJson(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value);
  if (value is num) return value.toDouble();
  return null;
}

@JsonSerializable()
class ProgressUpdateModel {
  final int id;
  @JsonKey(name: 'project_id', fromJson: _intFromJson)
  final int projectId;
  @JsonKey(name: 'user_id', fromJson: _intFromJson)
  final int userId;
  @JsonKey(fromJson: _intFromJson)
  final int progress;
  final String? description;
  @JsonKey(name: 'audio_report')
  final String? audioReport;
  @JsonKey(fromJson: _doubleFromJson)
  final double? latitude;
  @JsonKey(fromJson: _doubleFromJson)
  final double? longitude;
  final List<String>? photos;
  final List<String>? videos;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;
  
  // Relations
  final UserModel? user;

  ProgressUpdateModel({
    required this.id,
    required this.projectId,
    required this.userId,
    required this.progress,
    this.description,
    this.audioReport,
    this.latitude,
    this.longitude,
    this.photos,
    this.videos,
    this.createdAt,
    this.updatedAt,
    this.user,
  });

  factory ProgressUpdateModel.fromJson(Map<String, dynamic> json) {
    try {
      // Utiliser la fonction générée qui gère déjà les conversions avec _intFromJson et _doubleFromJson
      return _$ProgressUpdateModelFromJson(json);
    } catch (e) {
      throw Exception('Erreur lors du parsing ProgressUpdateModel: $e. Données: $json');
    }
  }

  Map<String, dynamic> toJson() => _$ProgressUpdateModelToJson(this);
}

