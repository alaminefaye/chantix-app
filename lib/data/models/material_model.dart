import 'package:json_annotation/json_annotation.dart';

part 'material_model.g.dart';

@JsonSerializable()
class MaterialModel {
  @JsonKey(fromJson: _intFromJson)
  final int id;
  @JsonKey(name: 'company_id', fromJson: _intFromJson)
  final int companyId;
  final String name;
  final String? description;
  final String? category;
  final String? unit;
  @JsonKey(name: 'unit_price', fromJson: _priceFromJson)
  final double? unitPrice;
  final String? supplier;
  final String? reference;
  @JsonKey(name: 'stock_quantity', fromJson: _quantityFromJson)
  final double? stockQuantity;
  @JsonKey(name: 'min_stock', fromJson: _quantityFromJson)
  final double? minStock;
  @JsonKey(name: 'is_active')
  final bool isActive;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  MaterialModel({
    required this.id,
    required this.companyId,
    required this.name,
    this.description,
    this.category,
    this.unit,
    this.unitPrice,
    this.supplier,
    this.reference,
    this.stockQuantity,
    this.minStock,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory MaterialModel.fromJson(Map<String, dynamic> json) =>
      _$MaterialModelFromJson(json);

  Map<String, dynamic> toJson() => _$MaterialModelToJson(this);

  // Helper functions for safe parsing
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

  static double? _priceFromJson(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value);
      return parsed;
    }
    return null;
  }

  static double? _quantityFromJson(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value);
      return parsed;
    }
    return null;
  }

  bool get isLowStock {
    if (stockQuantity == null || minStock == null) return false;
    return stockQuantity! <= minStock!;
  }
}

