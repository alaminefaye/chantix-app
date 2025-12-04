import 'package:json_annotation/json_annotation.dart';
import 'project_model.dart';
import 'user_model.dart';

part 'comment_model.g.dart';

@JsonSerializable()
class CommentModel {
  final int id;
  @JsonKey(name: 'project_id')
  final int projectId;
  @JsonKey(name: 'user_id')
  final int userId;
  @JsonKey(name: 'parent_id')
  final int? parentId;
  final String content;
  @JsonKey(name: 'mentioned_users')
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
}

