class SaleModel {

  final int id;
  final String? code;
  final int? status;
  final double? total;
  final int? discountId;
  final int? paymentTypeId;
  final int? storeId;
  final int? staffId;
  final String? createdAt;
  final String? updatedAt;

  SaleModel({
    required this.id,
    this.code = "",
    this.status = 0,
    this.total = 0,
    this.discountId,
    this.paymentTypeId,
    this.storeId,
    this.staffId,
    this.createdAt = "",
    this.updatedAt = "",
  });

  factory SaleModel.fromJson(Map<String, dynamic> json) {
    return SaleModel(
      id: json["id"],
      code: json["code"] ?? "",
      status: json["status"] ?? 0,
      total: json["total"] ?? 0,
      discountId: json["discount_id"],
      paymentTypeId: json["payment_type_id"],
      storeId: json["store_id"],
      staffId: json["staff_id"],
      createdAt: json["created_at"] ?? "",
      updatedAt: json["updated_at"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "code": code,
      "status": status,
      "total": total,
      "discount_id": discountId,
      "payment_type_id": paymentTypeId,
      "store_id": storeId,
      "staff_id": staffId,
      "created_at": createdAt,
      "updated_at": updatedAt
    };
  }

}