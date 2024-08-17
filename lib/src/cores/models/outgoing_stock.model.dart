class OutgoingStockModel {

  final int id;
  final String? code;
  final String? name;
  final String? description;
  final int? status;
  final int? storeId;
  final String? createdAt;
  final String? updatedAt;

  OutgoingStockModel({
    required this.id,
    this.code = "",
    this.name = "",
    this.description = "",
    this.status = 0,
    this.storeId,
    this.createdAt = "",
    this.updatedAt = "",
  });

  factory OutgoingStockModel.fromJson(Map<String, dynamic> json) {
    return OutgoingStockModel(
      id: json["id"],
      code: json["code"] ?? "",
      name: json["name"] ?? "",
      description: json["description"] ?? "",
      status: json["status"] ?? 0,
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
      "description": description,
      "status": status,
      "store_id": storeId,
      "created_at": createdAt,
      "updated_at": updatedAt
    };
  }

}