class VariantModel {

  final int id;
  final int? productId;
  final String? name;
  final String? img;
  final String? description;
  final double? buyPrice;
  final double? qty;
  final double? price;
  final int? unitId;
  final int? storeId;
  final bool? isPublished;
  final String? createdAt;
  final String? updatedAt;

  VariantModel({
    required this.id,
    this.productId,
    this.name = "",
    this.img = "",
    this.description = "",
    this.buyPrice = 0,
    this.qty = 0,
    this.price = 0,
    this.unitId,
    this.storeId,
    this.isPublished = false,
    this.createdAt = "",
    this.updatedAt = "",
  });

  factory VariantModel.fromJson(Map<String, dynamic> json) {
    return VariantModel(
      id: json["id"],
      productId: json["product_id"],
      name: json["name"] ?? "",
      img: json["img"] ?? "",
      description: json["description"] ?? "",
      buyPrice: json["buy_price"] ?? 0,
      qty: json["qty"] ?? 0,
      price: json["price"] ?? 0,
      unitId: json["unit_id"],
      storeId: json["store_id"],
      isPublished: json["is_published"] ?? false,
      createdAt: json["created_at"] ?? "",
      updatedAt: json["updated_at"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "product_id": productId,
      "name": name,
      "img": img,
      "description": description,
      "buy_price": buyPrice,
      "qty": qty,
      "price": price,
      "unit_id": unitId,
      "store_id": storeId,
      "is_published": isPublished,
      "created_at": createdAt,
      "updated_at": updatedAt
    };
  }

}