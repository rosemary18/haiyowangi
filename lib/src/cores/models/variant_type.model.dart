import 'package:haiyowangi/src/index.dart';

class VariantTypeModel { 

  final int? id;
  final int? productId;
  String? name;
  final String? createdAt;
  List<VariantTypeItemModel> variants;

  VariantTypeModel({
    this.id,
    this.productId,
    this.name = "",
    this.createdAt = "",
    this.variants = const [],
  });

  factory VariantTypeModel.fromJson(Map<String, dynamic> json) {
    return VariantTypeModel(
      id: json["id"],
      productId: json["product_id"],
      name: json["name"] ?? "",
      createdAt: json["created_at"] ?? "",
      variants: json["variants"] == null ? [] : List<VariantTypeItemModel>.from(json["variants"].map((x) => VariantTypeItemModel.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "product_id": productId,
      "name": name,
      "created_at": createdAt,
      "variants": variants
    };
  }
  
}