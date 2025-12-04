import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  @JsonKey(fromJson: _idFromJson)
  final int id;
  final String name;
  final String email;
  @JsonKey(name: 'is_super_admin')
  final bool isSuperAdmin;
  @JsonKey(name: 'is_verified')
  final bool isVerified;
  @JsonKey(name: 'current_company_id', fromJson: _currentCompanyIdFromJson)
  final int? currentCompanyId;
  final String? avatar;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.isSuperAdmin = false,
    this.isVerified = false,
    this.currentCompanyId,
    this.avatar,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  // Helper function to safely parse id
  static int _idFromJson(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) {
      final parsed = int.tryParse(value);
      if (parsed != null) return parsed;
    }
    throw FormatException('Invalid id value: $value');
  }

  // Helper function to safely parse current_company_id
  static int? _currentCompanyIdFromJson(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) {
      final parsed = int.tryParse(value);
      return parsed;
    }
    return null;
  }
}

