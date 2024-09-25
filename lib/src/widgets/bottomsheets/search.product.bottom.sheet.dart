import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:haiyowangi/src/index.dart';

class SearchProduct extends StatefulWidget {

  final bool multiple;
  final bool showIngredient;
  final bool showPacket;

  const SearchProduct({
    super.key,
    this.multiple = false,
    this.showIngredient = false,
    this.showPacket = false
  });

  @override
  State<SearchProduct> createState() => _SearchProductState();
}

class _SearchProductState extends State<SearchProduct> {

  final repository = ProductRepository();
  final controllerSearch = TextEditingController();

  List<IngredientModel> ingredients = [];
  List<ProductModel> products = [];
  List<VariantModel> variants = [];
  List<PacketModel> packets = [];

  bool showIngredient = false;
  bool showProduct = true;
  bool showVariant = false;
  bool showPacket = false;
  bool collapseIngredient = true;
  bool collapseProduct = true;
  bool collapseVariant = true;
  bool collapsePacket = true;
  dynamic selected;
  List<dynamic> selectedItems = [];


  bool loading = true;
  Timer? timeId;

  void handlerGetData() async {
    
    if (controllerSearch.text.isEmpty) {
      products.clear();
      variants.clear();
      packets.clear();
      ingredients.clear();
    } else {
      var state = context.read<AuthBloc>().state;
      var queryParams = {
        "search_text": controllerSearch.text,
        "include_variant": showVariant ? 1 : 0,
        "include_packet": showPacket ? 1 : 0,
        "include_ingredient": showIngredient ? 1 : 0,
        "is_published": 1
      };
      
      final response = await repository.search("${state.store!.id}", queryParams: queryParams);
      
      if (response.statusCode == 200) {

        products.clear();
        variants.clear();
        packets.clear();
        ingredients.clear();

        if (showProduct) {
          for (var item in response.data!["data"]!["products"]) {
            products.add(ProductModel.fromJson(item));
          }
        } 
        
        if (showVariant) {
          for (var item in response.data!["data"]!["variants"]) {
            variants.add(VariantModel.fromJson(item));
          }
        }

        if (showPacket) {
          for (var item in response.data!["data"]!["packets"]) {
            packets.add(PacketModel.fromJson(item));
          }
        }

        if (showIngredient) {
          debugPrint(response.data!["data"]!["ingredients"].toString());
          for (var item in response.data!["data"]!["ingredients"]) {
            ingredients.add(IngredientModel.fromJson(item));
          }
        }
      }
    }

    loading = false;
    selectedItems.clear();
    setState(() {});
  }

  void handlerSearch(String query) async {

    setState(() {
      loading = true;
    });
    if (timeId?.isActive ?? false) timeId!.cancel();
    timeId = Timer(const Duration(milliseconds: 500), () {
      handlerGetData();
    });
  }

  void handlerShowData(String type) {

    if (type == "product") {
      showProduct = !showProduct;
      if (showProduct && controllerSearch.text.isNotEmpty && products.isEmpty) {
        handlerGetData();
      }
    } else if (type == "variant") {
      showVariant = !showVariant;
      if (showVariant && controllerSearch.text.isNotEmpty && variants.isEmpty) {
        handlerGetData();
      }
    } else if (type == "packet") {
      showPacket = !showPacket;
      if (showPacket && controllerSearch.text.isNotEmpty && packets.isEmpty) {
        handlerGetData();
      }
    } else if (type == "ingredient") {
      showIngredient = !showIngredient;
      if (showIngredient && controllerSearch.text.isNotEmpty && ingredients.isEmpty) {
        handlerGetData();
      }
    }
    setState(() {});
  }

  void handlerCollapseData(String type) {

    if (type == "product") {
      collapseProduct = !collapseProduct;
    } else if (type == "variant") {
      collapseVariant = !collapseVariant;
    } else if (type == "packet") {
      collapsePacket = !collapsePacket;
    } else if (type == "ingredient") {
      collapseIngredient = !collapseIngredient;
    }
    setState(() {});
  }

  void handlerSelectData(dynamic data) {

    if (widget.multiple) {
      if (selectedItems.contains(data)) {
        selectedItems.remove(data);
      } else {
        selectedItems.add(data);
      }
    } else {
      selected = (data.runtimeType == selected.runtimeType && (data.id == selected.id)) ? null : data;
    }
    setState(() {});
  }

  void handlerSubmit() {

    Navigator.pop(context, widget.multiple ? selectedItems : selected);
  }

  // Views

  Widget buildFilterData(String t, Function() onPress) {

    bool active = false;
    if (t == "Produk") {
      active = showProduct;
    } else if (t == "Varian") {
      active = showVariant;
    } else if (t == "Paket") {
      active = showPacket;
    } else if (t == "Bahan") {
      active = showIngredient;
    }

    return TouchableOpacity(
      onPress: onPress,
      child: Container(
        constraints: const BoxConstraints(minWidth: 70, maxWidth: 120),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: active ? primaryColor : greyLightColor),
        ),
        child: Text(t, textAlign: TextAlign.center, style: TextStyle(color: active ? primaryColor : greyTextColor)),
      )
    );
  }

  Widget buildCard(dynamic data) {

    bool active = false;

    if (widget.multiple) {
      active = selectedItems.contains(data);
    } else if ((data.runtimeType == selected.runtimeType) && (data.id == selected.id)) {
      active = true;
    }

    if ((data.runtimeType == ProductModel) && (data?.hasVariants == true)) return Container();

    return TouchableOpacity(
      onPress: () => handlerSelectData(data),
      child: Container(
        color: active ? greenLightColor : Colors.transparent,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        margin: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(data.name.toString(), style: const TextStyle(fontSize: 12, fontFamily: FontMedium), maxLines: 2, overflow: TextOverflow.ellipsis),
                  if (data.runtimeType != PacketModel) Text("Qty: ${data.qty.toString()} ${data?.uom?.name ?? "" }", style: const TextStyle(fontSize: 8, color: greyTextColor)),
                  if (data.runtimeType == PacketModel) Text("Dijual: ${data.isPublished ? "Ya" : "Tidak"}", style: const TextStyle(fontSize: 8, color: greyTextColor)),
                ],
              )
            ),
            if (data.runtimeType != IngredientModel) Text(parseRupiahCurrency(data.price.toString()), style: const TextStyle(fontSize: 10)),
            Checkbox(
              value: active, 
              onChanged: (v) => handlerSelectData(data),
              activeColor: blueLightColor,
              checkColor: blueColor,
              shape: const CircleBorder(),
              side: const BorderSide(color: blueColor),
            )
          ],
        ),
      )
    );
  }

  Widget buildDivider(String t, Function() onPress) {

    bool active = false;
    if (t == "Produk") {
      active = collapseProduct;
    } else if (t == "Varian") {
      active = collapseVariant;
    } else if (t == "Paket") {
      active = collapsePacket;
    } else if (t == "Bahan") {
      active = collapseIngredient;
    }

    return TouchableOpacity(
      onPress: onPress,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        color: white1Color,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(t, style: const TextStyle(color: greyTextColor, fontSize: 12, fontWeight: FontWeight.w600)),
            Icon(
              active ? CupertinoIcons.chevron_up : CupertinoIcons.chevron_down,
              color: blackColor,
              size: 12,
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 4),
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
              margin: const EdgeInsets.symmetric(vertical: 8),
              height: double.infinity,
              width: double.infinity,
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
                  InputSearch(
                    controller: controllerSearch,
                    onChanged: handlerSearch,
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      child: Row(
                        children: [
                          if (widget.showIngredient) buildFilterData("Bahan", () => handlerShowData("ingredient")),
                          buildFilterData("Produk", () => handlerShowData("product")),
                          buildFilterData("Varian", () => handlerShowData("variant")),
                          if (widget.showPacket) buildFilterData("Paket", () => handlerShowData("packet")),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (showIngredient) buildDivider("Bahan", () => handlerCollapseData("ingredient")),
                          if (showIngredient && collapseIngredient) ...ingredients.map((e) => buildCard(e)),
                          if (showProduct) buildDivider("Produk", () => handlerCollapseData("product")),
                          if (showProduct && collapseProduct) ...products.map((e) => buildCard(e)),
                          if (showVariant) buildDivider("Varian", () => handlerCollapseData("variant")),
                          if (showVariant && collapseVariant) ...variants.map((e) => buildCard(e)),
                          if (showPacket) buildDivider("Paket", () => handlerCollapseData("packet")),
                          if (showPacket && collapsePacket) ...packets.map((e) => buildCard(e)),
                        ],
                      ),
                    )
                  )
                ]
              ),              
            ),
            if (selected != null || (selectedItems.isNotEmpty && widget.multiple)) Positioned(
              height: 48,
              bottom: MediaQuery.of(context).viewPadding.bottom + 8,
              right: 12,
              left: 12,
              child: ButtonOpacity(
                onPress: handlerSubmit,
                text: "Pilih ${(selectedItems.isNotEmpty && widget.multiple) ? "(${selectedItems.length})" : ""}",
                backgroundColor: primaryColor,
                fontSize: 16,
              )
            )
          ],
        )
      ),
    );
  }
}