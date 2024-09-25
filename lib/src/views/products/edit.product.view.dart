import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:haiyowangi/src/index.dart';

class EditProductView extends StatefulWidget {

  final String data;

  const EditProductView({
    super.key,
    required this.data
  });

  @override
  State<EditProductView> createState() => _EditProductViewState();
}

class _EditProductViewState extends State<EditProductView> {

  final repository = ProductRepository();

  final unitRepository = UnitRepository();
  final ctrlName = TextEditingController();
  final ctrlDesc = TextEditingController();
  final ctrlQty = TextEditingController();
  final ctrlBuyPrice = TextEditingController();
  final ctrlPrice = TextEditingController();
  late ProductModel _product; 

  bool uploadingImage = false;
  List<UnitModel> units = [];
  bool isPublished = false;
  String? unit;

  @override
  void initState() {
    super.initState();
    _product = ProductModel.fromJson(jsonDecode(widget.data));
    ctrlName.text = _product.name;
    ctrlDesc.text = _product.description!;
    ctrlQty.text = _product.qty.toString();
    ctrlBuyPrice.text = _product.buyPrice.toString();
    ctrlPrice.text = _product.price.toString();
    isPublished = _product.isPublished!;
    handlerGetUnits();
    debugPrint(ctrlBuyPrice.text);
    debugPrint(ctrlPrice.text);
  }

  Future<void> handlerGetUnits() async {

    Response res = await unitRepository.getData();
    if (res.statusCode == 200) {
      units.clear();
      for (var item in res.data!["data"]!) {
        var x = UnitModel.fromJson(item);
        units.add(x);
        if (_product.uom != null && (_product.uom!.id == x.id)) {
          unit = _product.uom == null ? null : "${_product.uom!.name} (${_product.uom!.symbol})";
        }
      }
      setState(() {});
    }
  }

  void handlerSubmit() async {

    if (ctrlName.text.isEmpty) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text("Nama produk harus diisi!"),
          backgroundColor: Colors.red,
        )
      );
    }

    if (unit == null) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text("Satuan produk harus diisi!"),
          backgroundColor: Colors.red,
        )
      );
    }

    final data = {
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

    Response res = await repository.update("${_product.id}", data);
    if (res.statusCode == 200) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text("Produk ${_product.name} berhasil diubah!"),
          backgroundColor: Colors.green,
        )
      );
      Navigator.pop(context, true);
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const DetailHeader(
        title: "Ubah Produk"
      ), 
      backgroundColor: white1Color,
      body: Container(
        height: double.infinity,
        width: double.infinity,
        color: white1Color,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  margin: const EdgeInsets.all(12),
                  child: Column(
                    children: [
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
                        placeholder: "Contoh: Black Opium",
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
                        placeholder: "Pilih satuan untuk produk ini ...",
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
      )
    );
  }
}