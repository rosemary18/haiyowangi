import 'user.model.dart';

class Store {

  final int id;
  final String? name;
  final String? address;
  final String? storeImage;
  final bool isActive;
  final String? lastSync;
  final int? ownerId;
  final User? owner;
  final String? createdAt;
  final String? updatedAt;

  Store({
    required this.id,
    this.name = "",
    this.address = "",
    this.storeImage = "",
    this.isActive = false,
    this.lastSync = "",
    this.ownerId,
    this.owner,
    this.createdAt = "",
    this.updatedAt = "",
  });

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      id: json["id"],
      name: json["name"] ?? "",
      address: json["address"] ?? "",
      storeImage: json["store_image"] ?? "",
      isActive: json["is_active"] ?? false,
      lastSync: json["last_sync"] ?? "",
      ownerId: json["owner_id"],
      owner: json["owner"] != null ? User.fromJson(json["owner"]) : null,
      createdAt: json["created_at"] ?? "",
      updatedAt: json["updated_at"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "address": address,
      "store_image": storeImage,
      "is_active": isActive,
      "last_sync": lastSync,
      "owner_id": ownerId,
      "owner": owner?.toJson(),
      "created_at": createdAt,
      "updated_at": updatedAt
    };
  }

}