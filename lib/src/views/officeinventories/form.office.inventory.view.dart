import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:haiyowangi/src/index.dart';

class FormOfficeInventoryView extends StatefulWidget {
  const FormOfficeInventoryView({super.key});

  @override
  State<FormOfficeInventoryView> createState() => _FormOfficeInventoryViewState();
}

class _FormOfficeInventoryViewState extends State<FormOfficeInventoryView> {

  final repository = OfficeInventoryRepository();
  final _controllerPrice = TextEditingController();
  final _controllerName = TextEditingController();
  final _controllerBuyDate = TextEditingController();
  final _controllerQty = TextEditingController();
  
  String goods_condition = GOODS_CONDITIONS.map((e) => "${e['name']}").toList()[0];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void handlerSubmit() async {

    if (_controllerName.text.isEmpty || _controllerPrice.text.isEmpty || _controllerBuyDate.text.isEmpty || _controllerQty.text.isEmpty) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text("Lengkapi data terlebih dahulu"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_controllerQty.text == "0") {
      scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text("Jumlah harus lebih dari 0"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final data = {
      "store_id": context.read<AuthBloc>().state.store?.id,
      "name": _controllerName.text,
      "price": parsePriceFromInput(_controllerPrice.text),
      "buy_date": _controllerBuyDate.text,
      "qty": _controllerQty.text,
    };

    for (var i = 0; i < GOODS_CONDITIONS.length; i++) {
      if (GOODS_CONDITIONS[i]['name'].toString().toLowerCase() == goods_condition.toLowerCase()) {
        data["goods_condition"] = GOODS_CONDITIONS[i]['id'].toString();
      }
    }

    Response response = await repository.create(data);

    if (response.statusCode == 200) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text("Inventaris baru telah ditambahkan!"),
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
      appBar: const FormHeader(title: "Tambah Inventaris"),
      body: Column(
        children: [
          Expanded(
            child: Container(
              height: double.infinity,
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.all(12),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Input(
                      controller: _controllerName,
                      title: "Nama",
                      margin: const EdgeInsets.only(bottom: 6),
                    ),
                    Input(
                      controller: _controllerPrice,
                      isCurrency: true,
                      title: "Harga",
                      margin: const EdgeInsets.only(bottom: 6),
                    ),
                    InputDate(
                      controller: _controllerBuyDate,
                      title: "Tanggal Beli",
                      margin: const EdgeInsets.only(bottom: 6),
                    ),
                    Input(
                      controller: _controllerQty,
                      title: "Jumlah",
                      multiplication: true,
                      margin: const EdgeInsets.only(bottom: 6),
                    ),
                    InputDropDown(
                      title: "Kondisi Barang",
                      placeholder: "Pilih kondisi",
                      list: GOODS_CONDITIONS.map((e) => "${e['name']}").toList(),
                      initialValue: goods_condition
                    )
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
    );
  }
}