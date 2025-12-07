import 'package:json_annotation/json_annotation.dart';
import 'project_model.dart';
import 'user_model.dart';

part 'comment_model.g.dart';

@JsonSerializable()
class CommentModel {
  @JsonKey(fromJson: _intFromJson)
  final int id;
  @JsonKey(name: 'project_id', fromJson: _intFromJson)
  final int projectId;
  @JsonKey(name: 'user_id', fromJson: _intFromJson)
  final int userId;
  @JsonKey(name: 'parent_id', fromJson: _intFromJsonNullable)
  final int? parentId;
  final String content;
  @JsonKey(name: 'mentioned_users', fromJson: _intListFromJson)
  final List<int>? mentionedUsers;
  final List<Map<String, dynamic>>? attachments;
  @JsonKey(name: 'is_read')
  final bool isRead;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  // Relations
  final ProjectModel? project;
  final UserModel? user;
  @JsonKey(name: 'replies')
  final List<CommentModel>? replies;

  CommentModel({
    required this.id,
    required this.projectId,
    required this.userId,
    this.parentId,
    required this.content,
    this.mentionedUsers,
    this.attachments,
    this.isRead = false,
    this.createdAt,
    this.updatedAt,
    this.project,
    this.user,
    this.replies,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) =>
      _$CommentModelFromJson(json);

  Map<String, dynamic> toJson() => _$CommentModelToJson(this);

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

  static List<int>? _intListFromJson(dynamic value) {
    if (value == null) return null;
    if (value is List) {
      return value.map((e) {
        if (e is int) return e;
        if (e is num) return e.toInt();
        if (e is String) {
          final parsed = int.tryParse(e);
          return parsed ?? 0;
        }
        return 0;
      }).toList();
    }
    return null;
  }
}

