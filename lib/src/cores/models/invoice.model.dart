class Invoice {

  final int id;
  final String? code;
  final int? salesId;
  final int? paymentId;
  final double? status;
  final double? discount;
  final double? subTotal;
  final double? total;
  final double? cash;
  final double? changeMoney;
  final String? createdAt;
  final String? updatedAt;

  Invoice({
    required this.id,
    this.code = "",
    this.salesId,
    this.paymentId,
    this.status = 0,
    this.discount = 0,
    this.subTotal = 0,
    this.total = 0,
    this.cash = 0,
    this.changeMoney = 0,
    this.createdAt = "",
    this.updatedAt = "",
  });

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      id: json["id"],
      code: json["code"] ?? "",
      salesId: json["sales_id"],
      paymentId: json["payment_id"],
      status: json["status"] ?? 0,
      discount: json["discount"] ?? 0,
      subTotal: json["sub_total"] ?? 0,
      total: json["total"] ?? 0,
      cash: json["cash"] ?? 0,
      changeMoney: json["change_money"] ?? 0,
      createdAt: json["created_at"] ?? "",
      updatedAt: json["updated_at"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "code": code,
      "sales_id": salesId,
      "payment_id": paymentId,
      "status": status,
      "discount": discount,
      "sub_total": subTotal,
      "total": total,
      "cash": cash,
      "change_money": changeMoney,
      "created_at": createdAt,
      "updated_at": updatedAt
    };
  }
  
}