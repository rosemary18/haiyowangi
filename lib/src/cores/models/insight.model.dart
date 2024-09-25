class InsightItem {

  final int total;
  final List<dynamic> sources;

  InsightItem({
    required this.total,
    required this.sources
  });

  factory InsightItem.fromJson(Map<String, dynamic> json) {
    return InsightItem(
      total: json["total"],
      sources: json["sources"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "total": total,
      "sources": sources
    };
  }
}

class InsightModel {

  final int laba;
  final Map<String, dynamic> sales;
  final InsightItem incomes;
  final InsightItem expenses;

  InsightModel({
    required this.laba,
    required this.sales,
    required this.incomes,
    required this.expenses
  });

  factory InsightModel.fromJson(Map<String, dynamic> json) {
    return InsightModel(
      laba: json["laba"],
      sales: json["sales"],
      incomes: InsightItem.fromJson(json["incomes"]),
      expenses: InsightItem.fromJson(json["expenses"])
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "laba": laba,
      "sales": sales,
      "incomes": incomes,
      "expenses": expenses
    };
  }
}