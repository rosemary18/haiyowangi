class Payment {

  final int id;
  final String? code;
  final String? accountBank;
  final String? accountNumber;
  final String? receiverAccountBank;
  final String? receiverAccountNumber;
  final String? img;
  final double? nominal;
  final String? createdAt;
  final String? updatedAt;

  Payment({
    required this.id,
    this.code = "",
    this.accountBank = "",
    this.accountNumber = "",
    this.receiverAccountBank = "",
    this.receiverAccountNumber = "",
    this.img = "",
    this.nominal = 0,
    this.createdAt = "",
    this.updatedAt = "",
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json["id"],
      code: json["code"] ?? "",
      accountBank: json["account_bank"] ?? "",
      accountNumber: json["account_number"] ?? "",
      receiverAccountBank: json["receiver_account_bank"] ?? "",
      receiverAccountNumber: json["receiver_account_number"] ?? "",
      img: json["img"] ?? "",
      nominal: json["nominal"] ?? 0,
      createdAt: json["created_at"] ?? "",
      updatedAt: json["updated_at"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "code": code,
      "account_bank": accountBank,
      "account_number": accountNumber,
      "receiver_account_bank": receiverAccountBank,
      "receiver_account_number": receiverAccountNumber,
      "img": img,
      "nominal": nominal,
      "created_at": createdAt,
      "updated_at": updatedAt
    };
  }

}