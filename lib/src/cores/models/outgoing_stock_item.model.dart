class OutgoingStockItem {
  
  final int id;
  final int? outgoingStockId;
  final int? productId;
  final int? variantId;
  final double? qty;
  final String? createdAt;
  final String? updatedAt;

  OutgoingStockItem({
    required this.id,
    this.outgoingStockId,
    this.productId,
    this.variantId,
    this.qty = 0,
    this.createdAt = "",
    this.updatedAt = "",
  });

  factory OutgoingStockItem.fromJson(Map<String, dynamic> json) {
    return OutgoingStockItem(
      id: json["id"],
      outgoingStockId: json["outgoing_stock_id"],
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
      "outgoing_stock_id": outgoingStockId,
      "product_id": productId,
      "variant_id": variantId,
      "qty": qty,
      "created_at": createdAt,
      "updated_at": updatedAt
    };
  }
  
}