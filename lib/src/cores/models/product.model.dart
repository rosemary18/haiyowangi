class ProductModel {

  final int id;
  final String name;
  final String? img;
  final String? description;
  final double? qty;
  final double? buyPrice;
  final double? price;
  final bool? hasVariants;
  final bool? isPublished;
  final int? unitId;
  final int? storeId;
  final String? createdAt;
  final String? updatedAt;

  ProductModel({
    required this.id,
    required this.name,
    this.img = "",
    this.description = "",
    this.qty = 0,
    this.buyPrice = 0,
    this.price = 0,
    this.hasVariants = false,
    this.isPublished = false,
    this.unitId,
    this.storeId,
    this.createdAt = "",
    this.updatedAt = "",
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json["id"],
      name: json["name"] ?? "",
      img: json["img"] ?? "",
      description: json["description"] ?? "",
      qty: json["qty"] ?? 0,
      buyPrice: json["buy_price"] ?? 0,
      price: json["price"] ?? 0,
      hasVariants: json["has_variants"] ?? false,
      isPublished: json["is_published"] ?? false,
      unitId: json["unit_id"],
      storeId: json["store_id"],
      createdAt: json["created_at"] ?? "",
      updatedAt: json["updated_at"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "img": img,
      "description": description,
      "qty": qty,
      "buy_price": buyPrice,
      "price": price,
      "has_variants": hasVariants,
      "is_published": isPublished,
      "unit_id": unitId,
      "store_id": storeId,
      "created_at": createdAt,
      "updated_at": updatedAt
    };
  }

}