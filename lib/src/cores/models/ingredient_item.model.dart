class IngredientItemModel {

  final int id;
  final int? productId;
  final int? variantId;
  final int? ingredientId;
  final double? qty;
  final int? unitId;
  final String? createdAt;
  final String? updatedAt;

  IngredientItemModel({
    required this.id,
    this.productId,
    this.variantId,
    this.ingredientId,
    this.qty = 0,
    this.unitId,
    this.createdAt = "",
    this.updatedAt = "",
  });

  factory IngredientItemModel.fromJson(Map<String, dynamic> json) {
    return IngredientItemModel(
      id: json["id"],
      productId: json["product_id"],
      variantId: json["variant_id"],
      ingredientId: json["ingredient_id"],
      qty: json["qty"] ?? 0,
      unitId: json["unit_id"],
      createdAt: json["created_at"] ?? "",
      updatedAt: json["updated_at"] ?? "",
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
      "updated_at": updatedAt
    };
  }

}