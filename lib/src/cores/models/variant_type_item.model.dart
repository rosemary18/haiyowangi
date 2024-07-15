class VariantTypeItem {
  
  final int id;
  final String? name;
  final int? variantTypeId;
  final String? createdAt;

  VariantTypeItem({
    required this.id,
    this.name = "",
    this.variantTypeId,
    this.createdAt = "",
  });

  factory VariantTypeItem.fromJson(Map<String, dynamic> json) {
    return VariantTypeItem(
      id: json["id"],
      name: json["name"] ?? "",
      variantTypeId: json["variant_type_id"],
      createdAt: json["created_at"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "variant_type_id": variantTypeId,
      "created_at": createdAt
    };
  }
  
}