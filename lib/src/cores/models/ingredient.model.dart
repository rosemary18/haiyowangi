class Ingredient {
  
  final int id;
  final String? name;
  final String? img;
  final double? qty;
  final int? unitId;
  final int? storeId;
  final String? createdAt;
  final String? updatedAt;

  Ingredient({
    required this.id,
    this.name = "",
    this.img = "",
    this.qty = 0,
    this.unitId,
    this.storeId,
    this.createdAt = "",
    this.updatedAt = "",
  });

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      id: json["id"],
      name: json["name"] ?? "",
      img: json["img"] ?? "",
      qty: json["qty"] ?? 0,
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
      "qty": qty,
      "unit_id": unitId,
      "store_id": storeId,
      "created_at": createdAt,
      "updated_at": updatedAt
    };
  }

}