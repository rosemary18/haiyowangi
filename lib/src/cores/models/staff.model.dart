class Staff {

  final int id;
  final String? code;
  final String? name;
  final String? email;
  final String? phone;
  final String? profilePhoto;
  final String? address;
  final String? dateJoined;
  final int? status;
  final double? salary;
  final String? posPasscode;
  final bool? isCashier;
  final int? storeId;
  final String? createdAt;
  final String? updatedAt;

  Staff({
    required this.id,
    this.code = "",
    this.name = "",
    this.email = "",
    this.phone = "",
    this.profilePhoto = "",
    this.address = "",
    this.dateJoined = "",
    this.status = 0,
    this.salary = 0,
    this.posPasscode = "",
    this.isCashier = false,
    this.storeId,
    this.createdAt = "",
    this.updatedAt = "",
  });

  factory Staff.fromJson(Map<String, dynamic> json) {
    return Staff(
      id: json["id"],
      code: json["code"] ?? "",
      name: json["name"] ?? "",
      email: json["email"] ?? "",
      phone: json["phone"] ?? "",
      profilePhoto: json["profile_photo"] ?? "",
      address: json["address"] ?? "",
      dateJoined: json["date_joined"] ?? "",
      status: json["status"] ?? 0,
      salary: json["salary"] ?? 0,
      posPasscode: json["pos_passcode"] ?? "",
      isCashier: json["is_cashier"] ?? false,
      storeId: json["store_id"],
      createdAt: json["created_at"] ?? "",
      updatedAt: json["updated_at"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "code": code,
      "name": name,
      "email": email,
      "phone": phone,
      "profile_photo": profilePhoto,
      "address": address,
      "date_joined": dateJoined,
      "status": status,
      "salary": salary,
      "pos_passcode": posPasscode,
      "is_cashier": isCashier,
      "store_id": storeId,
      "created_at": createdAt,
      "updated_at": updatedAt
    };
  }

}