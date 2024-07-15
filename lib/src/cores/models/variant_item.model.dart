class VariantItem {
  
  final int id;
  final int? variantId;
  final int? variantTypeItemId;
  final String? createdAt;

  VariantItem({
    required this.id,
    this.variantId,
    this.variantTypeItemId,
    this.createdAt = "",
  });

  factory VariantItem.fromJson(Map<String, dynamic> json) {
    return VariantItem(
      id: json["id"],
      variantId: json["variant_id"],
      variantTypeItemId: json["variant_type_item_id"],
      createdAt: json["created_at"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "variant_id": variantId,
      "variant_type_item_id": variantTypeItemId,
      "created_at": createdAt
    };
  }

}