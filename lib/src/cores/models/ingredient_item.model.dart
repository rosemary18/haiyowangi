import 'package:haiyowangi/src/index.dart';

class IngredientItemModel {

  final int id;
  final int? productId;
  final int? variantId;
  final int? ingredientId;
  double? qty;
  final int? unitId;
  final String? createdAt;
  final String? updatedAt;
  ProductModel? product;
  VariantModel? variant;
  IngredientModel? ingredient;

  IngredientItemModel({
    required this.id,
    this.productId,
    this.variantId,
    this.ingredientId,
    this.qty = 0,
    this.unitId,
    this.createdAt = "",
    this.updatedAt = "",
    this.product,
    this.variant,
    this.ingredient
  });

  factory IngredientItemModel.fromJson(Map<String, dynamic> json) {
    return IngredientItemModel(
      id: json["id"],
      productId: json["product_id"],
      variantId: json["variant_id"],
      ingredientId: json["ingredient_id"],
      qty: double.parse(json["qty"].toString()),
      unitId: json["unit_id"],
      createdAt: json["created_at"] ?? "",
      updatedAt: json["updated_at"] ?? "",
      product: (json["product"] != null) ? ProductModel.fromJson(json["product"]) : null,
      variant: (json["variant"] != null) ? VariantModel.fromJson(json["variant"]) : null,
      ingredient: (json["ingredient"] != null) ? IngredientModel.fromJson(json["ingredient"]) : null
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "product_id": productId,
      "variant_id": variantId,
      "ingredient_id": ingredientId,
      "qty": qty,
      "unit_id": unitId,
      "created_at": createdAt,
      "updated_at": updatedAt,
      "product": product?.toJson(),
      "variant": variant?.toJson(),
      "ingredient": ingredient?.toJson()
    };
  }

}