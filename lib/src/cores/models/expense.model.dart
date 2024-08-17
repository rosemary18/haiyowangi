class ExpenseModel {

  final int id;
  final String? code;
  final String? name;
  final int? nominal;
  final String? tag;
  final String? description;
  final int? storeId;
  final String? createdAt;
  final String? updatedAt;

  ExpenseModel({
    required this.id,
    this.code = "",
    this.name = "",
    this.nominal = 0,
    this.tag = "",
    this.description = "",
    this.storeId,
    this.createdAt = "",
    this.updatedAt = "",
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json["id"],
      code: json["code"] ?? "",
      name: json["name"] ?? "",
      nominal: json["nominal"] ?? 0,
      tag: json["tag"] ?? "",
      description: json["description"] ?? "",
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
      "nominal": nominal,
      "tag": tag,
      "description": description,
      "store_id": storeId,
      "created_at": createdAt,
      "updated_at": updatedAt
    };
  }

}