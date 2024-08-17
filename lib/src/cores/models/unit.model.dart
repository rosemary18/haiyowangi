class UnitModel {

  final int id;
  final String? name;
  final String? symbol;
  final String? base_unit_symbol;
  final double conversion_factor_to_base;
  final String? createdAt;

  UnitModel({
    required this.id,
    this.name = "",
    this.symbol = "",
    this.base_unit_symbol = "",
    this.conversion_factor_to_base = 0,
    this.createdAt = "",
  });

  factory UnitModel.fromJson(Map<String, dynamic> json) {
    return UnitModel(
      id: json["id"],
      name: json["name"] ?? "",
      symbol: json["symbol"] ?? "",
      base_unit_symbol: json["base_unit_symbol"] ?? "",
      conversion_factor_to_base: json["conversion_factor_to_base"] ?? 0,
      createdAt: json["created_at"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "symbol": symbol,
      "base_unit_symbol": base_unit_symbol,
      "conversion_factor_to_base": conversion_factor_to_base,
      "created_at": createdAt,
    };
  }
  
}