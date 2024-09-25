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

class DetailVariantView extends StatefulWidget {

  final String data;

  const DetailVariantView({
    super.key,
    required this.data
  });

  @override
  State<DetailVariantView> createState() => _DetailVariantViewState();
}

class _DetailVariantViewState extends State<DetailVariantView> {

  final repository = VariantRepository();
  final ingredientRepository = IngredientRepository();
  final qtyController = TextEditingController();
  late VariantModel _variant; 

  bool uploadingImage = false;
  File? _image;
  IngredientItemModel? editIngredient;

  @override
  void initState() {
    super.initState();
    _variant = VariantModel.fromJson(jsonDecode(widget.data));
    handlerGetDetail();
  }

  Future<void> handlerGetDetail() async {

    Response response = await repository.getDetail("${_variant.id}");
    if (response.statusCode == 200) {
      _variant = VariantModel.fromJson(response.data!["data"]);
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

    Response response = await repository.uploadImage("${_variant.id}", formData);
    if (response.statusCode == 200) {
      _variant.img = response.data["data"]["img"];
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

    final response = await repository.delete("${_variant.id}");
    if (response.statusCode == 200) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text("Varian telah dihapus ${_variant.name}!"),
          backgroundColor: Colors.green,
        )
      );
      Navigator.pop(context, true);
    }
  }

  void handlerDeleteIngredient(IngredientItemModel item) async {

    final response = await ingredientRepository.deleteItem("${item.id}");
    if (response.statusCode == 200) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text("Bahan ${item.ingredient!.name} telah dihapus dari produk ${_variant.name}!"),
          backgroundColor: Colors.green,
        )
      );
      handlerGetDetail();
      setState(() {});
    }
  }

  Future<void> handlerAddIngredient(Map<String, dynamic> form) async {
    
    if (_variant.ingredients.isNotEmpty) {
      if (_variant.ingredients.any((e) => e.ingredientId == form["ingredient_id"])) {
        scaffoldMessengerKey.currentState?.showSnackBar(
          const SnackBar(
            content: Text("Bahan sudah ada di dalam varian ini."),
            backgroundColor: Colors.red,
          )
        );
        return;
      }
    }

    final data = {
      "items": [{
        "variant_id": _variant.id,
        ...form
      }]
    };

    final response = await ingredientRepository.addIngredientItem(data);
    if (response.statusCode == 200) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text("Bahan ditambahkan ke dalam varian!"),
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
          content: Text("Apakah anda yakin ingin menghapus varian ${_variant.name}?"),
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

  void viewDeleteIngredientConfirm(IngredientItemModel item) {
    showDialog(
      context: context, 
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
          titlePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          content: Text("Apakah anda yakin ingin menghapus bahan ${item.ingredient!.name} dari produk ${_variant.name}?"),
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
        title: "${_variant.name!.isNotEmpty ? _variant.name : "Detail Varian"}",
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
                                : (_variant.img != null && _variant.img!.isNotEmpty) ? Image.network(_variant.img!, width: 104, height: 104, fit: BoxFit.cover) 
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
                            const Text("Nama Varian", style: TextStyle(color: greyTextColor, fontSize: 8)),
                            Text("${_variant.name!.isEmpty ? "-" : _variant.name}", style: const TextStyle(fontSize: 10), maxLines: 2, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 2),
                            const Text("Satuan", style: TextStyle(color: greyTextColor, fontSize: 8)),
                            Text(_variant.unitId != null ? "${_variant.uom!.name!} (${_variant.uom!.symbol!})" : "-", style: const TextStyle(fontSize: 10), maxLines: 2, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 2),
                            const Text("Tampilkan di POS (Dijual)", style: TextStyle(color: greyTextColor, fontSize: 8)),
                            Text(_variant.isPublished! ? "Ya" : "Tidak", style: const TextStyle(fontSize: 10), maxLines: 2, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 10),
                            const Text("Detail", style: TextStyle(color: blackColor, fontSize: 12, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 10),
                            const Text("Varian", style: TextStyle(color: greyTextColor, fontSize: 8)),
                            Text(_variant.variants.map((i) => "${i.variantTypeItem!.name}").join(", "), style: const TextStyle(fontSize: 10, color: blueColor), maxLines: 2, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 10),
                            const Text("Deskripsi", style: TextStyle(color: greyTextColor, fontSize: 8)),
                            Text("${_variant.description!.isNotEmpty ? _variant.description : "-"}", style: const TextStyle(fontSize: 10), maxLines: 2, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 2),
                            const Text("Jumlah (Qty)", style: TextStyle(color: greyTextColor, fontSize: 8)),
                            Text("${_variant.qty.toString()} ${_variant.unitId != null ? _variant.uom!.name! : ""}", style: const TextStyle(fontSize: 10), maxLines: 2, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 2),
                            const Text("Harga Beli", style: TextStyle(color: greyTextColor, fontSize: 8)),
                            Text(parseRupiahCurrency(_variant.buyPrice.toString()), style: const TextStyle(fontSize: 10), maxLines: 2, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 2),
                            const Text("Harga Jual", style: TextStyle(color: greyTextColor, fontSize: 8)),
                            Text(parseRupiahCurrency(_variant.price.toString()), style: const TextStyle(fontSize: 10), maxLines: 2, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 10),
                            const Text("Log", style: TextStyle(color: blackColor, fontSize: 12, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 10),
                            const Text("Terakhir diubah", style: TextStyle(color: greyTextColor, fontSize: 8)),
                            Text(formatDateFromString(_variant.updatedAt!, format: "EEEE, dd/MM/yyyy HH:mm"), style: const TextStyle(fontSize: 10), maxLines: 2, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 2),
                            const Text("Dibuat pada", style: TextStyle(color: greyTextColor, fontSize: 8)),
                            Text(formatDateFromString(_variant.createdAt!, format: "EEEE, dd/MM/yyyy HH:mm"), style: const TextStyle(fontSize: 10), maxLines: 2, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 2),
                          ],
                        )
                      ),
                      TouchableOpacity(
                        onPress: () async {
                          var result = await context.pushNamed(appRoutes.editVariant.name, extra: jsonEncode(_variant));
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
                Row(
                  children: [
                    Expanded(
                      child: Text("Bahan (${_variant.ingredients.length})", style: const TextStyle(color: blackColor, fontSize: 16, fontWeight: FontWeight.w600)),
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
                const SizedBox(height: 10),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _variant.ingredients.length,
                  itemBuilder: (context, index) => cardIngredient(_variant.ingredients[index])
                ),
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