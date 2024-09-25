import 'package:haiyowangi/src/index.dart';

class ProductModel {

  final int id;
  final String name;
  String? img;
  final String? description;
  final double? qty;
  final int? buyPrice;
  final int price;
  final bool? hasVariants;
  final bool? isPublished;
  final int? unitId;
  final int? storeId;
  final String? createdAt;
  final String? updatedAt;
  final List<VariantTypeModel> variant_types;
  final List<IngredientItemModel> ingredients;
  final List<VariantModel> variants;
  final List<DiscountModel> discounts;
  final UnitModel? uom;

  ProductModel({
    required this.id,
    required this.name,
    this.img = "",
    this.description = "",
    this.qty = 0,
    this.buyPrice = 0,
    this.price = 0,
    this.hasVariants = false,
    this.isPublished = false,
    this.unitId,
    this.storeId,
    this.createdAt = "",
    this.updatedAt = "",
    this.variant_types = const [],
    this.ingredients = const [],
    this.variants = const [],
    this.discounts = const [],
    this.uom
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json["id"],
      name: json["name"] ?? "",
      img: json["img"] ?? "",
      description: json["description"] ?? "",
      qty: double.parse(json["qty"].toString()),
      buyPrice: json["buy_price"] ?? 0,
      price: json["price"] ?? 0,
      hasVariants: json["has_variants"] ?? false,
      isPublished: json["is_published"] ?? false,
      unitId: json["unit_id"],
      storeId: json["store_id"],
      createdAt: json["created_at"] ?? "",
      updatedAt: json["updated_at"] ?? "",
      variant_types: json["variant_types"] != null ? List<VariantTypeModel>.from(json["variant_types"].map((x) => VariantTypeModel.fromJson(x))) : [],
      ingredients: json["ingredients"] != null ? List<IngredientItemModel>.from(json["ingredients"].map((x) => IngredientItemModel.fromJson(x))) : [],
      variants: json["variants"] != null ? List<VariantModel>.from(json["variants"].map((x) => VariantModel.fromJson(x))) : [],
      discounts: json["discounts"] != null ? List<DiscountModel>.from(json["discounts"].map((x) => DiscountModel.fromJson(x))) : [],
      uom: json["uom"] != null ? UnitModel.fromJson(json["uom"]) : null
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "img": img,
      "description": description,
      "qty": qty,
      "buy_price": buyPrice,
      "price": price,
      "has_variants": hasVariants,
      "is_published": isPublished,
      "unit_id": unitId,
      "store_id": storeId,
      "created_at": createdAt,
      "updated_at": updatedAt,
      "variant_types": variant_types.map((x) => x.toJson()).toList(),
      "ingredients": ingredients.map((x) => x.toJson()).toList(),
      "variants": variants.map((x) => x.toJson()).toList(),
      "discounts": discounts.map((x) => x.toJson()).toList(),
      "uom": uom
    };
  }

}