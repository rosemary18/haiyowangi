import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import 'package:haiyowangi/src/index.dart';

class FormPacketView extends StatefulWidget {
  const FormPacketView({super.key});

  @override
  State<FormPacketView> createState() => _FormPacketViewState();
}

class _FormPacketViewState extends State<FormPacketView> {

  final repository = PacketRepository();

  final ctrlName = TextEditingController();
  final ctrlDesc = TextEditingController();
  final ctrlPrice = TextEditingController();

  List<dynamic> items = [];
  bool isPublished = false;

  @override
  void initState() {
    super.initState();
  }

  void handlerSearchProduct() async {

    var x = await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      barrierColor: Colors.transparent,
      clipBehavior: Clip.none,
      isScrollControlled: false,
      scrollControlDisabledMaxHeightRatio: .85,
      builder: (context) => const SearchProduct(multiple: true),
    );

    if (x != null) {
      setState(() {
        for (var item in x) {

          bool exist = false;

          if (items.isNotEmpty) {
            for (var e in items) {
              if (((e["data"].runtimeType == item.runtimeType) && e["data"]?.id == item?.id)) {
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
      });
    }
  }

  void handlerSubmit() async {

    if (ctrlName.text.isEmpty) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text("Nama paket harus diisi!"),
          backgroundColor: Colors.red,
        )
      );
      return;
    }

    if (ctrlPrice.text.isEmpty) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text("Harga paket harus diisi!"),
          backgroundColor: Colors.red,
        )
      );
      return;
    }

    if (items.isEmpty) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text("Item paket harus diisi!"),
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
      "price": parsePriceFromInput(ctrlPrice.text),
      "is_published": isPublished,
      "items": []
    };

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

    data["items"] = _items;

    Response res = await repository.create(data);
    if (res.statusCode == 200) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text("Paket baru ditambahkan!"),
          backgroundColor: Colors.green,
        )
      );
      Navigator.pop(context, true);
    }

  }

  void handlerDeleteItem(dynamic data) {
    setState(() {
      items.remove(data);
    });
  }

  Widget buildItem(dynamic data) => ItemPacket(
    data: data, 
    onDelete: handlerDeleteItem
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const FormHeader(title: "Tambah Paket"),
      body: Builder(
        builder: (_ctx) => Container(
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
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                        const SizedBox(height: 6),
                        const Divider(color: greyLightColor),         
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Items", style: TextStyle(fontSize: 16, fontFamily: FontBold)),
                            TouchableOpacity(
                              onPress: handlerSearchProduct,
                              child: const Icon(
                                Boxicons.bx_plus,
                                size: 24,
                                color: primaryColor
                              ), 
                            )
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (items.isNotEmpty) ...items.map(buildItem)
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
      )
    );
  }
}

class ItemPacket extends StatefulWidget {

  final dynamic data;
  final Function(dynamic)? onChange;
  final Function(dynamic)? onDelete;

  const ItemPacket({
    super.key, 
    this.data,
    this.onChange,
    this.onDelete
  });

  @override
  State<ItemPacket> createState() => _ItemPacketState();
}

class _ItemPacketState extends State<ItemPacket> {
  
  final ctrlQty = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.data != null) {
      ctrlQty.text = widget.data["qty"].toString();
    }
    ctrlQty.addListener(() {
      if (widget.data["qty"].toString() != ctrlQty.text.toString()) {
        widget.data["qty"] = double.parse(ctrlQty.text);
        widget.onChange!(widget.data);
      }
    });
  }

  @override
  void didUpdateWidget(covariant ItemPacket oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.data["qty"].toString() != oldWidget.data["qty"].toString()) {
      ctrlQty.text = widget.data["qty"].toString();
    }
  }

  @override
  void dispose() {
    super.dispose();
    ctrlQty.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: white1Color
                ),
                clipBehavior: Clip.hardEdge,
                child: Image.network("${widget.data["data"]?.img}", height: 40, fit: BoxFit.cover),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${widget.data["data"]?.name}", 
                      style: const TextStyle(color: blackColor, fontSize: 14, fontFamily: FontMedium), 
                      maxLines: 2, 
                      overflow: TextOverflow.ellipsis
                    ),
                    const SizedBox(height: 2),
                    Text(
                      parseRupiahCurrency("${widget.data["data"]?.price}"),
                      style: const TextStyle(color: greyTextColor, fontSize: 8), 
                    )                    
                  ],
                ),
              ),
              TouchableOpacity(
                onPress: () => widget.onDelete!(widget.data),
                child: const Icon(
                  Boxicons.bxs_trash,
                  color: redColor,
                  size: 16,
                ) 
              )
            ],
          ),
          Input(
            controller: ctrlQty,
            multiplication: true,
            margin: const EdgeInsets.only(top: 8),
          )
        ],
      )
    );
  }
}