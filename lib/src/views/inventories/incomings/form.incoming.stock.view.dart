import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:haiyowangi/src/index.dart';

class FormIncomingStockView extends StatefulWidget {
  const FormIncomingStockView({super.key});

  @override
  State<FormIncomingStockView> createState() => _FormIncomingStockViewState();
}

class _FormIncomingStockViewState extends State<FormIncomingStockView> {

  final repository = IncomingStockRepository();
  final _controllerName = TextEditingController();
  final _controllerDesc = TextEditingController();

  bool isCashier = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void handlerSubmit() async {

    if (_controllerName.text.isEmpty) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text("Nama stok masuk harus diisi!"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final data = {
      "store_id": context.read<AuthBloc>().state.store?.id,
      "name": _controllerName.text,
      "description": _controllerDesc.text,
    };

    Response response = await repository.create(data);

    if (response.statusCode == 200) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text("Stok masuk telah ditambahkan!"),
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
      appBar: const FormHeader(title: "Tambah Stok Masuk"),
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
                      controller: _controllerDesc,
                      title: "Deskripsi",
                      maxLines: 10,
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
    );
  }
}