import 'package:haiyowangi/src/index.dart';

class IncomingStockModel {

  final int id;
  final String? code;
  final String? name;
  final String? description;
  final int? status;
  final int? storeId;
  final String? createdAt;
  final String? updatedAt;
  final List<IncomingStockItemModel> incomingStockItems;

  IncomingStockModel({
    required this.id,
    this.code = "",
    this.name = "",
    this.description = "",
    this.status = 0,
    this.storeId,
    this.createdAt = "",
    this.updatedAt = "",
    this.incomingStockItems = const [],
  });

  factory IncomingStockModel.fromJson(Map<String, dynamic> json) {
    return IncomingStockModel(
      id: json["id"],
      code: json["code"] ?? "",
      name: json["name"] ?? "",
      description: json["description"] ?? "",
      status: json["status"] ?? 0,
      storeId: json["store_id"],
      createdAt: json["created_at"] ?? "",
      updatedAt: json["updated_at"] ?? "",
      incomingStockItems: (json["incoming_stock_items"] == null) ? [] : List<IncomingStockItemModel>.from(json["incoming_stock_items"].map((x) => IncomingStockItemModel.fromJson(x))),
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
      "updated_at": updatedAt,
      "incoming_stock_items": List<dynamic>.from(incomingStockItems.map((x) => x.toJson())),
    };
  }

}