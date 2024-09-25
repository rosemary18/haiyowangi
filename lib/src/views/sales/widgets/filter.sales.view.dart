import 'package:flutter/material.dart';
import 'package:haiyowangi/src/index.dart';

class FilterSalesView extends StatefulWidget {

  final void Function(Map<String, dynamic>) onFilter;
  final Map<String, dynamic> filter;
  final PersistentBottomSheetController? controller;

  const FilterSalesView({
    super.key,
    this.controller,
    required this.filter,
    required this.onFilter,
  });

  @override
  State<FilterSalesView> createState() => _FilterSalesViewState();
}

class _FilterSalesViewState extends State<FilterSalesView> {

  late Map<String, dynamic> filter = widget.filter;
  List<Map<String, String>> orderBys = [
    {
      "key": "code",
      "name": "Kode"
    },
    {
      "key": "total",
      "name": "Total"
    },
    {
      "key": "created_at",
      "name": "Tanggal Dibuat"
    },
  ];
  List<Map<String, String>> orderTypes = [
    {
      "key": "asc",
      "name": "A - Z"
    },
    {
      "key": "desc",
      "name": "Z - A"
    },
  ];
  List<Map<String, String>> statuses = [
    {
      "key": "0",
      "name": "Pending"
    },
    {
      "key": "1",
      "name": "Selesai"
    },
    {
      "key": "2",
      "name": "Dibatalkan"
    },
  ];

  @override
  void initState() {
    super.initState();
  }

  String getTextStatus(String status) {

    String t = "";
    for (var item in statuses) {
      if (item["key"] == status) {
        t = item["name"].toString();
        break;
      }
    }

    return t;
  }

  String getTextOrderBy(String orderBy) {

    String t = "";
    for (var item in orderBys) {
      if (item["key"] == orderBy) {
        t = item["name"].toString();
        break;
      }
    }

    return t;
  }

  String getTextOrderType(String orderType) {

    String t = "";
    for (var item in orderTypes) {
      if (item["key"] == orderType) {
        t = item["name"].toString();
        break;
      }
    }

    return t;
  }

  void handlerSetOrderBy(String? v) {
    for (var item in orderBys) {
      if (item["name"] == v) {
        filter["order_by"] = item["key"];
        break;
      }
    }
    setState(() {});
  }

  void handlerSetOrderType(String? v) {

    for (var item in orderTypes) {
      if (item["name"] == v) {
        filter["order_type"] = item["key"];
        break;
      }
    }
    
    setState(() {});
  }

  void handlerSetStatus(String? v) {

    for (var item in statuses) {
      if (item["name"] == v) {
        filter["status"] = item["key"];
        break;
      }
    }
    
    setState(() {});
  }

  void handlerApply({bool isReset = false}) {

    filter = isReset ? {} : filter;
    widget.controller!.setState!(() {});
    widget.controller?.close();
    widget.onFilter(filter);
  }

  // Views

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
        boxShadow: [
          BoxShadow(color: Color.fromARGB(22, 0, 0, 0), blurRadius: 10, spreadRadius: 2.5)
        ]
      ),
      child: Stack(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  width: double.infinity,
                  child: Center(
                    child: Container(
                      height: 4,
                      width: 40,
                      decoration: BoxDecoration(
                        color: greyLightColor,
                        borderRadius: BorderRadius.circular(4)
                      ),
                    )
                  ),
                ),
                const SizedBox(height: 8),
                InputDropDown(
                  initialValue: widget.filter["order_by"] != null ? getTextOrderBy(widget.filter["order_by"].toString()) : null,
                  placeholder: "Urutkan berdasarkan ...",
                  list: orderBys.map((e) => e["name"].toString()).toList(),
                  onChanged: handlerSetOrderBy,
                ),
                const SizedBox(height: 8),
                InputDropDown(
                  initialValue: widget.filter["order_type"] != null ? getTextOrderType(widget.filter["order_type"].toString()) : null,
                  placeholder: "Tipe pengurutan ...",
                  list: orderTypes.map((e) => e["name"].toString()).toList(),
                  onChanged: handlerSetOrderType,
                ),
                const SizedBox(height: 8),
                InputDropDown(
                  initialValue: widget.filter["status"] != null ? getTextStatus(widget.filter["status"].toString()) : null,
                  placeholder: "Status ...",
                  list: statuses.map((e) => e["name"].toString()).toList(),
                  onChanged: handlerSetStatus,
                )
              ]
            )
          ),
          Positioned(
            height: 40,
            bottom: MediaQuery.of(context).viewPadding.bottom + 8,
            right: 0,
            left: 0,
            child: Row(
              children: [
                Expanded(
                  child: ButtonOpacity(
                    onPress: () => handlerApply(isReset: true),
                    text: "Atur Ulang",
                    backgroundColor: Colors.white,
                    textColor: greyTextColor,
                    fontSize: 12,
                  )
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ButtonOpacity(
                    onPress: handlerApply,
                    text: "Urutkan",
                    backgroundColor: primaryColor,
                    fontSize: 12,
                  )
                )
              ],
            )
          )
        ],
      )
    );
  }
}