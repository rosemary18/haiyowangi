import 'package:haiyowangi/src/index.dart';

class PacketItemModel {
  
  final int id;
  final int? packetId;
  final int? productId;
  final int? variantId;
  final double? qty;
  final String? createdAt;
  final String? updatedAt;
  final ProductModel? product;
  final VariantModel? variant;

  PacketItemModel({
    required this.id,
    this.packetId,
    this.productId,
    this.variantId,
    this.qty = 0,
    this.createdAt = "",
    this.updatedAt = "",
    this.product,
    this.variant
  });

  factory PacketItemModel.fromJson(Map<String, dynamic> json) {
    return PacketItemModel(
      id: json["id"],
      packetId: json["packet_id"],
      productId: json["product_id"],
      variantId: json["variant_id"],
      qty: double.parse(json["qty"].toString()),
      createdAt: json["created_at"] ?? "",
      updatedAt: json["updated_at"] ?? "",
      product: json["product"] == null ? null : ProductModel.fromJson(json["product"]),
      variant: json["variant"] == null ? null : VariantModel.fromJson(json["variant"]),
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
      "updated_at": updatedAt,
      "product": product,
      "variant": variant
    };
  }
  
}