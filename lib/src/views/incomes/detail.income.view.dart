import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:haiyowangi/src/index.dart';

class DetailIncomeView extends StatefulWidget {

  final String data;

  const DetailIncomeView({
    super.key, 
    required this.data
  });

  @override
  State<DetailIncomeView> createState() => _DetailIncomeViewState();
}

class _DetailIncomeViewState extends State<DetailIncomeView> {

  final repository = IncomeRepository();
  final _controllerTag = TextEditingController();
  final _controllerName = TextEditingController();
  final _controllerDescription = TextEditingController();
  final _controllerNominal = TextEditingController();
  final _controllerDate = TextEditingController();
  
  late IncomeModel _income;

  bool isEditing = false;
  List<String> tags = [];

  @override
  void initState() {
    super.initState();
    _income = IncomeModel.fromJson(jsonDecode(widget.data));
    handlerGetDetail();
    handlerGetTags();
    setState(() {});
  }

  Future<void> handlerGetDetail() async {
    
    Response response = await repository.getDetail("${_income.id}");
    debugPrint(response.data.toString());
    if (response.statusCode == 200) {
      _income = IncomeModel.fromJson(response.data!["data"]);
      setState(() {});
    } else {
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text(response.data["message"]! ?? response.statusMessage!),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void handlerEdit() {
    _controllerTag.text = _income.tag!.toString();
    _controllerName.text = _income.name!;
    _controllerDate.text = _income.createdAt!;
    _controllerNominal.text = _income.nominal!.toString();
    _controllerDescription.text = _income.description!.toString();
    isEditing = true;
    setState(() {});
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

  Future<void> handlerUpdate() async {

    if (_controllerTag.text.isEmpty || _controllerName.text.isEmpty || _controllerDate.text.isEmpty || _controllerDescription.text.isEmpty || _controllerNominal.text.isEmpty) {
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
      "tag": _controllerTag.text,
      "name": _controllerName.text,
      "nominal": parseFromInput(_controllerNominal.text),
      "date": _controllerDate.text,
      "description": _controllerDescription.text,
    };

    Response response = await repository.update("${_income.id}", data);
    if (response.statusCode == 200) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text("Pendapatan telah diubah!"),
          backgroundColor: Colors.green,
        )
      );
      handlerGetDetail();
      isEditing = false;
      setState(() {});
    }
  }

  void handlerDelete() async {

    final response = await repository.delete("${_income.id}");
    if (response.statusCode == 200) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text("Pendapatan berhasil dihapus!"),
          backgroundColor: Colors.green,
        )
      );
      Navigator.pop(context, true);
    }
  }

  // Views

  void viewConfirmDelete() {

    showDialog(
      context: context, 
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
          titlePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          content: const Text("Apakah anda yakin ingin menghapus pendapatan ini?"),
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
          scrollable: true,
          shadowColor: primaryColor.withOpacity(0.2),
          insetPadding: EdgeInsets.symmetric(horizontal: isTablet ? MediaQuery.of(context).size.width/4 : 16),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          actions: [
            TouchableOpacity(
              onPress: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                margin: const EdgeInsets.only(left: 8),
                decoration: BoxDecoration(
                  color: greyColor,
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: const Text(
                  'Batal', 
                  style: TextStyle(
                    color: Color.fromARGB(192, 0, 0, 0), 
                    fontSize: 14,
                    fontWeight: FontWeight.bold
                  )
                ),
              ), 
            ),
            TouchableOpacity(
              onPress: () async {
                Navigator.pop(context);
                handlerDelete();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                margin: const EdgeInsets.only(left: 6),
                decoration: BoxDecoration(
                  color: redColor,
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: const Text(
                  'Hapus', 
                  style: TextStyle(
                    color: Colors.white, 
                    fontSize: 14,
                    fontWeight: FontWeight.bold
                  )
                ),
              ), 
            )
          ],
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: DetailHeader(title: _income.code ?? "Detail Pendapatan"), 
      body: Container(
        height: double.infinity,
        width: double.infinity,
        color: Colors.white,
        child: Column(
          children: [
            Expanded(
              child: Container(
                height: double.infinity,
                width: double.infinity,
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: (isEditing) ? Column(
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
                  ) : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_income.code ?? "-", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: white1Color,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        padding: const EdgeInsets.all(8),
                        margin: const EdgeInsets.only(top: 6),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("Tag", style: TextStyle(fontSize: 12, color: greyTextColor)),
                                Text(_income.tag.toString(), style: const TextStyle(fontSize: 12))
                              ],
                            ),
                            const Divider(color: greyLightColor),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("Nama", style: TextStyle(fontSize: 12, color: greyTextColor)),
                                Text(_income.name.toString(), style: const TextStyle(fontSize: 12))
                              ],
                            ),
                            const Divider(color: greyLightColor),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("Nominal", style: TextStyle(fontSize: 12, color: greyTextColor)),
                                Text(parseRupiahCurrency("${_income.nominal ?? 0}"), style: const TextStyle(fontSize: 12)),
                              ],
                            ),
                            const Divider(color: greyLightColor),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("Tanggal", style: TextStyle(fontSize: 12, color: greyTextColor)),
                                Text(formatDateFromString(_income.createdAt ?? "", format: "dd/MM/yyyy"), style: const TextStyle(fontSize: 12)),
                              ],
                            ),
                            const Divider(color: greyLightColor),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("Terakhir diubah pada", style: TextStyle(fontSize: 12, color: greyTextColor)),
                                Text(formatDateFromString(_income.updatedAt ?? ""), style: const TextStyle(fontSize: 12)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text("Deskripsi", style: TextStyle(fontSize: 12, fontFamily: FontMedium)),
                      const SizedBox(height: 4),
                      Text("${_income.description!.isNotEmpty ? _income.description : "-"}", style: const TextStyle(fontSize: 10, color: greyTextColor)),
                    ],
                  ),
                ),
              )
            ),
            if (!isEditing) Container(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: ButtonOpacity(
                      onPress: viewConfirmDelete,
                      text: "Hapus",
                      backgroundColor: redLightColor,
                      textColor: redColor
                    )
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ButtonOpacity(
                      text: "Ubah",
                      backgroundColor: white1Color,
                      textColor: greyTextColor,
                      onPress: handlerEdit,
                    )
                  ),
                ],
              ),
            ),
            if (isEditing) Container(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: ButtonOpacity(
                      onPress: () {
                        setState(() {
                          isEditing = false;
                        });
                      },
                      text: "Batal",
                      backgroundColor: white1Color,
                      textColor: greyTextColor
                    )
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ButtonOpacity(
                      text: "Simpan",
                      backgroundColor: primaryColor,
                      textColor: white1Color,
                      onPress: handlerUpdate,
                    )
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}