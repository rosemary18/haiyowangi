import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import 'package:haiyowangi/src/index.dart';
import '../widgets/index.dart';

class DetailOutgoingStockView extends StatefulWidget {

  final String data;

  const DetailOutgoingStockView({
    super.key, 
    required this.data
  });

  @override
  State<DetailOutgoingStockView> createState() => _DetailOutgoingStockViewState();
}

class _DetailOutgoingStockViewState extends State<DetailOutgoingStockView> {

  final repository = OutgoingStockRepository();
  final _controllerName = TextEditingController();
  final _controllerDesc = TextEditingController();
  
  late OutgoingStockModel _outgoingStock;

  List<dynamic> items = [];
  bool isEditing = false;
  Timer? timeId;

  @override
  void initState() {
    super.initState();
    _outgoingStock = OutgoingStockModel.fromJson(jsonDecode(widget.data));
    handlerGetDetail();
    setState(() {});
  }

  Future<void> handlerGetDetail() async {
    
    Response response = await repository.getDetail("${_outgoingStock.id}");
    debugPrint(response.data.toString());
    if (response.statusCode == 200) {
      _outgoingStock = OutgoingStockModel.fromJson(response.data!["data"]);
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
    final response = await repository.update("${_outgoingStock.id}", data);
    if (response.statusCode == 200) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text("Stok keluar berhasil di posting!"),
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

        if (_outgoingStock.outgoingStockItems.isNotEmpty) {
          for (var e in _outgoingStock.outgoingStockItems) {
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
    
    _controllerName.text = _outgoingStock.name!;
    _controllerDesc.text = _outgoingStock.description!;
    
    isEditing = true;
    setState(() {});
  }

  void handlerAddItem(List<dynamic> items) async {

    if (items.isEmpty) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text("Item stok keluar harus diisi! atau item yang anda pilih sudah berada di dalam stok keluar."),
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

    final response = await repository.addStockItem("${_outgoingStock.id}", data);
    if (response.statusCode == 200) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text("Item stok keluar berhasil ditambahkan!"),
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

    Response response = await repository.update("${_outgoingStock.id}", data);
    if (response.statusCode == 200) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text("Stok keluar telah diubah!"),
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
          content: Text("Jumlah stok item dari stok keluar berhasil diupdate!"),
          backgroundColor: Colors.green,
        )
      );
      handlerGetDetail();
    }
  }

  void handlerDelete() async {

    final response = await repository.delete("${_outgoingStock.id}");
    if (response.statusCode == 200) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text("Stok keluar berhasil dihapus!"),
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
          content: Text("Item stok keluar berhasil dihapus!"),
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
          content: const Text("Apakah anda yakin ingin menghapus stok keluar ini?"),
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
          content: Text("Apakah anda yakin ingin menghapus item $name dari stok keluar ini?"),
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
      isEdit: !(_outgoingStock.status == 1),
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
        title: _outgoingStock.code ?? "Detail Staff",
        actions: !(_outgoingStock.status == 1) ? [
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
                                  Text(_outgoingStock.status == 1 ? "Posted" : "Pending", style: TextStyle(fontSize: 12, color: _outgoingStock.status == 1 ? blueColor : yellowColor))
                                ],
                              ),
                              const Divider(color: greyLightColor),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text("Kode Stok Keluar", style: TextStyle(fontSize: 12, color: greyTextColor)),
                                  Text(_outgoingStock.code.toString(), style: const TextStyle(fontSize: 12))
                                ],
                              ),
                              const Divider(color: greyLightColor),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text("Nama", style: TextStyle(fontSize: 12, color: greyTextColor)),
                                  Text(_outgoingStock.name.toString(), style: const TextStyle(fontSize: 12))
                                ],
                              ),
                              const Divider(color: greyLightColor),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text("Terakhir diubah", style: TextStyle(fontSize: 12, color: greyTextColor)),
                                  Text(formatDateFromString(_outgoingStock.updatedAt ?? ""), style: const TextStyle(fontSize: 12)),
                                ],
                              ),
                              const Divider(color: greyLightColor),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text("Dibuat pada", style: TextStyle(fontSize: 12, color: greyTextColor)),
                                  Text(formatDateFromString(_outgoingStock.createdAt ?? ""), style: const TextStyle(fontSize: 12)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const Text("Deskripsi", style: TextStyle(fontSize: 14, fontFamily: FontBold)),
                        const SizedBox(height: 2),
                        Text("${_outgoingStock.description!.isNotEmpty ? _outgoingStock.description : "-"}", style: const TextStyle(fontSize: 12, color: greyTextColor)),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text("Items (${_outgoingStock.outgoingStockItems.length})", style: const TextStyle(fontSize: 14, fontFamily: FontBold)),
                            if (_outgoingStock.status != 1) TouchableOpacity(
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
                        if (_outgoingStock.outgoingStockItems.isNotEmpty) ..._outgoingStock.outgoingStockItems.map(buildItem),
                      ],
                    )
                  ),
                ),
              )
            ),
            if (!isEditing && !(_outgoingStock.status == 1)) Container(
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
                      disabled: _outgoingStock.outgoingStockItems.isEmpty,
                    )
                  ),
                ],
              ),
            ),
            if (isEditing && !(_outgoingStock.status == 1)) Container(
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