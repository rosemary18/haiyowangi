import 'package:haiyowangi/src/index.dart';

class SaleItemModel {

  final int? id;
  final int? salesId;
  double? qty;
  int? productId;
  int? variantId;
  int? packetId;
  final String? createdAt;
  ProductModel? product;
  VariantModel? variant;
  PacketModel? packet;

  SaleItemModel({
    this.id,
    this.salesId,
    this.qty = 0,
    this.productId,
    this.variantId,
    this.packetId,
    this.createdAt = "",
    this.product,
    this.variant,
    this.packet
  });

  factory SaleItemModel.fromJson(Map<String, dynamic> json) {
    return SaleItemModel(
      id: json["id"],
      salesId: json["sales_id"],
      qty: double.parse(json["qty"].toString()),
      productId: json["product_id"],
      variantId: json["variant_id"],
      packetId: json["packet_id"],
      createdAt: json["created_at"] ?? "",
      product: (json["product"] != null) ? ProductModel.fromJson(json["product"]) : null,
      variant: (json["variant"] != null) ? VariantModel.fromJson(json["variant"]) : null,
      packet: (json["packet"] != null) ? PacketModel.fromJson(json["packet"]) : null
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
      "created_at": createdAt,
      "product": product?.toJson(),
      "variant": variant?.toJson(),
      "packet": packet?.toJson()
    };
  }

}