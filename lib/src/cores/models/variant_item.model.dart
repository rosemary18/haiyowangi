import 'package:haiyowangi/src/index.dart';

class VariantItemModel {
  
  final int id;
  final int? variantId;
  final int? variantTypeItemId;
  final String? createdAt;
  final VariantTypeItemModel? variantTypeItem;

  VariantItemModel({
    required this.id,
    this.variantId,
    this.variantTypeItemId,
    this.createdAt = "",
    this.variantTypeItem
  });

  factory VariantItemModel.fromJson(Map<String, dynamic> json) {
    return VariantItemModel(
      id: json["id"],
      variantId: json["variant_id"],
      variantTypeItemId: json["variant_type_item_id"],
      createdAt: json["created_at"] ?? "",
      variantTypeItem: json["variant_type_item"] != null ? VariantTypeItemModel.fromJson(json["variant_type_item"]) : null
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "variant_id": variantId,
      "variant_type_item_id": variantTypeItemId,
      "created_at": createdAt,
      "variant_type_item": variantTypeItem
    };
  }

}