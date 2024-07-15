class OfficeInventory {

  final int id;
  final int? storeId;
  final String? name;
  final double? price;
  final String? buyDate;
  final double? qty;
  final int? goodsCondition;
  final String? createdAt;
  final String? updatedAt;

  OfficeInventory({
    required this.id,
    this.storeId,
    this.name = "",
    this.price = 0,
    this.buyDate,
    this.qty = 0,
    this.goodsCondition = 0,
    this.createdAt = "",
    this.updatedAt = "",
  });

  factory OfficeInventory.fromJson(Map<String, dynamic> json) {
    return OfficeInventory(
      id: json["id"],
      storeId: json["store_id"],
      name: json["name"] ?? "",
      price: json["price"] ?? 0,
      buyDate: json["buy_date"] ?? "",
      qty: json["qty"] ?? 0,
      goodsCondition: json["goods_condition"] ?? 0,
      createdAt: json["created_at"] ?? "",
      updatedAt: json["updated_at"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "store_id": storeId,
      "name": name,
      "price": price,
      "buy_date": buyDate,
      "qty": qty,
      "goods_condition": goodsCondition,
      "created_at": createdAt,
      "updated_at": updatedAt
    };
  }

}