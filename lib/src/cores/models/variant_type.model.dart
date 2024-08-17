class VariantTypeModel { 

  final int id;
  final int? productId;
  final String? name;
  final String? createdAt;

  VariantTypeModel({
    required this.id,
    this.productId,
    this.name = "",
    this.createdAt = "",
  });

  factory VariantTypeModel.fromJson(Map<String, dynamic> json) {
    return VariantTypeModel(
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