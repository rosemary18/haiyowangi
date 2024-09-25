import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:haiyowangi/src/index.dart';

class DetailOfficeInventoryView extends StatefulWidget {

  final String data;

  const DetailOfficeInventoryView({
    super.key, 
    required this.data
  });

  @override
  State<DetailOfficeInventoryView> createState() => _DetailOfficeInventoryViewState();
}

class _DetailOfficeInventoryViewState extends State<DetailOfficeInventoryView> {

  final repository = OfficeInventoryRepository();
  final _controllerPrice = TextEditingController();
  final _controllerName = TextEditingController();
  final _controllerBuyDate = TextEditingController();
  final _controllerQty = TextEditingController();
  
  late OfficeInventoryModel _officeInventory;
  late String goods_condition = GOODS_CONDITIONS.map((e) => "${e['name']}").toList()[0];

  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    _officeInventory = OfficeInventoryModel.fromJson(jsonDecode(widget.data));
    handlerGetDetailOfficeInventory();
    setState(() {});
  }

  Future<void> handlerGetDetailOfficeInventory() async {
    
    Response response = await repository.getDetail("${_officeInventory.id}");
    debugPrint(response.data.toString());
    if (response.statusCode == 200) {
      _officeInventory = OfficeInventoryModel.fromJson(response.data!["data"]);
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
    for (var i = 0; i < GOODS_CONDITIONS.length; i++) {
      if (GOODS_CONDITIONS[i]['id'] == _officeInventory.goodsCondition) {
        goods_condition = GOODS_CONDITIONS[i]['name'];
      }
    }
    _controllerName.text = _officeInventory.name!;
    _controllerPrice.text = _officeInventory.price!.toString();
    _controllerBuyDate.text = _officeInventory.buyDate!;
    _controllerQty.text = _officeInventory.qty!.toString();
    isEditing = true;
    setState(() {});
  }

  Future<void> handlerUpdate() async {

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

    Response response = await repository.update("${_officeInventory.id}", data);
    if (response.statusCode == 200) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text("Inventaris telah diubah!"),
          backgroundColor: Colors.green,
        )
      );
      handlerGetDetailOfficeInventory();
      isEditing = false;
      setState(() {});
    }
  }

  void handlerDelete() async {

    final response = await repository.delete("${_officeInventory.id}");
    if (response.statusCode == 200) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text("Inventaris berhasil dihapus!"),
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
          content: const Text("Apakah anda yakin ingin menghapus inventaris ini?"),
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
      appBar: DetailHeader(title: _officeInventory.name ?? "Detail Office Inventory"), 
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
                  child: isEditing ? Column(
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
                      ),
                    ]
                  ) : Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_officeInventory.name ?? "-", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.all(Radius.circular(100)),
                              color: _officeInventory.goodsCondition == 0 ? greenLightColor : redLightColor
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            child: Text(_officeInventory.goodsCondition == 0 ? "Bagus" : "Rusak", style: TextStyle(color: _officeInventory.goodsCondition == 0 ? primaryColor : redColor, fontSize: 10)),
                          )
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
                                const Text("Jumlah", style: TextStyle(fontSize: 12, color: greyTextColor)),
                                Text(_officeInventory.qty.toString(), style: const TextStyle(fontSize: 12))
                              ],
                            ),
                            const Divider(color: greyLightColor),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("Harga", style: TextStyle(fontSize: 12, color: greyTextColor)),
                                Text(parseRupiahCurrency("${_officeInventory.price ?? 0}"), style: const TextStyle(fontSize: 12)),
                              ],
                            ),
                            const Divider(color: greyLightColor),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("Dibeli pada", style: TextStyle(fontSize: 12, color: greyTextColor)),
                                Text(formatDateFromString(_officeInventory.buyDate ?? "", format: "dd/MM/yyyy"), style: const TextStyle(fontSize: 12)),
                              ],
                            ),
                            const Divider(color: greyLightColor),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("Terakhir diubah", style: TextStyle(fontSize: 12, color: greyTextColor)),
                                Text(formatDateFromString(_officeInventory.updatedAt ?? ""), style: const TextStyle(fontSize: 12)),
                              ],
                            ),
                            const Divider(color: greyLightColor),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("Dibuat pada", style: TextStyle(fontSize: 12, color: greyTextColor)),
                                Text(formatDateFromString(_officeInventory.createdAt ?? ""), style: const TextStyle(fontSize: 12)),
                              ],
                            ),
                          ],
                        ),
                      ),
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