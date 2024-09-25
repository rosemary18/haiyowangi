import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import 'package:haiyowangi/src/index.dart';

class DetailPacketView extends StatefulWidget {

  final String data;

  const DetailPacketView({
    super.key, 
    required this.data
  });

  @override
  State<DetailPacketView> createState() => _DetailPacketViewState();
}

class _DetailPacketViewState extends State<DetailPacketView> {

  final repository = PacketRepository();
  
  final ctrlName = TextEditingController();
  final ctrlDesc = TextEditingController();
  final ctrlPrice = TextEditingController();
  
  late PacketModel _packet;

  bool isPublished = false;
  bool isEditing = false;

  Timer? timeId;

  @override
  void initState() {
    super.initState();
    _packet = PacketModel.fromJson(jsonDecode(widget.data));
    handlerGetDetail();
    setState(() {});
  }

  Future<void> handlerGetDetail() async {
    
    Response response = await repository.getDetail("${_packet.id}");
    debugPrint(response.data.toString());
    if (response.statusCode == 200) {
      _packet = PacketModel.fromJson(response.data!["data"]);
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

  void handlerSearchProduct(BuildContext ctx) async {

    var x = await showModalBottomSheet(
      context: ctx,
      backgroundColor: Colors.white,
      barrierColor: Colors.transparent,
      clipBehavior: Clip.none,
      isScrollControlled: false,
      scrollControlDisabledMaxHeightRatio: .85,
      builder: (context) => const SearchProduct(multiple: true),
    );

    if (x != null) {

      List<Map<String, dynamic>> items = [];

      for (var item in x) {

        bool exist = false;

        if (_packet.items.isNotEmpty) {
          for (var e in _packet.items) {
            if (
              (((e.productId != null) && (item.runtimeType == ProductModel)) && (e.productId == item.id)) 
              || 
              (((e.variantId != null) && (item.runtimeType == VariantModel)) && (e.variantId == item.id))
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

  void handlerAddItem(List<dynamic> items) async {

    if (items.isEmpty) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text("Item paket harus diisi! Atau paket yang anda pilih sudah berada di dalam paket."),
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
      }
      _item["qty"] = "${item["qty"]}";
      _items.add(_item);
    }

    final data = {
      "items": _items
    };

    final response = await repository.createItem("${_packet.id}", data);
    if (response.statusCode == 200) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text("Paket item berhasil ditambahkan!"),
          backgroundColor: Colors.green,
        )
      );
      handlerGetDetail();
    }
  }

  void handlerEdit() {

    ctrlName.text = _packet.name!;
    ctrlDesc.text = _packet.description!;
    ctrlPrice.text = _packet.price.toString();
    isPublished = _packet.isPublished!;

    isEditing = true;
    setState(() {});
  }

  Future<void> handlerUpdate() async {
    
    if (ctrlName.text.isEmpty || ctrlDesc.text.isEmpty || ctrlPrice.text.isEmpty) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text("Lengkapi data terlebih dahulu"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final data = {
      "name": ctrlName.text,
      "description": ctrlDesc.text,
      "price": parsePriceFromInput(ctrlPrice.text),
      "is_published": isPublished
    };

    final response = await repository.update("${_packet.id}", data);
    if (response.statusCode == 200) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text("Paket berhasil diupdate!"),
          backgroundColor: Colors.green,
        )
      );
      handlerGetDetail();
    }

    isEditing = false;
    setState(() {});
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
          content: Text("Paket item berhasil diupdate!"),
          backgroundColor: Colors.green,
        )
      );
      handlerGetDetail();
    }
  }

  void handlerDelete() async {

    final response = await repository.delete("${_packet.id}");
    if (response.statusCode == 200) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text("Paket berhasil dihapus!"),
          backgroundColor: Colors.green,
        )
      );
      Navigator.pop(context, true);
    }
  }

  void handlerDeleteItem(dynamic id) async {

    final response = await repository.deleteItem("$id");
    if (response.statusCode == 200) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text("Paket item berhasil dihapus!"),
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
          content: const Text("Apakah anda yakin ingin menghapus paket ini?"),
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
          content: Text("Apakah anda yakin ingin menghapus item $name dari paket ini?"),
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

    return ItemPacket(
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
      appBar: DetailHeader(title: _packet.name ?? "Detail Paket"), 
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
                          title: "Nama Paket",
                          placeholder: "Contoh: Paket Murah",
                          margin: const EdgeInsets.only(bottom: 6),
                        ),
                        Input(
                          controller: ctrlDesc,
                          title: "Deskripsi",
                          maxLines: 10,
                          placeholder: "Deskripsi ...",
                          margin: const EdgeInsets.only(bottom: 12),
                        ),
                        Input(
                          controller: ctrlPrice,
                          title: "Harga",
                          isCurrency: true,
                          margin: const EdgeInsets.only(bottom: 6),
                        ),
                      ],
                    ),
                  ) : Container(
                    margin: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Text("Name", style: TextStyle(fontSize: 10, color: greyTextColor)),
                        Text(_packet.name ?? "Paket", style: const TextStyle(fontSize: 12, fontFamily: FontMedium)),
                        const SizedBox(height: 6),
                        const Text("Tampilkan di POS (Dijual)", style: TextStyle(fontSize: 10, color: greyTextColor)),
                        Text(_packet.isPublished! ? "Ya" : "Tidak", style: const TextStyle(fontSize: 12, fontFamily: FontMedium)),
                        const SizedBox(height: 6),
                        const Text("Deskripsi", style: TextStyle(fontSize: 10, color: greyTextColor)),
                        Text(_packet.description!.isNotEmpty ? _packet.description! : "-", style: const TextStyle(fontSize: 12, fontFamily: FontMedium)),
                        const SizedBox(height: 12),
                        const Text("Terakhir diubah", style: TextStyle(fontSize: 10, color: greyTextColor)),
                        Text(formatDateFromString(_packet.updatedAt!), style: const TextStyle(fontSize: 12, fontFamily: FontMedium)),
                        const SizedBox(height: 6),
                        const Text("Dibuat pada", style: TextStyle(fontSize: 10, color: greyTextColor)),
                        Text(formatDateFromString(_packet.createdAt!), style: const TextStyle(fontSize: 12, fontFamily: FontMedium)),
                        const SizedBox(height: 12),
                        const Divider(color: greyLightColor),         
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Items", style: TextStyle(fontSize: 16, fontFamily: FontBold)),
                            TouchableOpacity(
                              onPress: () => handlerSearchProduct(context),
                              child: const Icon(
                                Boxicons.bx_plus,
                                size: 24,
                                color: primaryColor
                              ), 
                            )
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (_packet.items.isNotEmpty) ..._packet.items.map(buildItem)
                      ],
                    ),
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