class PaymentType {

  final int id;
  final String? name;
  final String? description;
  final String? code;
  final String? createdAt;
  final String? updatedAt;

  PaymentType({
    required this.id,
    this.name = "",
    this.description = "",
    this.code = "",
    this.createdAt = "",
    this.updatedAt = "",
  });

  factory PaymentType.fromJson(Map<String, dynamic> json) {
    return PaymentType(
      id: json["id"],
      name: json["name"] ?? "",
      description: json["description"] ?? "",
      code: json["code"] ?? "",
      createdAt: json["created_at"] ?? "",
      updatedAt: json["updated_at"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "description": description,
      "code": code,
      "created_at": createdAt,
      "updated_at": updatedAt
    };
  }
  
}