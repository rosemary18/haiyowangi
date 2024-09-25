import 'package:haiyowangi/src/index.dart';

class VariantModel {

  final int id;
  final int? productId;
  final String? name;
  String? img;
  final String? description;
  final double? buyPrice;
  final double? qty;
  final int price;
  final int? unitId;
  final int? storeId;
  final bool? isPublished;
  final String? createdAt;
  final String? updatedAt;
  final UnitModel? uom;
  final List<IngredientItemModel> ingredients;
  final List<VariantItemModel> variants;
  final List<DiscountModel> discounts;

  VariantModel({
    required this.id,
    this.productId,
    this.name = "",
    this.img = "",
    this.description = "",
    this.buyPrice = 0,
    this.qty = 0,
    this.price = 0,
    this.unitId,
    this.storeId,
    this.isPublished = false,
    this.createdAt = "",
    this.updatedAt = "",
    this.uom,
    this.ingredients = const [],
    this.variants = const [],
    this.discounts = const [],
  });

  factory VariantModel.fromJson(Map<String, dynamic> json) {
    return VariantModel(
      id: json["id"],
      productId: json["product_id"],
      name: json["name"] ?? "",
      img: json["img"] ?? "",
      description: json["description"] ?? "",
      buyPrice: double.parse(json["buy_price"].toString()),
      qty: double.parse(json["qty"].toString()),
      price: json["price"],
      unitId: json["unit_id"],
      storeId: json["store_id"],
      isPublished: json["is_published"] ?? false,
      createdAt: json["created_at"] ?? "",
      updatedAt: json["updated_at"] ?? "",
      uom: json["uom"] != null ? UnitModel.fromJson(json["uom"]) : null,
      ingredients: json["ingredients"] == null ? [] : List<IngredientItemModel>.from(json["ingredients"].map((x) => IngredientItemModel.fromJson(x))),
      variants: json["variants"] == null ? [] : List<VariantItemModel>.from(json["variants"].map((x) => VariantItemModel.fromJson(x))),
      discounts: json["discounts"] == null ? [] : List<DiscountModel>.from(json["discounts"].map((x) => DiscountModel.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "product_id": productId,
      "name": name,
      "img": img,
      "description": description,
      "buy_price": buyPrice,
      "qty": qty,
      "price": price,
      "unit_id": unitId,
      "store_id": storeId,
      "is_published": isPublished,
      "created_at": createdAt,
      "updated_at": updatedAt,
      "uom": uom,
      "ingredients": ingredients,
      "variants": variants,
      "discounts": discounts
    };
  }

}