import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import 'package:go_router/go_router.dart';
import 'package:haiyowangi/src/index.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class DetailProductView extends StatefulWidget {

  final String data;

  const DetailProductView({
    super.key,
    required this.data
  });

  @override
  State<DetailProductView> createState() => _DetailProductViewState();
}

class _DetailProductViewState extends State<DetailProductView> {

  final repository = ProductRepository();
  final variantRepository = VariantRepository();
  final ingredientRepository = IngredientRepository();
  final qtyController = TextEditingController();
  late ProductModel _product; 

  bool uploadingImage = false;
  File? _image;
  IngredientItemModel? editIngredient;

  @override
  void initState() {
    super.initState();
    _product = ProductModel.fromJson(jsonDecode(widget.data));
    handlerGetDetail();
  }

  Future<void> handlerGetDetail() async {

    Response response = await repository.getDetail("${_product.id}");
    if (response.statusCode == 200) {
      _product = ProductModel.fromJson(response.data!["data"]);
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

  Future<void> handlerUpdateImage() async {

    setState(() {
      uploadingImage = true;
    });

    FormData formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(_image!.path, filename: "image.png"),
    });

    Response response = await repository.uploadImage("${_product.id}", formData);
    if (response.statusCode == 200) {
      _product.img = response.data["data"]["img"];
      scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text("Gambar berhasil diubah!"),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text(response.data["message"]! ?? response.statusMessage!),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() {
      _image = null;
      uploadingImage = false;
    });
  }

  void handlerUpdateIngredient() async {

    if (qtyController.text.isEmpty || qtyController.text == "0") {
      scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text("Jumlah harus lebih dari 0!"),
          backgroundColor: Colors.red,
        )
      );
      return;
    }

    final data = {
      "qty": qtyController.text
    };

    final response = await ingredientRepository.updateItem("${editIngredient!.id}", data);
    if (response.statusCode == 200) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text("Bahan ${editIngredient!.ingredient!.name} telah diupdate!"),
          backgroundColor: Colors.green,
        )
      );
      handlerGetDetail();
    }

    editIngredient = null;
    setState(() {});
  }

  void handlerDelete() async {

    final response = await repository.delete("${_product.id}");
    if (response.statusCode == 200) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text("Produk telah dihapus ${_product.name}!"),
          backgroundColor: Colors.green,
        )
      );
      Navigator.pop(context, true);
    }
  }

  void handlerDeleteVariant(VariantModel variant) async {
    
    final response = await variantRepository.delete("${variant.id}");
    if (response.statusCode == 200) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text("Varian ${variant.name} telah dihapus dari produk ${_product.name}!"),
          backgroundColor: Colors.green,
        )
      );
      handlerGetDetail();
    }
  }

  void handlerDeleteIngredient(IngredientItemModel item) async {

    final response = await ingredientRepository.deleteItem("${item.id}");
    if (response.statusCode == 200) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text("Bahan ${item.ingredient!.name} telah dihapus dari produk ${_product.name}!"),
          backgroundColor: Colors.green,
        )
      );
      handlerGetDetail();
      setState(() {});
    }
  }

  Future<void> handlerAddIngredient(Map<String, dynamic> form) async {
    
    if (_product.ingredients.isNotEmpty) {
      // Check if ingredient already exists
      if (_product.ingredients.any((e) => e.ingredientId == form["ingredient_id"])) {
        scaffoldMessengerKey.currentState?.showSnackBar(
          const SnackBar(
            content: Text("Bahan sudah ada di dalam produk ini."),
            backgroundColor: Colors.red,
          )
        );
        return;
      }
    }

    final data = {
      "items": [{
        "product_id": _product.id,
        ...form
      }]
    };

    final response = await ingredientRepository.addIngredientItem(data);
    if (response.statusCode == 200) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text("Bahan ditambahkan ke dalam produk!"),
          backgroundColor: Colors.green,
        )
      );
      handlerGetDetail();
      setState(() {});
    }
  }

  Future<void> _pickImage() async {

    if (uploadingImage) return;

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      await handlerUpdateImage();
    }
  }

  void viewDeleteConfirm() {
    showDialog(
      context: context, 
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
          titlePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          content: Text("Apakah anda yakin ingin menghapus produk ${_product.name}?"),
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

  void viewDeleteConfirmVariant(VariantModel variant) {
    showDialog(
      context: context, 
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
          titlePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          content: Text("Apakah anda yakin ingin menghapus variant ${variant.name}?"),
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
                handlerDeleteVariant(variant);
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

  void viewDeleteIngredientConfirm(IngredientItemModel item) {
    showDialog(
      context: context, 
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
          titlePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          content: Text("Apakah anda yakin ingin menghapus bahan ${item.ingredient!.name} dari produk ${_product.name}?"),
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
                handlerDeleteIngredient(item);
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

  void viewAddIngredientModal() async {

    var result = await showDialog(
      context: context,
      builder: (BuildContext context) => const ModalAddIngredient(),
    );

    if (result != null) {
      handlerAddIngredient(result);
    }
  }

  Widget cardVariant(VariantModel variant) {
    return TouchableOpacity(
      onPress: () async {
        var result = await context.pushNamed(appRoutes.detailVariant.name, extra: jsonEncode(variant));
        if (result != null) {
          handlerGetDetail();
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4.0),
          boxShadow: const [BoxShadow(color: Color.fromARGB(24, 0, 0, 0), spreadRadius: 1, blurRadius: 1, offset: Offset(1, 1))]
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 44,
              width: 44,
              margin: const EdgeInsets.only(right: 8),
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                color: greyColor,
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: variant.img!.isNotEmpty ? 
                Image.network(variant.img!, width: 44, height: 44, fit: BoxFit.cover) 
                : Image.asset(appImages["IMG_DEFAULT"]!, width: 40, height: 40, fit: BoxFit.cover),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("${variant.name}", style: const TextStyle(fontSize: 12, fontFamily: FontMedium), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(parseRupiahCurrency(variant.price.toString()), style: const TextStyle(fontSize: 8, color: greyTextColor)),
                  Text("${variant.qty} ${variant.uom?.name!}", style: const TextStyle(fontSize: 8, color: greyTextColor)),
                ],
              ),
            ),
            TouchableOpacity(
              onPress: () => viewDeleteConfirmVariant(variant),
              child: Container(
                padding: const EdgeInsets.only(left: 10),
                child: const Icon(
                  Boxicons.bxs_trash,
                  size: 16,
                  color: redColor,
                ),
              ) 
            ),
          ],
        )
      ), 
    );
  }

  Widget cardIngredient(IngredientItemModel item) {

    bool isEdit = item.id == editIngredient?.id;

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4.0),
        boxShadow: const [BoxShadow(color: Color.fromARGB(24, 0, 0, 0), spreadRadius: 1, blurRadius: 1, offset: Offset(1, 1))]
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 44,
                width: 44,
                margin: const EdgeInsets.only(right: 8),
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  color: greyColor,
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: item.ingredient!.img!.isNotEmpty ? 
                  Image.network(item.ingredient!.img!, width: 44, height: 44, fit: BoxFit.cover) 
                  : Image.asset(appImages["IMG_DEFAULT"]!, width: 40, height: 40, fit: BoxFit.cover),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("${item.ingredient?.name}", style: const TextStyle(fontSize: 12, fontFamily: FontMedium), maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text("${item.qty} ${item.ingredient?.uom?.name!} • (${item.ingredient?.qty!} ${item.ingredient?.uom?.name!})", style: const TextStyle(fontSize: 8, color: greyTextColor)),
                  ],
                ),
              ),
              if (!isEdit) TouchableOpacity(
                onPress: () {
                  setState(() {
                    qtyController.text = "${item.qty}";
                    editIngredient = item;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.only(left: 10),
                  child: const Icon(
                    Boxicons.bx_edit,
                    size: 16,
                    color: primaryColor,
                  ),
                ) 
              ),
              if (!isEdit) TouchableOpacity(
                onPress: () => viewDeleteIngredientConfirm(item),
                child: Container(
                  padding: const EdgeInsets.only(left: 10),
                  child: const Icon(
                    Boxicons.bxs_trash,
                    size: 16,
                    color: redColor,
                  ),
                ) 
              ),
              if (isEdit) TouchableOpacity(
                onPress: handlerUpdateIngredient,
                child: Container(
                  padding: const EdgeInsets.only(left: 10),
                  child: const Icon(
                    Boxicons.bxs_check_circle,
                    size: 16,
                    color: primaryColor,
                  ),
                ) 
              ),
              if (isEdit) TouchableOpacity(
                onPress: () {
                  setState(() {
                    editIngredient = null;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.only(left: 10),
                  child: const Icon(
                    Boxicons.bxs_x_circle,
                    size: 16,
                    color: redColor,
                  ),
                ) 
              ),
            ],
          ),
          if (isEdit) Input(
            controller: qtyController,
            multiplication: true,
            margin: const EdgeInsets.only(top: 8),
          )
        ],
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DetailHeader(
        title: _product.name.isNotEmpty ? _product.name : "Detail Produk",
        actions: [
          TouchableOpacity(
            onPress: viewDeleteConfirm,
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              child: const Icon(
                Boxicons.bxs_trash,
                size: 18,
                color: redColor,
              ),
            ), 
          )
        ],
      ), 
      backgroundColor: white1Color,
      body: Container(
        height: double.infinity,
        width: double.infinity,
        color: white1Color,
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                    boxShadow: [BoxShadow(color: Color.fromARGB(24, 0, 0, 0), spreadRadius: 1, blurRadius: 1, offset: Offset(1, 1))]
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TouchableOpacity(
                        onPress: _pickImage,
                        child: Container(
                          margin: const EdgeInsets.only(right: 12),
                          width: 100,
                          height: 100,
                          clipBehavior: Clip.hardEdge,
                          decoration: BoxDecoration(
                            color: greyColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Stack(
                            children: [
                              (_image != null) ? Image.file(_image!, width: 100, height: 100, fit: BoxFit.cover) 
                                : (_product.img != null && _product.img!.isNotEmpty) ? Image.network(_product.img!, width: 104, height: 104, fit: BoxFit.cover) 
                                : Image.asset(
                                  appImages["IMG_DEFAULT"]!, 
                                  width: 104, 
                                  height: 104, 
                                  fit: BoxFit.cover
                              ),
                              if (uploadingImage) Container(
                                color: Colors.black.withOpacity(0.1),
                                child: Center(
                                  child: LoadingAnimationWidget.threeRotatingDots(color: white1Color, size: 16)
                                ),
                              )
                            ],
                          )
                        ), 
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Text("Nama produk", style: TextStyle(color: greyTextColor, fontSize: 8)),
                            Text(_product.name.isNotEmpty ? _product.name : "-", style: const TextStyle(fontSize: 10), maxLines: 2, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 2),
                            const Text("Satuan", style: TextStyle(color: greyTextColor, fontSize: 8)),
                            Text(_product.unitId != null ? "${_product.uom!.name!} (${_product.uom!.symbol!})" : "-", style: const TextStyle(fontSize: 10), maxLines: 2, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 2),
                            const Text("Tampilkan di POS (Dijual)", style: TextStyle(color: greyTextColor, fontSize: 8)),
                            Text(_product.isPublished! ? "Ya" : "Tidak", style: const TextStyle(fontSize: 10), maxLines: 2, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 10),
                            const Text("Detail", style: TextStyle(color: blackColor, fontSize: 12, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 10),
                            const Text("Deskripsi", style: TextStyle(color: greyTextColor, fontSize: 8)),
                            Text("${_product.description!.isNotEmpty ? _product.description : "-"}", style: const TextStyle(fontSize: 10), maxLines: 2, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 2),
                            const Text("Jumlah (Qty)", style: TextStyle(color: greyTextColor, fontSize: 8)),
                            (_product.hasVariants!) ? const Text("Mengikuti varian", style: TextStyle(fontSize: 10, color: blueColor))
                            : Text("${formatDouble(_product.qty ?? 0.0)} ${_product.uom?.name}", style: const TextStyle(fontSize: 10)),
                            const SizedBox(height: 2),
                            const Text("Harga Beli", style: TextStyle(color: greyTextColor, fontSize: 8)),
                            Text(parseRupiahCurrency(_product.buyPrice.toString()), style: const TextStyle(fontSize: 10), maxLines: 2, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 2),
                            const Text("Harga Jual", style: TextStyle(color: greyTextColor, fontSize: 8)),
                            Text(parseRupiahCurrency(_product.price.toString()), style: const TextStyle(fontSize: 10), maxLines: 2, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 2),
                            const Text("Memiliki varian", style: TextStyle(color: greyTextColor, fontSize: 8)),
                            Text(_product.hasVariants! ? "Ya" : "Tidak", style: const TextStyle(fontSize: 10), maxLines: 2, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 2),
                            const SizedBox(height: 10),
                            const Text("Log", style: TextStyle(color: blackColor, fontSize: 12, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 10),
                            const Text("Terakhir diubah", style: TextStyle(color: greyTextColor, fontSize: 8)),
                            Text(formatDateFromString(_product.updatedAt!, format: "EEEE, dd/MM/yyyy HH:mm"), style: const TextStyle(fontSize: 10), maxLines: 2, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 2),
                            const Text("Dibuat pada", style: TextStyle(color: greyTextColor, fontSize: 8)),
                            Text(formatDateFromString(_product.createdAt!, format: "EEEE, dd/MM/yyyy HH:mm"), style: const TextStyle(fontSize: 10), maxLines: 2, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 2),
                          ],
                        )
                      ),
                      TouchableOpacity(
                        onPress: () async {
                          var result = await context.pushNamed(appRoutes.editProduct.name, extra: jsonEncode(_product));
                          if (result != null) {
                            handlerGetDetail();
                          }
                        },
                        child: const Icon(
                          Boxicons.bx_edit,
                          color: primaryColor,
                          size: 18,
                        ), 
                      )
                    ],
                  ),
                ),
                if (_product.variants.isEmpty) Row(
                  children: [
                    Expanded(
                      child: Text("Bahan (${_product.ingredients.length})", style: const TextStyle(color: blackColor, fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                    TouchableOpacity(
                      onPress: viewAddIngredientModal,
                      child: const Icon(
                        Boxicons.bx_plus,
                        color: primaryColor,
                        size: 22,
                      ), 
                    )
                  ]
                ),
                if (_product.variants.isEmpty && _product.ingredients.isNotEmpty) const SizedBox(height: 10),
                if (_product.variants.isEmpty && _product.ingredients.isNotEmpty) ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _product.ingredients.length,
                  itemBuilder: (context, index) => cardIngredient(_product.ingredients[index])
                ),
                if (_product.variants.isEmpty) const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Text("Varian (${_product.variants.length})", style: const TextStyle(color: blackColor, fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                    if (_product.variant_types.isNotEmpty && _product.variant_types[0].variants.isNotEmpty) TouchableOpacity(
                      onPress: () async {
                        var result = await context.pushNamed(appRoutes.formVariant.name, extra: jsonEncode(_product));
                        if (result != null) {
                          handlerGetDetail();
                        }
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        child: const Icon(
                          Boxicons.bx_plus,
                          color: primaryColor,
                          size: 22,
                        ),
                      ), 
                    ),
                    TouchableOpacity(
                      onPress: () async {
                        var result = await context.pushNamed(appRoutes.manageVariant.name, extra: jsonEncode(_product));
                        if (result != null) {
                          handlerGetDetail();
                        }
                      },
                      child: const Icon(
                        Boxicons.bx_cog,
                        color: primaryColor,
                        size: 20,
                      ), 
                    )
                  ]
                ),
                const SizedBox(height: 12),
                if (_product.variants.isNotEmpty) ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _product.variants.length,
                  itemBuilder: (context, index) => cardVariant(_product.variants[index])
                )
              ],
            ),
          ),
        ),
      )
    );
  }
}

class ModalAddIngredient extends StatefulWidget {
  const ModalAddIngredient({super.key});

  @override
  State<ModalAddIngredient> createState() => _ModalAddIngredientState();
}

class _ModalAddIngredientState extends State<ModalAddIngredient> {

  final repository = IngredientRepository();
  final _inputIngredientController = TextEditingController();
  FocusNode? focusNodeIngredient;
  final _inputQtyController = TextEditingController();

  List<IngredientModel> ingredients = [];
  Timer? timeId;

  Future<void> handlerSearchIngredients() async {

    if (_inputIngredientController.text.isEmpty) {
      ingredients.clear();
      setState(() {});
      focusNodeIngredient?.requestFocus();
      return;
    } else {

      if (timeId != null) {
        timeId?.cancel();
      }

      timeId = Timer(const Duration(milliseconds: 500), () async {
        var state = context.read<AuthBloc>().state;
        var queryParams = {
          "search_text": _inputIngredientController.text
        };
        
        final response = await repository.getData("${state.store!.id}", queryParams: queryParams);
        
        if (response.statusCode == 200) {
          ingredients.clear();
          for (var item in response.data!["data"]!["ingredients"]) {
            ingredients.add(IngredientModel.fromJson(item));
          }
          setState(() {});
          focusNodeIngredient!.requestFocus();
        }
      });
    }
  }

  void handlerSubmit() {

    if (_inputIngredientController.text.isEmpty) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(content: Text("Bahan harus diisi."), duration: Duration(seconds: 2), backgroundColor: redColor),
      );
      return;
    }
    
    if (_inputQtyController.text.isEmpty) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(content: Text("Jumlah harus lebih dari 0."), duration: Duration(seconds: 2), backgroundColor: redColor),
      );
    }

    IngredientModel? ingredient;
    for (var item in ingredients) {
      if (item.name == _inputIngredientController.text) {
        ingredient = item;
        break;
      }
    }

    if (ingredient != null) {
      Navigator.pop(context, {
        "ingredient_id": ingredient.id,
        "unit_id": ingredient.unitId,
        "qty": _inputQtyController.text
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Tambah Bahan', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
      titlePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      content: SizedBox(
        width: MediaQuery.of(context).size.width*.75,
        child: Column(
          children: [
            Input(
              controller: _inputIngredientController,
              focusNode: focusNodeIngredient,
              title: "Bahan",
              placeholder: "Pilih Bahan",
              maxCharacter: 50,
              onChanged: (v) => handlerSearchIngredients(),
              suggestions: ingredients.map((e) => "${e.name}").toList(),
            ),
            Input(
              controller: _inputQtyController,
              title: "Jumlah",
              maxCharacter: 50,
              multiplication: true,
            ),
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
          onPress: handlerSubmit,
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
}