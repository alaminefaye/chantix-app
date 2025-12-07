import 'package:json_annotation/json_annotation.dart';
import 'material_model.dart';

part 'project_material_model.g.dart';

@JsonSerializable()
class ProjectMaterialModel {
  @JsonKey(fromJson: _materialFromJson)
  final MaterialModel material;
  @JsonKey(name: 'quantity_planned', fromJson: _doubleFromJson)
  final double quantityPlanned;
  @JsonKey(name: 'quantity_ordered', fromJson: _doubleFromJson)
  final double quantityOrdered;
  @JsonKey(name: 'quantity_delivered', fromJson: _doubleFromJson)
  final double quantityDelivered;
  @JsonKey(name: 'quantity_used', fromJson: _doubleFromJson)
  final double quantityUsed;
  @JsonKey(name: 'quantity_remaining', fromJson: _doubleFromJson)
  final double quantityRemaining;
  final String? notes;

  ProjectMaterialModel({
    required this.material,
    required this.quantityPlanned,
    required this.quantityOrdered,
    required this.quantityDelivered,
    required this.quantityUsed,
    required this.quantityRemaining,
    this.notes,
  });

  factory ProjectMaterialModel.fromJson(Map<String, dynamic> json) =>
      _$ProjectMaterialModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProjectMaterialModelToJson(this);

  static double _doubleFromJson(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value);
      return parsed ?? 0.0;
    }
    return 0.0;
  }

  static MaterialModel _materialFromJson(dynamic value) {
    if (value is Map<String, dynamic>) {
      return MaterialModel.fromJson(value);
    }
    // Si c'est déjà un MaterialModel (dans le pivot)
    throw Exception('Material data format not supported');
  }

  bool get isOverConsumption => quantityUsed > quantityPlanned;
  
  double get usagePercentage {
    if (quantityPlanned == 0) return 0;
    return (quantityUsed / quantityPlanned * 100).clamp(0, 100);
  }
}

