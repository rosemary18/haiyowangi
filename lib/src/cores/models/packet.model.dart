class Packet {

  final int id;
  final String? name;
  final String? description;
  final double? price;
  final bool? isPublished;
  final int? storeId;
  final String? createdAt;
  final String? updatedAt;

  Packet({
    required this.id,
    this.name = "",
    this.description = "",
    this.price = 0,
    this.isPublished = false,
    this.storeId,
    this.createdAt = "",
    this.updatedAt = "",
  });

  factory Packet.fromJson(Map<String, dynamic> json) {
    return Packet(
      id: json["id"],
      name: json["name"] ?? "",
      description: json["description"] ?? "",
      price: json["price"] ?? 0,
      isPublished: json["is_published"] ?? false,
      storeId: json["store_id"],
      createdAt: json["created_at"] ?? "",
      updatedAt: json["updated_at"] ?? "",
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
      "updated_at": updatedAt
    };
  }

}