// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project_material_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProjectMaterialModel _$ProjectMaterialModelFromJson(
        Map<String, dynamic> json) =>
    ProjectMaterialModel(
      material: ProjectMaterialModel._materialFromJson(json['material']),
      quantityPlanned:
          ProjectMaterialModel._doubleFromJson(json['quantity_planned']),
      quantityOrdered:
          ProjectMaterialModel._doubleFromJson(json['quantity_ordered']),
      quantityDelivered:
          ProjectMaterialModel._doubleFromJson(json['quantity_delivered']),
      quantityUsed: ProjectMaterialModel._doubleFromJson(json['quantity_used']),
      quantityRemaining:
          ProjectMaterialModel._doubleFromJson(json['quantity_remaining']),
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$ProjectMaterialModelToJson(
        ProjectMaterialModel instance) =>
    <String, dynamic>{
      'material': instance.material,
      'quantity_planned': instance.quantityPlanned,
      'quantity_ordered': instance.quantityOrdered,
      'quantity_delivered': instance.quantityDelivered,
      'quantity_used': instance.quantityUsed,
      'quantity_remaining': instance.quantityRemaining,
      'notes': instance.notes,
    };
