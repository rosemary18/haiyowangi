import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import 'package:haiyowangi/src/index.dart';
import '../widgets/index.dart';

class DetailIncomingStockView extends StatefulWidget {

  final String data;

  const DetailIncomingStockView({
    super.key, 
    required this.data
  });

  @override
  State<DetailIncomingStockView> createState() => _DetailIncomingStockViewState();
}

class _DetailIncomingStockViewState extends State<DetailIncomingStockView> {

  final repository = IncomingStockRepository();
  final _controllerName = TextEditingController();
  final _controllerDesc = TextEditingController();
  
  late IncomingStockModel _incomingStock;

  List<dynamic> items = [];
  bool isEditing = false;
  Timer? timeId;

  @override
  void initState() {
    super.initState();
    _incomingStock = IncomingStockModel.fromJson(jsonDecode(widget.data));
    handlerGetDetail();
    setState(() {});
  }

  Future<void> handlerGetDetail() async {
    
    Response response = await repository.getDetail("${_incomingStock.id}");
    debugPrint(response.data.toString());
    if (response.statusCode == 200) {
      _incomingStock = IncomingStockModel.fromJson(response.data!["data"]);
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

  Future<void> handlerPost() async {

    final data = { "status": 1 };
    final response = await repository.update("${_incomingStock.id}", data);
    if (response.statusCode == 200) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text("Stok masuk berhasil di posting!"),
          backgroundColor: Colors.green,
        )
      );
      handlerGetDetail();
    }
  }

  void handlerSearchProduct() async {

    var x = await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      barrierColor: Colors.transparent,
      clipBehavior: Clip.none,
      isScrollControlled: false,
      scrollControlDisabledMaxHeightRatio: .85,
      builder: (context) => const SearchProduct(multiple: true, showIngredient: true),
    );

    if (x != null) {

      List<Map<String, dynamic>> items = [];

      for (var item in x) {

        bool exist = false;

        if (_incomingStock.incomingStockItems.isNotEmpty) {
          for (var e in _incomingStock.incomingStockItems) {
            if (
              (((e.productId != null) && (item.runtimeType == ProductModel)) && (e.productId == item.id)) 
              || 
              (((e.variantId != null) && (item.runtimeType == VariantModel)) && (e.variantId == item.id))
              ||
              (((e.ingredientId != null) && (item.runtimeType == IngredientModel)) && (e.ingredientId == item.id))
              ) {
              exist = true;
              break;
            }
          }
        }

        if (!exist) {
          items.add({
            "qty": 1,
            "data": item
          });
        }
      }

      handlerAddItem(items);
    }
  }

  void handlerEdit() {
    
    _controllerName.text = _incomingStock.name!;
    _controllerDesc.text = _incomingStock.description!;
    
    isEditing = true;
    setState(() {});
  }

  void handlerAddItem(List<dynamic> items) async {

    if (items.isEmpty) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text("Item stok masuk harus diisi! atau item yang anda pilih sudah berada di dalam stok masuk."),
          backgroundColor: Colors.red,
        )
      );
      return;
    }
    
    List<Map<String, dynamic>> _items = [];

    for (var item in items) {
      Map<String, dynamic> _item = {};
      if (item["data"].runtimeType == VariantModel) {
        _item["variant_id"] = item["data"].id;
      } else if (item["data"].runtimeType == ProductModel) {
        _item["product_id"] = item["data"].id;
      } else if (item["data"].runtimeType == IngredientModel) {
        _item["ingredient_id"] = item["data"].id;
      }
      _item["qty"] = "${item["qty"]}";
      _items.add(_item);
    }

    final data = {
      "items": _items
    };

    final response = await repository.addStockItem("${_incomingStock.id}", data);
    if (response.statusCode == 200) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text("Item stok masuk berhasil ditambahkan!"),
          backgroundColor: Colors.green,
        )
      );
      handlerGetDetail();
    }
  }

  Future<void> handlerUpdate() async {

    final data = {
      "name": _controllerName.text,
      "description": _controllerDesc.text
    };

    Response response = await repository.update("${_incomingStock.id}", data);
    if (response.statusCode == 200) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text("Stok masuk telah diubah!"),
          backgroundColor: Colors.green,
        )
      );
      handlerGetDetail();
      isEditing = false;
      setState(() {});
    }
  }

  void handlerUpdateItem(double qty, dynamic id) async {
    
    if (!(qty > 0)) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text("Kuantitas atau jumlah harus lebih dari 0"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final data = {
      "qty": qty
    };

    Response response = await repository.updateItem("$id", data);
    if (response.statusCode == 200) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text("Jumlah stok item dari stok masuk berhasil diupdate!"),
          backgroundColor: Colors.green,
        )
      );
      handlerGetDetail();
    }
  }

  void handlerDelete() async {

    final response = await repository.delete("${_incomingStock.id}");
    if (response.statusCode == 200) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text("Stok masuk berhasil dihapus!"),
          backgroundColor: Colors.green,
        )
      );
      Navigator.pop(context, true);
    }
  }

  void handlerDeleteItem(int id) async {

    final response = await repository.deleteStockItem("$id");
    if (response.statusCode == 200) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text("Item stok masuk berhasil dihapus!"),
          backgroundColor: Colors.green,
        )
      );
      handlerGetDetail();
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
          content: const Text("Apakah anda yakin ingin menghapus stok masuk ini?"),
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

  void viewConfirmDeleteItem(dynamic data) {

    var name = "";

    if (data.productId != null) {
      name = data.product!.name;
    }

    if (data.variantId != null) {
      name = data.variant!.name!;
    }
    
    showDialog(
      context: context, 
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
          titlePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          content: Text("Apakah anda yakin ingin menghapus item $name dari stok masuk ini?"),
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
                handlerDeleteItem(data?.id);
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

  Widget buildItem(dynamic data) {

    dynamic pdata;

    if (data.productId != null) {
      pdata = data.product;
    }

    if (data.variantId != null) {
      pdata = data.variant;
    }

    if (data.ingredientId != null) {
      pdata = data.ingredient;
    }

    return StockItem(
      isEdit: !(_incomingStock.status == 1),
      data: {
        "qty": data.qty,
        "data": pdata
      },
      onChange: (d) {
        if (timeId?.isActive ?? false) timeId!.cancel();
        timeId = Timer(const Duration(milliseconds: 500), () {
          handlerUpdateItem(d["qty"], data?.id);          
        });
      },
      onDelete: (d) {
        viewConfirmDeleteItem(data);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: DetailHeader(
        title: _incomingStock.code ?? "Detail Stock Masuk",
        actions: !(_incomingStock.status == 1) ? [
          TouchableOpacity(
            onPress: viewConfirmDelete,
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              child: const Icon(
                Boxicons.bxs_trash,
                size: 18,
                color: redColor,
              ),
            ), 
          )
        ] : [],
      ), 
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
                child: SingleChildScrollView(
                  child: (isEditing) ? Container(
                    margin: const EdgeInsets.all(16),
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
                  ) : Padding(
                    padding: const EdgeInsets.all(12), 
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: white1Color,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          padding: const EdgeInsets.all(8),
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text("Status", style: TextStyle(fontSize: 12, color: greyTextColor)),
                                  Text(_incomingStock.status == 1 ? "Posted" : "Pending", style: TextStyle(fontSize: 12, color: _incomingStock.status == 1 ? blueColor : yellowColor))
                                ],
                              ),
                              const Divider(color: greyLightColor),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text("Kode Stok Masuk", style: TextStyle(fontSize: 12, color: greyTextColor)),
                                  Text(_incomingStock.code.toString(), style: const TextStyle(fontSize: 12))
                                ],
                              ),
                              const Divider(color: greyLightColor),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text("Nama", style: TextStyle(fontSize: 12, color: greyTextColor)),
                                  Text(_incomingStock.name.toString(), style: const TextStyle(fontSize: 12))
                                ],
                              ),
                              const Divider(color: greyLightColor),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text("Terakhir diubah", style: TextStyle(fontSize: 12, color: greyTextColor)),
                                  Text(formatDateFromString(_incomingStock.updatedAt ?? ""), style: const TextStyle(fontSize: 12)),
                                ],
                              ),
                              const Divider(color: greyLightColor),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text("Dibuat pada", style: TextStyle(fontSize: 12, color: greyTextColor)),
                                  Text(formatDateFromString(_incomingStock.createdAt ?? ""), style: const TextStyle(fontSize: 12)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const Text("Deskripsi", style: TextStyle(fontSize: 14, fontFamily: FontBold)),
                        const SizedBox(height: 2),
                        Text("${_incomingStock.description!.isNotEmpty ? _incomingStock.description : "-"}", style: const TextStyle(fontSize: 12, color: greyTextColor)),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text("Items (${_incomingStock.incomingStockItems.length})", style: const TextStyle(fontSize: 14, fontFamily: FontBold)),
                            if (_incomingStock.status != 1) TouchableOpacity(
                              onPress: handlerSearchProduct,
                              child: const Icon(
                                Boxicons.bx_plus,
                                color: primaryColor,
                                size: 22,
                              ), 
                            )
                          ],
                        ),
                        const SizedBox(height: 10),
                        if (_incomingStock.incomingStockItems.isNotEmpty) ..._incomingStock.incomingStockItems.map(buildItem),
                      ],
                    )
                  ),
                ),
              )
            ),
            if (!isEditing && !(_incomingStock.status == 1)) Container(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: ButtonOpacity(
                      text: "Ubah",
                      backgroundColor: white1Color,
                      textColor: greyTextColor,
                      onPress: handlerEdit,
                    )
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ButtonOpacity(
                      onPress: handlerPost,
                      text: "Post",
                      backgroundColor: primaryColor,
                      disabled: _incomingStock.incomingStockItems.isEmpty,
                    )
                  ),
                ],
              ),
            ),
            if (isEditing && !(_incomingStock.status == 1)) Container(
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