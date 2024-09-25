import 'package:haiyowangi/src/index.dart';

class PacketModel {

  final int id;
  final String? name;
  final String? description;
  final int price;
  final bool? isPublished;
  final int? storeId;
  final String? createdAt;
  final String? updatedAt;
  final List<PacketItemModel> items;
  final List<DiscountModel> discounts;

  PacketModel({
    required this.id,
    this.name = "",
    this.description = "",
    this.price = 0,
    this.isPublished = false,
    this.storeId,
    this.createdAt = "",
    this.updatedAt = "",
    this.items = const [],
    this.discounts = const [],
  });

  factory PacketModel.fromJson(Map<String, dynamic> json) {
    return PacketModel(
      id: json["id"],
      name: json["name"] ?? "",
      description: json["description"] ?? "",
      price: json["price"] ?? 0,
      isPublished: json["is_published"] ?? false,
      storeId: json["store_id"],
      createdAt: json["created_at"] ?? "",
      updatedAt: json["updated_at"] ?? "",
      items: json["items"] == null ? [] : (json["items"] as List).map((e) => PacketItemModel.fromJson(e)).toList(),
      discounts: json["discounts"] == null ? [] : (json["discounts"] as List).map((e) => DiscountModel.fromJson(e)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "description": description,
      "price": price,
      "is_published": isPublished,
      "store_id": storeId,
      "created_at": createdAt,
      "updated_at": updatedAt,
      "items": items,
      "discounts": discounts
    };
  }

}