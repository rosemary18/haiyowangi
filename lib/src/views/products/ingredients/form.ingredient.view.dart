import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:haiyowangi/src/index.dart';

class FormIngredientView extends StatefulWidget {
  const FormIngredientView({super.key});

  @override
  State<FormIngredientView> createState() => _FormIngredientViewState();
}

class _FormIngredientViewState extends State<FormIngredientView> {

  final repository = IngredientRepository();
  final unitRepository = UnitRepository();

  final _controllerName = TextEditingController();
  final _controllerQty = TextEditingController();

  List<UnitModel> units = [];
  bool isCashier = false;
  String? unit;

  @override
  void initState() {
    super.initState();
    handlerGetUnits();
  }

  @override
  void dispose() {
    super.dispose();
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

    if (_controllerName.text.isEmpty || unit!.isEmpty) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text("Lengkapi data terlebih dahulu"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final data = {
      "store_id": context.read<AuthBloc>().state.store?.id,
      "name": _controllerName.text,
      "qty": _controllerQty.text,
    };

    for (var i = 0; i < units.length; i++) {
      if ("${units[i].name} (${units[i].symbol})" == unit) {
        data["unit_id"] = units[i].id;
      }
    }

    Response response = await repository.create(data);

    if (response.statusCode == 200) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text("Bahan baru telah ditambahkan!"),
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
      appBar: const FormHeader(title: "Tambah Bahan"),
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
                    // Input(
                    //   controller: _controllerQty,
                    //   title: "Jumlah",
                    //   multiplication: true,
                    //   margin: const EdgeInsets.only(bottom: 6),
                    // ),                    
                    InputDropDown(
                      title: "Satuan",
                      initialValue: unit,
                      placeholder: "Pilih satuan untuk bahan ini ...",
                      list: units.map((t) => "${t.name} (${t.symbol})").toList(),
                      margin: const EdgeInsets.only(bottom: 12),
                      onChanged: (v) {
                        setState(() {
                          unit = v;
                        });
                      },
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