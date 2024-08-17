class IncomingStockItemModel {

  final int id;
  final int? incomingStockId;
  final int? productId;
  final int? variantId;
  final double? qty;
  final String? createdAt;
  final String? updatedAt;

  IncomingStockItemModel({
    required this.id,
    this.incomingStockId,
    this.productId,
    this.variantId,
    this.qty = 0,
    this.createdAt = "",
    this.updatedAt = "",
  });

  factory IncomingStockItemModel.fromJson(Map<String, dynamic> json) {
    return IncomingStockItemModel(
      id: json["id"],
      incomingStockId: json["incoming_stock_id"],
      productId: json["product_id"],
      variantId: json["variant_id"],
      qty: json["qty"] ?? 0,
      createdAt: json["created_at"] ?? "",
      updatedAt: json["updated_at"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "incoming_stock_id": incomingStockId,
      "product_id": productId,
      "variant_id": variantId,
      "qty": qty,
      "created_at": createdAt,
      "updated_at": updatedAt
    };
  }

}