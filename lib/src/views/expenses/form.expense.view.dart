import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:haiyowangi/src/index.dart';

class FormExpenseView extends StatefulWidget {
  const FormExpenseView({super.key});

  @override
  State<FormExpenseView> createState() => _FormExpenseViewState();
}

class _FormExpenseViewState extends State<FormExpenseView> {

  final repository = ExpenseRepository();
  final _controllerTag = TextEditingController();
  final _controllerName = TextEditingController();
  final _controllerDescription = TextEditingController();
  final _controllerNominal = TextEditingController();
  final _controllerDate = TextEditingController();

  List<String> tags = [];

  @override
  void initState() {
    super.initState();
    handlerGetTags();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void handlerSubmit() async {

    if (_controllerName.text.isEmpty || _controllerNominal.text.isEmpty || _controllerDate.text.isEmpty || _controllerNominal.text.isEmpty) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text("Lengkapi data terlebih dahulu"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_controllerNominal.text.replaceAll(RegExp(r'[^\d]'), '') == "0") {
      scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text("Nominal harus lebih dari 0"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final data = {
      "store_id": context.read<AuthBloc>().state.store?.id,
      "tag": _controllerTag.text,
      "name": _controllerName.text,
      "description": _controllerDescription.text,
      "nominal": parseFromInput(_controllerNominal.text),
      "date": _controllerDate.text,
    };

    Response response = await repository.create(data);

    if (response.statusCode == 200) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text("Pengeluaran baru telah ditambahkan!"),
          backgroundColor: Colors.green,
        )
      );
      Navigator.pop(context, true);
    }
  }

  void handlerGetTags() async {
    
    final response = await repository.getTags(queryParams: {"per_page": 1000});
    if (response.statusCode == 200) {
      setState(() {
        for (var item in response.data!["data"]) {
          tags.add(item.toString());
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const FormHeader(title: "Tambah Pengeluaran"),
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
                      controller: _controllerTag,
                      title: "Tag",
                      margin: const EdgeInsets.only(bottom: 6),
                      suggestions: tags,
                    ),
                    Input(
                      controller: _controllerName,
                      title: "Nama",
                      margin: const EdgeInsets.only(bottom: 6),
                    ),
                    Input(
                      controller: _controllerNominal,
                      isCurrency: true,
                      title: "Nominal",
                      margin: const EdgeInsets.only(bottom: 6),
                    ),
                    InputDate(
                      controller: _controllerDate,
                      title: "Tanggal",
                      margin: const EdgeInsets.only(bottom: 6),
                    ),
                    Input(
                      controller: _controllerDescription,
                      title: "Deskripsi",
                      maxLines: 10,
                      margin: const EdgeInsets.only(bottom: 12),
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