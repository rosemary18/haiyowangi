import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:haiyowangi/src/index.dart';

class FormDiscountView extends StatefulWidget {
  const FormDiscountView({super.key});

  @override
  State<FormDiscountView> createState() => _FormDiscountViewState();
}

class _FormDiscountViewState extends State<FormDiscountView> {

  final repository = DiscountRepository();
  final _controllerName = TextEditingController();
  final _controllerCode = TextEditingController();
  final _controllerNomPer = TextEditingController();
  final _controllerMultiplication = TextEditingController();
  final _controllerDateValid = TextEditingController();
  final _controllerValidUntil = TextEditingController();
  final _controllerMaxItemQty = TextEditingController();
  final _controllerMinItemQty = TextEditingController();

  dynamic specialFor;
  bool isPercentage = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
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

  void handlerSubmit() async {

    if (_controllerName.text.isEmpty) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text("Nama diskon harus diisi!"),
          backgroundColor: Colors.red,
        )
      );
      return;
    }

    if (_controllerCode.text.isEmpty) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text("Kode diskon harus diisi!"),
          backgroundColor: Colors.red,
        )
      );
      return;
    }

    if (_controllerDateValid.text.isEmpty) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text("Waktu berlaku diskon harus diisi!"),
          backgroundColor: Colors.red,
        )
      );
      return;
    }

    if (_controllerValidUntil.text.isEmpty) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text("Waktu berakhir diskon harus diisi!"),
          backgroundColor: Colors.red,
        )
      );
      return;
    }

    final data = {
      "store_id": context.read<AuthBloc>().state.store?.id,
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

    Response response = await repository.create(data);

    if (response.statusCode == 200) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text("Diskon baru telah ditambahkan!"),
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
      appBar: const FormHeader(title: "Tambah Diskon"),
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