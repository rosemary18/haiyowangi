import 'package:haiyowangi/src/index.dart';

class IngredientModel {
  
  final int id;
  final String? name;
  String? img;
  final double? qty;
  final int? unitId;
  final int? storeId;
  final String? createdAt;
  final String? updatedAt;
  final List<IngredientItemModel> ingredients;
  final UnitModel? uom;

  IngredientModel({
    required this.id,
    this.name = "",
    this.img = "",
    this.qty = 0,
    this.unitId,
    this.storeId,
    this.createdAt = "",
    this.updatedAt = "",
    this.ingredients = const [],
    this.uom
  });

  factory IngredientModel.fromJson(Map<String, dynamic> json) {
    return IngredientModel(
      id: json["id"],
      name: json["name"] ?? "",
      img: json["img"] ?? "",
      qty: double.tryParse(json["qty"].toString()) ?? 0,
      unitId: json["unit_id"],
      storeId: json["store_id"],
      createdAt: json["created_at"] ?? "",
      updatedAt: json["updated_at"] ?? "",
      ingredients: json["ingredients"] == null ? [] : List<IngredientItemModel>.from(json["ingredients"].map((x) => IngredientItemModel.fromJson(x))),
      uom: json["uom"] == null ? null : UnitModel.fromJson(json["uom"]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "img": img,
      "qty": qty,
      "unit_id": unitId,
      "store_id": storeId,
      "created_at": createdAt,
      "updated_at": updatedAt,
      "ingredients": ingredients,
      "uom": uom
    };
  }

}