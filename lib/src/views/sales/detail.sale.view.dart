import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import 'package:haiyowangi/src/index.dart';

class DetailSaleView extends StatefulWidget {

  final String data;

  const DetailSaleView({
    super.key,
    required this.data
  });

  @override
  State<DetailSaleView> createState() => _DetailSaleViewState();
}

class _DetailSaleViewState extends State<DetailSaleView> {

  final repository = SalesRepository();
  final repositoryPayment = PaymentRepository();
  final repositoryDiscount = DiscountRepository();
  final qtyController = TextEditingController();
  final cashController = TextEditingController();
  final nominalController = TextEditingController();
  final bankAccController = TextEditingController();
  final bankAccNumController = TextEditingController();
  final bankRecAccController = TextEditingController();
  final bankRecAccNumController = TextEditingController();
  
  late SaleModel sale;

  SaleItemModel? editItem;
  List<PaymentTypeModel> paymentTypes = [];
  List<DiscountModel> discounts = [];

  String paymentType = "";
  String discount = "";
  File? img;

  @override
  void initState() {
    super.initState();
    sale = SaleModel.fromJson(jsonDecode(widget.data));
    handlerGetDetail();
    handlerGetPaymentTypes();
    handlerGetDiscounts();
  }

  void handlerGetPaymentTypes() async {
    
    Response response = await repositoryPayment.getTypes();
    if (response.statusCode == 200) {
      paymentTypes = (response.data!["data"] as List).map((e) => PaymentTypeModel.fromJson(e)).toList();
      setState(() {});
    }
  }

  void handlerGetDiscounts() async {
    
    Response response = await repositoryDiscount.getData("${sale.storeId}", queryParams: {"per_page": 1000, "is_active": true});
    if (response.statusCode == 200) {
      for (var item in response.data!["data"]!["discounts"]) {
        discounts.add(DiscountModel.fromJson(item));
      }
      setState(() {});
    }
  }

  Future<void> handlerGetDetail() async {

    Response response = await repository.getDetail("${sale.id}");
    if (response.statusCode == 200) {
      sale = SaleModel.fromJson(response.data!["data"]);
      paymentType = sale.paymentTypeId != null ? "${sale.paymentType!.name}" : "";
      discount = sale.discountId != null ? "${sale.discount!.code}" : "";
      setState(() {});
    } else {
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text(response.data["message"]! ?? response.statusMessage!),
          backgroundColor: Colors.red,
        ),
      );
      Navigator.pop(context);
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
      builder: (context) => const SearchProduct(multiple: true, showPacket: true),
    );

    if (x != null) {

      List<Map<String, dynamic>> items = [];

      for (var item in x) {

        bool exist = false;

        if (sale.items.isNotEmpty) {
          for (var e in sale.items) {
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
          if (item.runtimeType == ProductModel) {
            items.add({
              "qty": 1,
              "product_id": item.id
            });
          } else if (item.runtimeType == VariantModel) {
            items.add({
              "qty": 1,
              "variant_id": item.id
            });
          } else if (item.runtimeType == PacketModel) {
            items.add({
              "qty": 1,
              "packet_id": item.id
            });
          }
        }
      }

      handlerAddItem(items);
    }
  }

  void handlerSetPaymentType() async {

    String id = "";

    for (var e in paymentTypes) {
      if (e.name == paymentType) {
        id = e.id.toString();
        break;
      }
    }

    Response response = await repository.update("${sale.id}", {"payment_type_id": id});
    if (response.statusCode == 200) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text("Tipe pembayaran telah ditambahkan"),
          backgroundColor: Colors.green,
        ),
      );
      handlerGetDetail();
    } else {
      paymentType = sale.paymentTypeId != null ? "${sale.paymentType!.name}" : "";
      setState(() {});
    }
  }

  void handlerSetDiscount() async {

    String id = "";

    for (var e in discounts) {
      if (e.code == discount) {
        id = e.id.toString();
        break;
      }
    }

    Map<String, dynamic> data = {};

    if (id != "") {
      data["discount_id"] = id;
    } else {
      data["deleteDiscount"] = true;
    }

    Response response = await repository.update("${sale.id}", data);
    if (response.statusCode == 200) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text("Diskon telah diperbaharui"),
          backgroundColor: Colors.green,
        ),
      );
      handlerGetDetail();
    } else {
      discount = sale.discountId != null ? "${sale.discount!.code}" : "";
      setState(() {});
    }
  }

  void handlerAddItem(List<Map<String, dynamic>> items) async {

    if (items.isEmpty) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text("Item harus diisi atau item yang dipilih sudah ditambahkan!"),
          backgroundColor: Colors.red,
        )
      );
      return;
    }

    final data = {
      "items": items
    };

    Response response = await repository.update("${sale.id}", data);
    if (response.statusCode == 200) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text("Item baru telah ditambahkan"),
          backgroundColor: Colors.green,
        ),
      );
      handlerGetDetail();
    }
  }

  void handlerUpdateItem() async {
    
    final data = {
      "deleteItems" : [editItem!.id],
      "items": []
    };
    Map<String, dynamic> x = {
      "qty": qtyController.text
    };

    if (editItem!.productId != null) {
      x["product_id"] = editItem!.productId;
    } else if (editItem!.variantId != null) {
      x["variant_id"] = editItem!.variantId;
    } else if (editItem!.packetId != null) {
      x["packet_id"] = editItem!.packetId;
    }

    data["items"]!.add(x);

    Response response = await repository.update("${sale.id}", data);
    if (response.statusCode == 200) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text(response.data["message"]! ?? response.statusMessage!),
          backgroundColor: Colors.green,
        ),
      );
      handlerGetDetail();
    }
  }

  void handlerPayment() async {
    
    FormData formData = FormData.fromMap({
      "sales_id": sale.id
    });

    if (sale.paymentType!.code == "CASH") {
      formData.fields.add(
        MapEntry("cash", parsePriceFromInput(cashController.text))
      );
    } else {

      if (img == null) {
        scaffoldMessengerKey.currentState?.showSnackBar(
          const SnackBar(
            content: Text("Bukti pembayaran harus diisi"),
            backgroundColor: Colors.red,
          )
        );
        return;
      }

      formData.files.add(
        MapEntry("img", await MultipartFile.fromFile(img!.path, filename: "image.png"))
      );
      formData.fields.add(
        MapEntry("account_bank", bankAccController.text)
      );
      formData.fields.add(
        MapEntry("account_number", bankAccNumController.text)
      );
      formData.fields.add(
        MapEntry("receiver_account_bank", bankRecAccController.text)
      );
      formData.fields.add(
        MapEntry("receiver_account_number", bankRecAccNumController.text)
      );
      formData.fields.add(
        MapEntry("nominal", parsePriceFromInput(nominalController.text))
      );
    }

    Response response = await repository.createPayment(formData);
    if (response.statusCode == 200) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text(response.data["message"]! ?? response.statusMessage!),
          backgroundColor: Colors.green,
        ),
      );
      handlerGetDetail();
    }
  }

  void handlerDeleteItem(SaleItemModel item) async {
    
    final data = {
      "deleteItems" : [item.id]
    };

    Response response = await repository.update("${sale.id}", data);
    if (response.statusCode == 200) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text(response.data["message"]! ?? response.statusMessage!),
          backgroundColor: Colors.green,
        ),
      );
      handlerGetDetail();
    }
  }

  void handlerDelete() async {

    Response response = await repository.delete("${sale.id}");
    if (response.statusCode == 200) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text("Penjualan #${sale.code} telah dihapus!"),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    }
  }

  void handlerSetImage(File? x) async {

    setState(() {
      img = x;
    });
  }

  // Views

  void viewDeleteConfirm() {
    showDialog(
      context: context, 
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
          titlePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          content: Text("Apakah anda yakin ingin menghapus penjualan #${sale.code}?"),
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

  void viewDeleteItemConfirm(String name, SaleItemModel item) {
    showDialog(
      context: context, 
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
          titlePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          content: Text("Apakah anda yakin ingin menghapus item $name?"),
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
                handlerDeleteItem(item);
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

  void viewPay() {
    cashController.text = "${sale.invoice?.total ?? "0"}";
    nominalController.text = "${sale.invoice?.total ?? "0"}";
    img = null;
    showDialog(
      context: context, 
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Selesaikan Pembayaran', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
          titlePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          content: SizedBox(
            width: MediaQuery.of(context).size.width*.75,
            child: Column(
              children: paymentType.toLowerCase() == "cash" ? [
                Input(
                  controller: cashController,
                  isCurrency: true,
                  title: "Uang Tunai",
                )
              ] : [
                PickerImage(
                  img: img,
                  onSelected: handlerSetImage,
                ),
                const SizedBox(height: 12),
                Input(
                  controller: bankAccController,
                  placeholder: "Contoh: BRI/ANDI",
                  title: "Akun Bank",
                ),
                const SizedBox(height: 8),
                Input(
                  controller: bankAccNumController,
                  placeholder: "Contoh: 0331089675567",
                  title: "Nomor Akun Bank",
                ),
                const SizedBox(height: 8),
                Input(
                  controller: bankRecAccController,
                  placeholder: "Contoh: BRI/ANDI",
                  title: "Akun Bank Penerima",
                ),
                const SizedBox(height: 8),
                Input(
                  controller: bankRecAccNumController,
                  placeholder: "Contoh: 0331089675567",
                  title: "Nomor Akun Bank Penerima",
                ),
                const SizedBox(height: 8),
                Input(
                  controller: nominalController,
                  readOnly: true,
                  isCurrency: true,
                  title: "Nominal",
                )
              ],
            ),
          ),
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
          scrollable: true,
          shadowColor: primaryColor.withOpacity(0.2),
          insetPadding: EdgeInsets.symmetric(horizontal: isTablet ? MediaQuery.of(context).size.width/4 : 16),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          actions: [
            TouchableOpacity(
              onPress: () async {
                Navigator.pop(context);
                handlerPayment();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                margin: const EdgeInsets.only(left: 6),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: const Text(
                  'Bayar', 
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

  void viewSettingPaymentType() {

    List<String> lists = [];
    if (paymentType.isNotEmpty) {
      lists.add(paymentType);
    }

    if (paymentTypes.isNotEmpty) {
      for (var element in paymentTypes) {
        lists.add(element.name!);
      }
    }

    showDialog(
      context: context, 
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Atur Tipe Pembayaran', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
          titlePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          content: InputDropDown(
            placeholder: "Pilih tipe ...",
            list: lists.toSet().toList(),
            onChanged: (value) {
              paymentType = value!;
              setState(() {});
            },
          ),
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
          scrollable: true,
          shadowColor: primaryColor.withOpacity(0.2),
          insetPadding: EdgeInsets.symmetric(horizontal: isTablet ? MediaQuery.of(context).size.width/4 : 16),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          actions: [
            TouchableOpacity(
              onPress: () async {
                Navigator.pop(context);
                handlerSetPaymentType();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                margin: const EdgeInsets.only(left: 6),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: const Text(
                  'Simpan', 
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

  void viewSettingDiscount() {

    List<String> lists = ["Tidak Pakai Diskon"];
    if (discount.isNotEmpty) {
      lists.add(discount);
    }

    if (discounts.isNotEmpty) {
      for (var element in discounts) {
        lists.add(element.code!);
      }
    }

    showDialog(
      context: context, 
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Tambahkan Diskon', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
          titlePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          content: InputDropDown(
            placeholder: "Pilih diskon ...",
            list: lists.toSet().toList(),
            onChanged: (value) {
              discount = value == "Tidak Pakai Diskon" ? "" : value!;
              setState(() {});
            },
          ),
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
          scrollable: true,
          shadowColor: primaryColor.withOpacity(0.2),
          insetPadding: EdgeInsets.symmetric(horizontal: isTablet ? MediaQuery.of(context).size.width/4 : 16),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          actions: [
            TouchableOpacity(
              onPress: () async {
                Navigator.pop(context);
                handlerSetDiscount();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                margin: const EdgeInsets.only(left: 6),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: const Text(
                  'Simpan', 
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

  Widget cardItem(SaleItemModel item) {

    String name = "";
    int price = 0;
    String img = "";
    List<DiscountModel> xdiscounts = [];

    if (item.productId != null) {
      name = item.product!.name;
      price = item.product!.price;
      img = item.product!.img ?? "";
      xdiscounts = item.product!.discounts;
    } else if (item.variantId != null) {
      name = "${item.variant?.name}";
      price = item.variant!.price;
      img = item.variant!.img ?? "";
      xdiscounts = item.variant!.discounts;
    } else if (item.packetId != null) {
      name = "${item.packet?.name}";
      price = item.packet!.price;
      xdiscounts = item.packet!.discounts;
    }
    
    return Container(
      margin: const EdgeInsets.only(top: 8),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 40,
                width: 40,
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: white1Color
                ),
                child: img.isEmpty ? Image.asset(appImages["IMG_DEFAULT"]!, fit: BoxFit.cover) : Image.network(img, fit: BoxFit.cover),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600), maxLines: 2, overflow: TextOverflow.ellipsis),
                    Text("x${item.qty} @${parseRupiahCurrency(price.toString())} (${parseRupiahCurrency((price * (item.qty ?? 0)).toString())})", style: const TextStyle(fontSize: 8, color: greyTextColor)),
                    if (xdiscounts.isNotEmpty) ...xdiscounts.map((e) {
                      return Text("Diskon: ${e.code} (${e.isPercentage ? "${e.percentage}%" : parseRupiahCurrency(e.nominal.toString())})", style: const TextStyle(fontSize: 8, color: greyTextColor));
                    })
                  ],
                )
              ),
              const SizedBox(width: 8),
              if (editItem?.id != item.id && (sale.status == 0)) TouchableOpacity(
                onPress: () {
                  setState(() {
                    editItem = item;
                    qtyController.text = item.qty.toString();
                  });
                },
                child: const Icon(
                  Boxicons.bx_edit,
                  size: 13,
                  color: primaryColor
                ) 
              ),
              if (editItem?.id == item.id && (sale.status == 0)) TouchableOpacity(
                onPress: handlerUpdateItem,
                child: const Icon(
                  Boxicons.bx_check,
                  size: 13,
                  color: primaryColor
                ) 
              ),
              const SizedBox(width: 8),
              if (editItem?.id != item.id && (sale.status == 0)) TouchableOpacity(
                onPress: () => viewDeleteItemConfirm(name, item),
                child: const Icon(
                  Boxicons.bxs_trash,
                  size: 12,
                  color: redColor
                ) 
              ),
              if (editItem?.id == item.id && (sale.status == 0)) TouchableOpacity(
                onPress: () {
                  setState(() {
                    editItem = null;
                  });
                },
                child: const Icon(
                  Boxicons.bx_x_circle,
                  size: 12,
                  color: redColor
                ) 
              )
            ],
          ),
          if (editItem?.id == item.id && (sale.status == 0)) Input(
            controller: qtyController,
            margin: const EdgeInsets.only(top: 8),
            multiplication: true,
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DetailHeader(
        title: sale.code!,
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(bottom: 16, top: 16, left: 16, right: 16),
                        clipBehavior: Clip.none,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("#${sale.code!}", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.all(Radius.circular(100)),
                                        color: sale.status == 0 ? white1Color : sale.status == 1 ? greenLightColor : redLightColor
                                      ),
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      child: Text(sale.status == 0 ? "Pending" : sale.status == 1 ? "Selesai" : "Dibatalkan", style: TextStyle(color: sale.status == 0 ? greyTextColor : sale.status == 1 ?  primaryColor : redColor, fontSize: 10)),
                                    )
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  decoration: BoxDecoration(
                                    color: white1Color,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  padding: const EdgeInsets.all(8),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text("Dijual oleh", style: TextStyle(fontSize: 10, color: greyTextColor)),
                                          Text("${sale.staff != null ? sale.staff!.name : "Pemilik"}", style: TextStyle(fontSize: 10, color: sale.staff != null ? blackColor : blueColor))
                                        ],
                                      ),
                                      const Divider(color: greyLightColor),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text("Terakhir diubah", style: TextStyle(fontSize: 10, color: greyTextColor)),
                                          Text(formatDateFromString(sale.updatedAt ?? ""), style: const TextStyle(fontSize: 10)),
                                        ],
                                      ),
                                      const Divider(color: greyLightColor),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text("Dibuat pada", style: TextStyle(fontSize: 10, color: greyTextColor)),
                                          Text(formatDateFromString(sale.createdAt ?? ""), style: const TextStyle(fontSize: 10)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text("Item", style: TextStyle(fontSize: 14, fontFamily: FontBold)),
                                    if (sale.status == 0) Builder(builder: (context) {
                                      return TouchableOpacity(
                                        onPress: () => handlerSearchProduct(context),
                                        child: const Icon(
                                          Boxicons.bx_plus,
                                          size: 22,
                                          color: primaryColor
                                        ), 
                                      );
                                    })
                                  ],
                                ),
                                if (sale.items.isNotEmpty) const SizedBox(height: 4),
                                if (sale.items.isNotEmpty) ...sale.items.map(cardItem),
                                const SizedBox(height: 12),
                                const Text("Faktur", style: TextStyle(fontSize: 14, fontFamily: FontBold)),
                                const SizedBox(height: 10),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  margin: const EdgeInsets.only(bottom: 12),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.2),
                                        spreadRadius: 1,
                                        blurRadius: 1,
                                        offset: const Offset(0, 1),
                                      )
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                if (sale.status == 0) TouchableOpacity(
                                                  onPress: viewSettingPaymentType,
                                                  child: const Icon(
                                                    Boxicons.bx_cog,
                                                    size: 12,
                                                    color: blueColor
                                                  ),
                                                ),
                                                if (sale.status == 0) const SizedBox(width: 2),
                                                const Text("Tipe Pembayaran", style: TextStyle(fontSize: 10, color: greyTextColor)),
                                              ],
                                            )
                                          ),
                                          Text(paymentType.isNotEmpty ? paymentType : "-", style: const TextStyle(fontSize: 10)),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                if (sale.status == 0) TouchableOpacity(
                                                  onPress: viewSettingDiscount,
                                                  child: const Icon(
                                                    Boxicons.bx_cog,
                                                    size: 12,
                                                    color: blueColor
                                                  ),
                                                ),
                                                if (sale.status == 0) const SizedBox(width: 2),
                                                const Text("Diskon", style: TextStyle(fontSize: 10, color: greyTextColor)),
                                              ],
                                            )
                                          ),
                                          Text(sale.discount != null ? "${sale.discount!.code} (${sale.discount!.isPercentage ? "${sale.discount!.percentage}%" : parseRupiahCurrency(sale.discount!.nominal.toString())})" : "-", style: const TextStyle(fontSize: 10)),
                                        ],
                                      ),
                                      const Divider(color: greyLightColor),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text("Subtotal", style: TextStyle(fontSize: 10, color: greyTextColor)),
                                          Text(parseRupiahCurrency("${sale.invoice != null ? sale.invoice!.total : 0}"), style: const TextStyle(fontSize: 10)),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text("Diskon", style: TextStyle(fontSize: 10, color: greyTextColor)),
                                          Text(parseRupiahCurrency("${sale.invoice != null ? sale.invoice!.discount : 0}"), style: const TextStyle(fontSize: 10, color: redColor)),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text("Total", style: TextStyle(fontSize: 10, color: greyTextColor)),
                                          Text(parseRupiahCurrency("${sale.invoice != null ? sale.invoice!.total : 0}"), style: const TextStyle(fontSize: 10)),
                                        ],
                                      ),
                                      if (sale.status == 1 && (sale.paymentType != null && sale.paymentType!.code == "BT") ) Container(
                                        margin: const EdgeInsets.only(top: 4),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Divider(color: greyLightColor),
                                            const Text("Pembayaran", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
                                            const SizedBox(height: 6),
                                            Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  height: 80,
                                                  width: 80,
                                                  clipBehavior: Clip.hardEdge,
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(4),
                                                    color: white1Color
                                                  ),
                                                  child: (sale.invoice!.payment != null && sale.invoice!.payment!.img!.isNotEmpty) ? Image.network("${sale.invoice!.payment!.img}", fit: BoxFit.fill) : const SizedBox(),
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Column(
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          const Text("Akun Bank", style: TextStyle(fontSize: 9, color: greyTextColor)),
                                                          Text(sale.invoice?.payment?.accountBank ?? "-", style: const TextStyle(fontSize: 9)),
                                                        ],
                                                      ),
                                                      const SizedBox(height: 3),
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          const Text("Nomor Akun Bank", style: TextStyle(fontSize: 9, color: greyTextColor)),
                                                          Text(sale.invoice?.payment?.accountNumber ?? "-", style: const TextStyle(fontSize: 9)),
                                                        ],
                                                      ),
                                                      const SizedBox(height: 3),
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          const Text("Akun Bank Penerima", style: TextStyle(fontSize: 9, color: greyTextColor)),
                                                          Text(sale.invoice?.payment?.receiverAccountBank ?? "-", style: const TextStyle(fontSize: 9)),
                                                        ],
                                                      ),
                                                      const SizedBox(height: 3),
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          const Text("Nomor Akun Bank Penerima", style: TextStyle(fontSize: 9, color: greyTextColor)),
                                                          Text(sale.invoice?.payment?.receiverAccountNumber ?? "-", style: const TextStyle(fontSize: 9)),
                                                        ],
                                                      ),
                                                      const SizedBox(height: 3),
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          const Text("Nominal", style: TextStyle(fontSize: 9, color: greyTextColor)),
                                                          Text(parseRupiahCurrency("${sale.invoice?.payment!.nominal}"), style: const TextStyle(fontSize: 9)),
                                                        ],
                                                      ),
                                                    ],
                                                  )
                                                )
                                              ],
                                            ),
                                          ]
                                        ) 
                                      ),
                                      if (sale.status == 1 && !(sale.paymentType != null && sale.paymentType!.code == "BT") ) Container(
                                        margin: const EdgeInsets.only(top: 4),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Divider(color: greyLightColor),
                                            const Text("Pembayaran", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
                                            const SizedBox(height: 4),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                const Text("Cash", style: TextStyle(fontSize: 10, color: greyTextColor)),
                                                Text(parseRupiahCurrency("${sale.invoice != null ? sale.invoice!.cash : 0}"), style: const TextStyle(fontSize: 10)),
                                              ],
                                            ),
                                            const SizedBox(height: 6),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                const Text("Kembalian", style: TextStyle(fontSize: 10, color: greyTextColor)),
                                                Text(parseRupiahCurrency("${sale.invoice != null ? sale.invoice!.changeMoney : 0}"), style: const TextStyle(fontSize: 10)),
                                              ],
                                            ),
                                          ]
                                        ) 
                                      )
                                    ],
                                  ),
                                ),
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
            if (sale.status == 0) Container(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: ButtonOpacity(
                      onPress: viewDeleteConfirm,
                      text: "Hapus",
                      backgroundColor: redLightColor,
                      textColor: redColor
                    )
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ButtonOpacity(
                      text: "Bayar",
                      backgroundColor: primaryColor,
                      textColor: Colors.white,
                      onPress: viewPay,
                      disabled: sale.invoice == null || sale.paymentTypeId == null
                    )
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}