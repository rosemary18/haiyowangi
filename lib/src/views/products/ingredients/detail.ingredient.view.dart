import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:haiyowangi/src/index.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class DetailIngredientView extends StatefulWidget {

  final String data;

  const DetailIngredientView({
    super.key,
    required this.data
  });

  @override
  State<DetailIngredientView> createState() => _DetailIngredientViewState();
}

class _DetailIngredientViewState extends State<DetailIngredientView> {

  final repository = IngredientRepository();
  final unitRepository = UnitRepository();

  final _controllerName = TextEditingController();
  final _controllerQty = TextEditingController();

  late IngredientModel _ingredient; 

  List<UnitModel> units = [];

  bool isEditing = false;
  bool uploadingImage = false;
  String? unit;
  File? _image;

  @override
  void initState() {
    super.initState();
    _ingredient = IngredientModel.fromJson(jsonDecode(widget.data));
    handlerGetDetail();
    handlerGetUnits();
  }

  Future<void> handlerGetDetail() async {

    Response response = await repository.getDetail("${_ingredient.id}");
    if (response.statusCode == 200) {
      _ingredient = IngredientModel.fromJson(response.data!["data"]);
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

  Future<void> handlerGetUnits() async {

    Response res = await unitRepository.getData();
    if (res.statusCode == 200) {
      units.clear();
      for (var item in res.data!["data"]!) {
        var x = UnitModel.fromJson(item);
        units.add(x);
        if (_ingredient.uom != null && (_ingredient.uom!.id == x.id)) {
          unit = _ingredient.uom == null ? null : "${_ingredient.uom!.name} (${_ingredient.uom!.symbol})";
        }
      }
      setState(() {});
    }
  }

  Future<void> handlerUpdateImage() async {

    setState(() {
      uploadingImage = true;
    });

    FormData formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(_image!.path, filename: "image.png"),
    });

    Response response = await repository.uploadImage("${_ingredient.id}", formData);
    if (response.statusCode == 200) {
      _ingredient.img = response.data["data"]["img"];
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

  void handlerDelete() async {

    final response = await repository.delete("${_ingredient.id}");
    if (response.statusCode == 200) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text("Bahan telah dihapus ${_ingredient.name}!"),
          backgroundColor: Colors.green,
        )
      );
      Navigator.pop(context, true);
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

  void handlerEdit() {
    _controllerName.text = _ingredient.name!;
    _controllerQty.text = _ingredient.qty!.toString();
    setState(() {
      isEditing = true;
    });
  }

    void handlerSubmit() async {

    if (_controllerName.text.isEmpty || unit!.isEmpty) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text("Lengkapi data terlebih dahulu"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Map<String, dynamic> data = {
      "name": _controllerName.text,
      "qty": _controllerQty.text,
    };

    for (var i = 0; i < units.length; i++) {
      if ("${units[i].name} (${units[i].symbol})" == unit) {
        data["unit_id"] = units[i].id;
      }
    }

    Response res = await repository.update("${_ingredient.id}", data);
    if (res.statusCode == 200) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text("Bahan ${_ingredient.name} berhasil diubah!"),
          backgroundColor: Colors.green,
        )
      );
      Navigator.pop(context, true);
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
          content: Text("Apakah anda yakin ingin menghapus bahan ${_ingredient.name}?"),
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
      appBar: DetailHeader(
        title: "${_ingredient.name}",
      ), 
      backgroundColor: white1Color,
      body: Container(
        height: double.infinity,
        width: double.infinity,
        color: white1Color,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: isEditing ? Column(
                    children: [
                      Input(
                        controller: _controllerName,
                        title: "Nama",
                        margin: const EdgeInsets.only(bottom: 6),
                      ),
                      // Input(
                      //   controller: _controllerQty,
                      //   title: "Jumlah",
                      //   multiplication: true,
                      //   margin: const EdgeInsets.only(bottom: 6),
                      // ),          
                      InputDropDown(
                        title: "Satuan",
                        initialValue: unit,
                        placeholder: "Pilih satuan untuk bahan ini ...",
                        list: units.map((t) => "${t.name} (${t.symbol})").toList(),
                        margin: const EdgeInsets.only(bottom: 12),
                        onChanged: (v) {
                          setState(() {
                            unit = v;
                          });
                        },
                      ),
                    ],
                  ) : Row(
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
                                : (_ingredient.img != null && _ingredient.img!.isNotEmpty) ? Image.network(_ingredient.img!, width: 104, height: 104, fit: BoxFit.cover) 
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
                            const Text("Nama", style: TextStyle(color: greyTextColor, fontSize: 8)),
                            Text("${_ingredient.name!.isNotEmpty ? _ingredient.name : "-"}", style: const TextStyle(fontSize: 10), maxLines: 2, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 2),
                            const Text("Jumlah", style: TextStyle(color: greyTextColor, fontSize: 8)),
                            Text("${_ingredient.qty} ${_ingredient.uom?.name}", style: const TextStyle(fontSize: 10), maxLines: 2, overflow: TextOverflow.ellipsis),
                            const Text("Satuan", style: TextStyle(color: greyTextColor, fontSize: 8)),
                            Text((_ingredient.uom == null) ? "-" : "${_ingredient.uom?.name} (${_ingredient.uom?.symbol})", style: const TextStyle(fontSize: 10), maxLines: 2, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 2),
                            const Text("Terkait dengan produk", style: TextStyle(color: greyTextColor, fontSize: 8)),
                            Text(_ingredient.ingredients.isNotEmpty ? "Ya" : "Tidak", style: const TextStyle(fontSize: 10, color: blueColor), maxLines: 2, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 2),
                            const Text("Terakhir diubah", style: TextStyle(color: greyTextColor, fontSize: 8)),
                            Text(formatDateFromString(_ingredient.updatedAt.toString()), style: const TextStyle(fontSize: 10), maxLines: 2, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 2),
                            const Text("Dibuat pada", style: TextStyle(color: greyTextColor, fontSize: 8)),
                            Text(formatDateFromString(_ingredient.createdAt.toString()), style: const TextStyle(fontSize: 10), maxLines: 2, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 2),
                          ],
                        )
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
                      onPress: viewDeleteConfirm,
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
                      onPress: handlerSubmit,
                    )
                  ),
                ],
              ),
            ),
          ]
        ),
      )
    );
  }
}