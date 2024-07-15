class VariantType { 

  final int id;
  final int? productId;
  final String? name;
  final String? createdAt;

  VariantType({
    required this.id,
    this.productId,
    this.name = "",
    this.createdAt = "",
  });

  factory VariantType.fromJson(Map<String, dynamic> json) {
    return VariantType(
      id: json["id"],
      productId: json["product_id"],
      name: json["name"] ?? "",
      createdAt: json["created_at"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "product_id": productId,
      "name": name,
      "created_at": createdAt
    };
  }
  
}