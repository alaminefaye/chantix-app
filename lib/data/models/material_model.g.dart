// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'material_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MaterialModel _$MaterialModelFromJson(Map<String, dynamic> json) =>
    MaterialModel(
      id: (json['id'] as num).toInt(),
      companyId: (json['company_id'] as num).toInt(),
      name: json['name'] as String,
      description: json['description'] as String?,
      category: json['category'] as String?,
      unit: json['unit'] as String?,
      unitPrice: MaterialModel._priceFromJson(json['unit_price']),
      supplier: json['supplier'] as String?,
      reference: json['reference'] as String?,
      stockQuantity: MaterialModel._quantityFromJson(json['stock_quantity']),
      minStock: MaterialModel._quantityFromJson(json['min_stock']),
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );

Map<String, dynamic> _$MaterialModelToJson(MaterialModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'company_id': instance.companyId,
      'name': instance.name,
      'description': instance.description,
      'category': instance.category,
      'unit': instance.unit,
      'unit_price': instance.unitPrice,
      'supplier': instance.supplier,
      'reference': instance.reference,
      'stock_quantity': instance.stockQuantity,
      'min_stock': instance.minStock,
      'is_active': instance.isActive,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };
