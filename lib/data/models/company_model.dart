import 'package:json_annotation/json_annotation.dart';

part 'company_model.g.dart';

@JsonSerializable()
class CompanyModel {
  final int id;
  final String name;
  final String? description;
  final String? logo;
  final String? address;
  final String? phone;
  final String? email;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  CompanyModel({
    required this.id,
    required this.name,
    this.description,
    this.logo,
    this.address,
    this.phone,
    this.email,
    this.createdAt,
    this.updatedAt,
  });

  factory CompanyModel.fromJson(Map<String, dynamic> json) =>
      _$CompanyModelFromJson(json);

  Map<String, dynamic> toJson() => _$CompanyModelToJson(this);
}

