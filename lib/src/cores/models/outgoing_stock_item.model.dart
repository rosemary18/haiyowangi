import 'package:haiyowangi/src/index.dart';

class OutgoingStockItemModel {
  
  final int id;
  final int? outgoingStockId;
  final int? productId;
  final int? variantId;
  final int? ingredientId;
  final double? qty;
  final String? createdAt;
  final String? updatedAt;
  final ProductModel? product;
  final VariantModel? variant;
  final IngredientModel? ingredient;

  OutgoingStockItemModel({
    required this.id,
    this.outgoingStockId,
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

  factory OutgoingStockItemModel.fromJson(Map<String, dynamic> json) {
    return OutgoingStockItemModel(
      id: json["id"],
      outgoingStockId: json["outgoing_stock_id"],
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
      "outgoing_stock_id": outgoingStockId,
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