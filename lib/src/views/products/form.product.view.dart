import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:haiyowangi/src/index.dart';

class FormProductView extends StatefulWidget {
  const FormProductView({super.key});

  @override
  State<FormProductView> createState() => _FormProductViewState();
}

class _FormProductViewState extends State<FormProductView> {

  final repository = ProductRepository();
  final unitRepository = UnitRepository();
  final ctrlName = TextEditingController();
  final ctrlDesc = TextEditingController();
  final ctrlQty = TextEditingController();
  final ctrlBuyPrice = TextEditingController();
  final ctrlPrice = TextEditingController();

  List<UnitModel> units = [];
  bool isPublished = false;
  String? unit;

  @override
  void initState() {
    super.initState();
    handlerGetUnits();
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

    if (ctrlName.text.isEmpty) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text("Nama produk harus diisi!"),
          backgroundColor: Colors.red,
        )
      );
      return;
    }

    if (unit == null) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text("Satuan produk harus diisi!"),
          backgroundColor: Colors.red,
        )
      );
      return;
    }

    final state = context.read<AuthBloc>().state;
    final data = {
      "store_id": state.store?.id,
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

    Response res = await repository.create(data);
    if (res.statusCode == 200) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text("Produk baru ditambahkan!"),
          backgroundColor: Colors.green,
        )
      );
      Navigator.pop(context, true);
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const FormHeader(title: "Tambah Produk"),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        color: Colors.white,
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