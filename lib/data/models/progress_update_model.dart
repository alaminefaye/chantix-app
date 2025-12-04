import 'package:json_annotation/json_annotation.dart';
import 'user_model.dart';

part 'progress_update_model.g.dart';

@JsonSerializable()
class ProgressUpdateModel {
  final int id;
  @JsonKey(name: 'project_id')
  final int projectId;
  @JsonKey(name: 'user_id')
  final int userId;
  final int progress;
  final String? description;
  @JsonKey(name: 'audio_report')
  final String? audioReport;
  final double? latitude;
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

  factory ProgressUpdateModel.fromJson(Map<String, dynamic> json) =>
      _$ProgressUpdateModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProgressUpdateModelToJson(this);
}

