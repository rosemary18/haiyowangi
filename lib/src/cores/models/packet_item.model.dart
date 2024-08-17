class PacketItemModel {
  
  final int id;
  final int? packetId;
  final int? productId;
  final int? variantId;
  final double? qty;
  final String? createdAt;
  final String? updatedAt;

  PacketItemModel({
    required this.id,
    this.packetId,
    this.productId,
    this.variantId,
    this.qty = 0,
    this.createdAt = "",
    this.updatedAt = "",
  });

  factory PacketItemModel.fromJson(Map<String, dynamic> json) {
    return PacketItemModel(
      id: json["id"],
      packetId: json["packet_id"],
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
      "packet_id": packetId,
      "product_id": productId,
      "variant_id": variantId,
      "qty": qty,
      "created_at": createdAt,
      "updated_at": updatedAt
    };
  }
  
}