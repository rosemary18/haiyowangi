import 'store.model.dart';

class  UserModel {
  final int id;
  final String? name;
  final String? username;
  final String? email;
  final String? profilePhoto;
  final String? phone;
  final String? address;
  final String? token;
  final int privilege;
  final bool is_active;
  final String createdAt;
  final String updatedAt;
  final List<StoreModel>? stores;

   UserModel({
    required this.id,
    this.name = "",
    this.username = "",
    this.email = "",
    this.profilePhoto = "",
    this.phone = "",
    this.address = "",
    this.token = "",
    this.privilege = 0,
    this.is_active = false,
    this.createdAt = "",
    this.updatedAt = "",
    this.stores
  });

  factory  UserModel.fromJson(Map<String, dynamic> json) {
    return  UserModel(
      id: json["id"],
      name: json["name"] ?? "",
      username: json["username"] ?? "",
      email: json["email"] ?? "",
      profilePhoto: json["profile_photo"] ?? "",
      phone: json["phone"] ?? "",
      address: json["address"] ?? "",
      token: json["token"] ?? "",
      privilege: json["privilege"] ?? 0,
      is_active: json["is_active"] ?? false,
      createdAt: json["created_at"] ?? "",
      updatedAt: json["updated_at"] ?? "",
      stores: json["stores"] != null ? (json["stores"] as List).map((i) => StoreModel.fromJson(i)).toList() : null
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "username": username,
      "email": email,
      "profile_photo": profilePhoto,
      "phone": phone,
      "address": address,
      "token": token,
      "privilege": privilege,
      "is_active": is_active,
      "created_at": createdAt,
      "updated_at": updatedAt,
      "stores": stores
    };
  }
}