import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:haiyowangi/src/index.dart';

class FormVariantView extends StatefulWidget {

  final String data;

  const FormVariantView({
    super.key,
    required this.data
  });

  @override
  State<FormVariantView> createState() => _FormVariantViewState();
}

class _FormVariantViewState extends State<FormVariantView> {

  final repository = VariantRepository();
  final unitRepository = UnitRepository();
  final ctrlName = TextEditingController();
  final ctrlDesc = TextEditingController();
  final ctrlQty = TextEditingController();
  final ctrlBuyPrice = TextEditingController();
  final ctrlPrice = TextEditingController();

  List<VariantTypeModel> _types = [];
  List<UnitModel> units = [];
  bool isPublished = false;
  String? unit;

  Map<String, String> mapTypes = {};

  late ProductModel _product;

  @override
  void initState() {
    super.initState();
    _product = ProductModel.fromJson(jsonDecode(widget.data));
    if (_product.variant_types.isNotEmpty) {
      _types = _product.variant_types;
      for (var item in _types) {
        mapTypes["${item.id}"] = "";
      }
      setState(() {});
    }
    handlerGetTypes();
    handlerGetUnits();
    isPublished = _product.isPublished!;
    ctrlBuyPrice.text = _product.buyPrice.toString();
    ctrlPrice.text = _product.price.toString();
  }

  void handlerGetTypes() async {
    
    Response response = await repository.getVariantTypes("${_product.id}");
    if (response.statusCode == 200) {
      if ((response.data["data"] as List).isNotEmpty) {
        _types = (response.data["data"] as List).map((e) => VariantTypeModel.fromJson(e)).toList();
        mapTypes.clear();
        for (var item in _types) {
          mapTypes["${item.id}"] = "";
        }
        setState(() {});
      }
    }
  }

  Future<void> handlerGetUnits() async {

    Response res = await unitRepository.getData();
    if (res.statusCode == 200) {
      units.clear();
      for (var item in res.data!["data"]!) {
        units.add(UnitModel.fromJson(item));
      }
      setState(() {});
    }
  }

  void handlerSubmit() async {

    final variantTypeList = mapTypes.values.toList();
    if (variantTypeList.contains("")) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text("Tipe varian harus diisi!"),
          backgroundColor: Colors.red,
        )
      );
      return;
    }

    if (unit == null) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text("Satuan varian harus diisi!"),
          backgroundColor: Colors.red,
        )
      );
      return;
    }

    final data = {
      "product_id": _product.id,
      "name": ctrlName.text,
      "description": ctrlDesc.text,
      "qty": ctrlQty.text,
      "buy_price": parsePriceFromInput(ctrlBuyPrice.text),
      "price": parsePriceFromInput(ctrlPrice.text),
      "is_published": isPublished
    };

    for (var i = 0; i < units.length; i++) {
      if ("${units[i].name} (${units[i].symbol})" == unit) {
        data["unit_id"] = units[i].id;
      }
    }

    List<dynamic> items = [];
    for (var item in _types) {
      for (var e in item.variants) {
        if (mapTypes["${item.id}"] == e.name) {
          items.add(e.id);
        }
      }
    }
    data["variant_type_item"] = items;

    Response res = await repository.create(data);
    if (res.statusCode == 200) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text("Varian baru ditambahkan!"),
          backgroundColor: Colors.green,
        )
      );
      Navigator.pop(context, true);
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FormHeader(
        title: "Tambah Varian - ${_product.name}",
      ),
      body: Container(
        color: Colors.white,
        height: double.infinity,
        width: double.infinity,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  margin: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 1,
                              blurRadius: 1,
                              offset: const Offset(0, 1), // changes position of shadow
                            ),
                          ]
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Pilih semua varian yang tersedia di ${_product.name}", style: const TextStyle(fontSize: 14, fontFamily: FontBold)),
                            ..._types.map((e) {
                              return InputDropDown(
                                title: "${e.name}",
                                placeholder: "Pilih varian",
                                list: e.variants.map((i) => "${i.name}").toList(),
                                onChanged: (v) {
                                  mapTypes["${e.id}"] = v!;
                                  setState(() {});
                                },
                                margin: const EdgeInsets.only(top: 8),
                              );
                            }),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      SwitchLabel(
                        title: "Tampilkan di POS (Dijual)",
                        value: isPublished, 
                        onChanged: (v) {
                          setState(() {
                            isPublished = v;
                          });
                        },
                        margin: const EdgeInsets.only(bottom: 6),
                      ),
                      Input(
                        controller: ctrlName,
                        title: "Nama Produk",
                        placeholder: "Contoh: Black Opium - Original",
                        margin: const EdgeInsets.only(bottom: 6),
                      ),
                      Input(
                        controller: ctrlDesc,
                        title: "Deskripsi",
                        maxLines: 10,
                        placeholder: "Deskripsi ...",
                        margin: const EdgeInsets.only(bottom: 12),
                      ),
                      InputDropDown(
                        title: "Satuan",
                        initialValue: unit,
                        placeholder: "Pilih satuan untuk varian ini ...",
                        list: units.map((t) => "${t.name} (${t.symbol})").toList(),
                        margin: const EdgeInsets.only(bottom: 12),
                        onChanged: (v) {
                          setState(() {
                            unit = v;
                          });
                        },
                      ),     
                      Input(
                        controller: ctrlQty,
                        title: "Jumlah",
                        multiplication: true,
                        margin: const EdgeInsets.only(bottom: 6),
                      ),
                      Input(
                        controller: ctrlBuyPrice,
                        title: "Harga Beli",
                        isCurrency: true,
                        margin: const EdgeInsets.only(bottom: 6),
                      ),
                      Input(
                        controller: ctrlPrice,
                        title: "Harga Jual",
                        isCurrency: true,
                        margin: const EdgeInsets.only(bottom: 6),
                      ), 
                    ],
                  ),
                ),
              )
            ),
            ButtonOpacity(
              text: "Simpan",
              margin: const EdgeInsets.all(12),
              backgroundColor: primaryColor,
              onPress: handlerSubmit,
            )
          ],
        ),
      ),
    );
  }
}