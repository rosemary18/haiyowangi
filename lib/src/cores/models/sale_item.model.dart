class SaleItem {

  final int id;
  final int? salesId;
  final double? qty;
  final int? productId;
  final int? variantId;
  final int? packetId;
  final String? createdAt;

  SaleItem({
    required this.id,
    this.salesId,
    this.qty = 0,
    this.productId,
    this.variantId,
    this.packetId,
    this.createdAt = "",
  });

  factory SaleItem.fromJson(Map<String, dynamic> json) {
    return SaleItem(
      id: json["id"],
      salesId: json["sales_id"],
      qty: json["qty"] ?? 0,
      productId: json["product_id"],
      variantId: json["variant_id"],
      packetId: json["packet_id"],
      createdAt: json["created_at"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "sales_id": salesId,
      "qty": qty,
      "product_id": productId,
      "variant_id": variantId,
      "packet_id": packetId,
      "created_at": createdAt
    };
  }

}