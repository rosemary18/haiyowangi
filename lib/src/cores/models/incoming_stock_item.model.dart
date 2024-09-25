import 'package:haiyowangi/src/index.dart';

class IncomingStockItemModel {

  final int id;
  final int? incomingStockId;
  final int? productId;
  final int? variantId;
  final int? ingredientId;
  final double? qty;
  final String? createdAt;
  final String? updatedAt;
  final ProductModel? product;
  final VariantModel? variant;
  final IngredientModel? ingredient;

  IncomingStockItemModel({
    required this.id,
    this.incomingStockId,
    this.productId,
    this.variantId,
    this.ingredientId,
    this.qty = 0,
    this.createdAt = "",
    this.updatedAt = "",
    this.product,
    this.variant,
    this.ingredient
  });

  factory IncomingStockItemModel.fromJson(Map<String, dynamic> json) {
    return IncomingStockItemModel(
      id: json["id"],
      incomingStockId: json["incoming_stock_id"],
      productId: json["product_id"],
      variantId: json["variant_id"],
      ingredientId: json["ingredient_id"],
      qty: double.tryParse(json["qty"].toString()) ?? 0,
      createdAt: json["created_at"] ?? "",
      updatedAt: json["updated_at"] ?? "",
      product: (json["product"] == null) ? null : ProductModel.fromJson(json["product"]),
      variant: (json["variant"] == null) ? null : VariantModel.fromJson(json["variant"]),
      ingredient: (json["ingredient"] == null) ? null : IngredientModel.fromJson(json["ingredient"]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "incoming_stock_id": incomingStockId,
      "product_id": productId,
      "variant_id": variantId,
      "ingredient_id": ingredientId,
      "qty": qty,
      "created_at": createdAt,
      "updated_at": updatedAt,
      "product": product?.toJson(),
      "variant": variant?.toJson(),
      "ingredient": ingredient?.toJson()
    };
  }

}