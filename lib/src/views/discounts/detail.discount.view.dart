import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:haiyowangi/src/index.dart';

class DetailDiscountView extends StatefulWidget {

  final String data;

  const DetailDiscountView({
    super.key, 
    required this.data
  });

  @override
  State<DetailDiscountView> createState() => _DetailDiscountViewState();
}

class _DetailDiscountViewState extends State<DetailDiscountView> {

  final repository = DiscountRepository();
  final _controllerName = TextEditingController();
  final _controllerCode = TextEditingController();
  final _controllerNomPer = TextEditingController();
  final _controllerMultiplication = TextEditingController();
  final _controllerDateValid = TextEditingController();
  final _controllerValidUntil = TextEditingController();
  final _controllerMaxItemQty = TextEditingController();
  final _controllerMinItemQty = TextEditingController();
  
  late DiscountModel _discount;

  bool isEditing = false;
  dynamic specialFor;
  bool isPercentage = false;

  @override
  void initState() {
    super.initState();
    _discount = DiscountModel.fromJson(jsonDecode(widget.data));
    handlerGetDetail();
    setState(() {});
  }

  void handlerSearchProduct() async {

    var x = await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      barrierColor: Colors.transparent,
      clipBehavior: Clip.none,
      isScrollControlled: false,
      scrollControlDisabledMaxHeightRatio: .85,
      builder: (context) => const SearchProduct(showPacket: true),
    );

    if (x != null) {
      if (!(specialFor.runtimeType == x.runtimeType && specialFor.id == x.id) || specialFor == null) {
        setState(() {
          specialFor = x;
        });
      }
    }
  }

  Future<void> handlerGetDetail() async {
    
    Response response = await repository.getDetail("${_discount.id}");
    debugPrint(response.data.toString());
    if (response.statusCode == 200) {
      _discount = DiscountModel.fromJson(response.data!["data"]);
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
    
    _controllerName.text = _discount.name!;
    _controllerCode.text = _discount.code!;
    _controllerNomPer.text = _discount.isPercentage ? _discount.percentage.toString().split(".")[0] : _discount.nominal.toString().split(".")[0];
    _controllerMultiplication.text = _discount.multiplication.toString();
    _controllerDateValid.text = _discount.dateValid.toString();
    _controllerValidUntil.text = _discount.validUntil.toString();
    _controllerMaxItemQty.text = _discount.maxItemsQty!.toString();
    _controllerMinItemQty.text = _discount.minItemsQty.toString();

    isPercentage = _discount.isPercentage;

    if (_discount.specialForProductId != null) {
      specialFor = _discount.product;
    } else if (_discount.specialForVariantId != null) {
      specialFor = _discount.variant;
    } else if (_discount.specialForPacketId != null) {
      specialFor = _discount.packet;
    }

    isEditing = true;
    setState(() {});
  }

  Future<void> handlerUpdate() async {

    final data = {
      "name": _controllerName.text,
      "code": _controllerCode.text,
      "is_percentage": isPercentage,
      "percentage": parsePriceFromInput(_controllerNomPer.text),
      "nominal": parsePriceFromInput(_controllerNomPer.text),
      "multiplication": _controllerMultiplication.text,
      "date_valid": _controllerDateValid.text,
      "valid_until": _controllerValidUntil.text,
      "max_items_qty": _controllerMaxItemQty.text,
      "min_items_qty": _controllerMinItemQty.text,
    };

    if (specialFor != null) {
      if (specialFor.runtimeType == ProductModel) {
        data["special_for_product_id"] = specialFor.id;
      } else if (specialFor.runtimeType == VariantModel) {
        data["special_for_variant_id"] = specialFor.id;
      } else if (specialFor.runtimeType == PacketModel) {
        data["special_for_packet_id"] = specialFor.id;
      }
    }

    Response response = await repository.update("${_discount.id}", data);
    if (response.statusCode == 200) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text("Diskon telah diubah!"),
          backgroundColor: Colors.green,
        )
      );
      handlerGetDetail();
      isEditing = false;
      setState(() {});
    }
  }

  void handlerDelete() async {

    final response = await repository.delete("${_discount.id}");
    if (response.statusCode == 200) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text("Diskon berhasil dihapus!"),
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
          content: const Text("Apakah anda yakin ingin menghapus diskon ini?"),
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
      appBar: DetailHeader(title: _discount.code ?? "Detail Diskon"), 
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
                    InputDate(
                      controller: _controllerDateValid,
                      title: "Berlaku Mulai",
                      margin: const EdgeInsets.only(bottom: 6),
                    ),
                    InputDate(
                      controller: _controllerValidUntil,
                      title: "Berakhir Pada",
                      margin: const EdgeInsets.only(bottom: 6),
                    ),
                    Input(
                      controller: _controllerName,
                      title: "Nama",
                      margin: const EdgeInsets.only(bottom: 6),
                    ),
                    Input(
                      controller: _controllerCode,
                      title: "Kode Diskon",
                      margin: const EdgeInsets.only(bottom: 6),
                    ),
                    Input(
                      controller: _controllerMinItemQty,
                      multiplication: true,
                      title: "Minimal Jumlah Item",
                      margin: const EdgeInsets.only(bottom: 6),
                    ),
                    Input(
                      controller: _controllerMaxItemQty,
                      multiplication: true,
                      title: "Maksimal Jumlah Item",
                      margin: const EdgeInsets.only(bottom: 6),
                    ),
                    Input(
                      controller: _controllerMultiplication,
                      multiplication: true,
                      title: "Multiplikasi Diskon",
                      margin: const EdgeInsets.only(bottom: 6),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Input(
                            title: "Nominal Diskon",
                            controller: _controllerNomPer,
                            multiplication: isPercentage,
                            isCurrency: !isPercentage,
                          )
                        ),
                        TouchableOpacity(
                          onPress: () {
                            setState(() {
                              isPercentage = !isPercentage;
                            });
                          },
                          child: Container(
                            height: 45,
                            width: 45,
                            margin: const EdgeInsets.only(left: 6, bottom: 3.5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: isPercentage ? primaryColor :  Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.4),
                                  spreadRadius: 1,
                                  blurRadius: 1,
                                  offset: const Offset(0, 1),
                                )
                              ]
                            ),
                            child: Icon(
                              Icons.percent,
                              color: isPercentage ? Colors.white : greyDarkColor,
                              size: 20
                            ),
                          ), 
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Expanded(
                          child: Text("Terapkan pada produk, varian atau paket tertentu?")
                        ),
                        TouchableOpacity(
                          onPress: handlerSearchProduct,
                          child: Text(specialFor != null ? "Ubah" : "Atur", style: const TextStyle(color: blueColor)),
                        )
                      ],
                    ),
                    if (specialFor != null) Container(
                      margin: const EdgeInsets.only(top: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 40,
                            width: 40,
                            clipBehavior: Clip.hardEdge,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: white1Color
                            ),
                            child: (specialFor.img) != null ? Image.network(specialFor.img, fit: BoxFit.cover) : Image.asset(appImages["IMG_DEFAULT"]!, fit: BoxFit.cover),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(specialFor.name ?? "-", style: const TextStyle(fontSize: 16), maxLines: 2, overflow: TextOverflow.ellipsis),
                                Text(parseRupiahCurrency(specialFor.price.toString()), style: const TextStyle(fontSize: 10, color: greyTextColor)),
                              ],
                            )
                          ),
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2),
                              color: white1Color
                            ),
                            child: Text(specialFor.runtimeType == ProductModel ? "Produk" : specialFor.runtimeType == VariantModel ? "Varian" : "Paket", style: const TextStyle(color: greyTextColor, fontSize: 8)),
                          )
                        ],
                      )
                    )
                  ],
                ) : Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("#${_discount.code!}", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                          if (DateTime.parse(_discount.dateValid!).isBefore(DateTime.now())) Container(
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.all(Radius.circular(100)),
                              color: DateTime.parse(_discount.validUntil!).isAfter(DateTime.now()) ? greenLightColor : white1Color
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            child: Text(DateTime.parse(_discount.validUntil!).isAfter(DateTime.now()) ? "Sedang Aktif" : "Berakhir", style: TextStyle(color: DateTime.parse(_discount.validUntil!).isAfter(DateTime.now()) ? primaryColor : greyTextColor, fontSize: 10)),
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
                                const Text("Nama", style: TextStyle(fontSize: 12, color: greyTextColor)),
                                Text(_discount.name.toString(), style: const TextStyle(fontSize: 12))
                              ],
                            ),
                            const Divider(color: greyLightColor),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("Diskon", style: TextStyle(fontSize: 12, color: greyTextColor)),
                                Text(_discount.isPercentage ? "${_discount.percentage}%" : parseRupiahCurrency("${_discount.nominal}"), style: const TextStyle(fontSize: 12))
                              ],
                            ),
                            const Divider(color: greyLightColor),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("Minimal Item", style: TextStyle(fontSize: 12, color: greyTextColor)),
                                Text(_discount.minItemsQty! > 0 ? "${_discount.minItemsQty}" : "-", style: const TextStyle(fontSize: 12))
                              ],
                            ),
                            const Divider(color: greyLightColor),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("Maksimal Item", style: TextStyle(fontSize: 12, color: greyTextColor)),
                                Text(_discount.maxItemsQty! > 0 ? "${_discount.maxItemsQty}" : "-", style: const TextStyle(fontSize: 12))
                              ],
                            ),
                            const Divider(color: greyLightColor),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("Multiplikasi diskon", style: TextStyle(fontSize: 12, color: greyTextColor)),
                                Text(_discount.multiplication! > 0 ? "${_discount.multiplication}" : "-", style: const TextStyle(fontSize: 12))
                              ],
                            ),
                            const Divider(color: greyLightColor),
                            Row(
                              children: [
                                const Text("Diskon Spesial", style: TextStyle(fontSize: 12, color: greyTextColor)),
                                Expanded(
                                  child: Text(
                                    "${(_discount.specialForProductId != null) ? _discount.product!.name : (_discount.specialForVariantId != null) ? _discount.variant!.name : (_discount.specialForPacketId != null) ? _discount.packet!.name : "-"}", 
                                    style: const TextStyle(fontSize: 12),
                                    textAlign: TextAlign.right 
                                  )
                                )
                              ],
                            ),
                            const Divider(color: greyLightColor),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("Berlaku dari", style: TextStyle(fontSize: 12, color: greyTextColor)),
                                Text(formatDateFromString("${_discount.dateValid}", format: "EEEE, dd/MM/yyyy"), style: const TextStyle(fontSize: 12))
                              ],
                            ),
                            const Divider(color: greyLightColor),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("Berlaku sampai", style: TextStyle(fontSize: 12, color: greyTextColor)),
                                Text(formatDateFromString("${_discount.validUntil}", format: "EEEE, dd/MM/yyyy"), style: const TextStyle(fontSize: 12))
                              ],
                            ),
                            const Divider(color: greyLightColor),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("Terakhir diubah", style: TextStyle(fontSize: 12, color: greyTextColor)),
                                Text(formatDateFromString("${_discount.updatedAt}"), style: const TextStyle(fontSize: 12))
                              ],
                            ),
                            const Divider(color: greyLightColor),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("Dibuat pada", style: TextStyle(fontSize: 12, color: greyTextColor)),
                                Text(formatDateFromString("${_discount.createdAt}"), style: const TextStyle(fontSize: 12))
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