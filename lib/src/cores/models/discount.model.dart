class Discount {

  final int id;
  final String? name;
  final String? code;
  final double? nominal;
  final double? percentage;
  final bool isPercentage;
  final String? dateValid;
  final String? validUntil;
  final int? multiplication;
  final double? maxItemsQty;
  final double? minItemsQty;
  final int? specialForProductId;
  final int? specialForVariantId;
  final int? specialForPacketId;
  final int? storeId;
  final String? createdAt;
  final String? updatedAt;

  Discount({
    required this.id,
    this.name = "",
    this.code = "",
    this.nominal = 0,
    this.percentage = 0,
    this.isPercentage = false,
    this.dateValid = "",
    this.validUntil = "",
    this.multiplication = 0,
    this.maxItemsQty = 0,
    this.minItemsQty = 0,
    this.specialForProductId,
    this.specialForVariantId,
    this.specialForPacketId,
    this.storeId,
    this.createdAt = "",
    this.updatedAt = "",
  });

  factory Discount.fromJson(Map<String, dynamic> json) {
    return Discount(
      id: json["id"],
      name: json["name"] ?? "",
      code: json["code"] ?? "",
      nominal: json["nominal"] ?? 0,
      percentage: json["percentage"] ?? 0,
      isPercentage: json["is_percentage"] ?? false,
      dateValid: json["date_valid"] ?? "",
      validUntil: json["valid_until"] ?? "",
      multiplication: json["multiplication"] ?? 0,
      maxItemsQty: json["max_items_qty"] ?? 0,
      minItemsQty: json["min_items_qty"] ?? 0,
      specialForProductId: json["special_for_product_id"],
      specialForVariantId: json["special_for_variant_id"],
      specialForPacketId: json["special_for_packet_id"],
      storeId: json["store_id"],
      createdAt: json["created_at"] ?? "",
      updatedAt: json["updated_at"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "code": code,
      "nominal": nominal,
      "percentage": percentage,
      "is_percentage": isPercentage,
      "date_valid": dateValid,
      "valid_until": validUntil,
      "multiplication": multiplication,
      "max_items_qty": maxItemsQty,
      "min_items_qty": minItemsQty,
      "special_for_product_id": specialForProductId,
      "special_for_variant_id": specialForVariantId,
      "special_for_packet_id": specialForPacketId,
      "store_id": storeId,
      "created_at": createdAt,
      "updated_at": updatedAt
    }; 
  }

}