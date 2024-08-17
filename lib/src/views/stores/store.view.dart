import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:haiyowangi/src/index.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class StoreView extends StatefulWidget {

  const StoreView({super.key});

  @override
  State<StoreView> createState() => _StoreViewState();
}

class _StoreViewState extends State<StoreView> {

  final TextEditingController _inputController = TextEditingController();
  final StoreRepository _storeRepository = StoreRepository();
  File? _image;
  bool uploadingImage = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _pickImage() async {

    if (uploadingImage) return;

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      await handlerUpdateStoreImage();
    }
  }

  Future<void> handlerUpdateStoreImage() async {

    setState(() {
      uploadingImage = true;
    });

    final state = context.read<AuthBloc>().state;
    FormData formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(_image!.path, filename: "image.png"),
    });

    Response response = await _storeRepository.uploadStoreImage("${state.store?.id}", formData);
    if (response.statusCode == 200) {
      state.store = StoreModel.fromJson(response.data["data"]);
      context.read<AuthBloc>().add(AuthUpdateState(state: state));
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

  Future<void> handlerUpdateStoreData(String type) async {
    
    Map<String, dynamic> data = {};

    if (type == "name") {
      data = {"name": _inputController.text};
    } else if (type == "address") {
      data = {"address": _inputController.text};
    }

    final state = context.read<AuthBloc>().state;
    Response response = await _storeRepository.updateStore("${state.store?.id}", jsonEncode(data));
    if (response.statusCode == 200) {
      state.store = StoreModel.fromJson(response.data["data"]);
      context.read<AuthBloc>().add(AuthUpdateState(state: state));
      scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text("Toko berhasil diubah!"),
          backgroundColor: Colors.green,
        ),
      );
      setState(() {});
    }
  }

  Future<void> handlerDeleteStore() async {
    
    final state = context.read<AuthBloc>().state;
    Response response = await _storeRepository.deleteStore("${state.store?.id}");
    if (response.statusCode == 200) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text("Toko berhasil dihapus!"),
          backgroundColor: Colors.green,
        ),
      );
      context.read<AuthBloc>().add(AuthLogout());
    }
  }
  
  // Views

  void viewUpdateModal(String type) {
    _inputController.clear();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Ubah info toko', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
          titlePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          content: SizedBox(
            width: MediaQuery.of(context).size.width*.75,
            child: Column(
              children: [
                (type == "phone") ? InputPhone(controller: _inputController) : Input(
                  controller: _inputController,
                  placeholder: type == "name" ? "Nama" : "Alamat",
                  maxCharacter: 50,
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
                handlerUpdateStoreData(type);
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
      },
    );
  }

  void viewConfirmDeleteModal() {
    var state = context.read<AuthBloc>().state;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Penghapusan Toko', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
          titlePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          content: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Apakah kamu yakin ingin menghapus toko ${state.store?.name}?", style: const TextStyle(color: Colors.black, fontSize: 12)),
              const SizedBox(height: 8),
              const Text("Kamu akan otomatis keluar dan login ulang setelah penghapusan toko berhasil!", style: TextStyle(color: Colors.black, fontSize: 12)),
            ],
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
              onPress: () async {
                Navigator.pop(context);
                handlerDeleteStore();
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
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (c, s) {},
        builder: (c, s) => SizedBox(
          height: double.infinity,
          width: double.infinity,
          child: Column(
            children: [
              Container(
                color: primaryColor,
                height: 120,
              ),
              Expanded(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      color: Colors.white,
                      height: double.infinity,
                      width: double.infinity,
                      padding: const EdgeInsets.only(left: 12, top: 72, right: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Center(
                            child: Text("${s.store?.name}", style: const TextStyle(color: Color.fromARGB(180, 9, 9, 9), fontFamily: FontMedium, fontSize: 12))
                          ),
                          Center(
                            child: Text("Terakhir sinkronasi: ${s.store!.lastSync!.isNotEmpty ? formatDateFromString(s.store!.lastSync!) : "-"}", style: const TextStyle(color: Color.fromARGB(180, 9, 9, 9), fontSize: 10))
                          ),
                          Expanded(
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                              padding: const EdgeInsets.only(top: 12),
                              child: Column(
                                children: [
                                  Container(
                                    margin: const EdgeInsets.symmetric(vertical: 4),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Text("Nama", style: TextStyle(color: blackColor, fontSize: 13, fontFamily: FontMedium)),
                                              Text(
                                                "${s.store!.name}", 
                                                style: const TextStyle(color: greyTextColor, fontSize: 12, fontWeight: FontWeight.w400), 
                                                maxLines: 2, 
                                                overflow: TextOverflow.ellipsis
                                              ),
                                            ],
                                          )
                                        ),
                                        TouchableOpacity(
                                          onPress: () => viewUpdateModal("name"),
                                          child: const Icon(
                                            Icons.mode_edit_outline_outlined,
                                            size: 16,
                                            color: primaryColor,
                                          ), 
                                        )
                                      ],
                                    ),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.symmetric(vertical: 4),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Text("Alamat", style: TextStyle(color: blackColor, fontSize: 13, fontFamily: FontMedium)),
                                              Text(
                                                "${s.store!.address}", 
                                                style: const TextStyle(color: greyTextColor, fontSize: 12, fontWeight: FontWeight.w400), 
                                                maxLines: 2, 
                                                overflow: TextOverflow.ellipsis
                                              ),
                                            ],
                                          )
                                        ),
                                        TouchableOpacity(
                                          onPress: () => viewUpdateModal("address"),
                                          child: const Icon(
                                            Icons.mode_edit_outline_outlined,
                                            size: 16,
                                            color: primaryColor,
                                          ), 
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ),
                          ButtonOpacity(
                            onPress: viewConfirmDeleteModal,
                            margin: const EdgeInsets.symmetric(vertical: 12),
                            backgroundColor: redLightColor,
                            text: "Hapus Toko",
                            textColor: redColor,
                          )
                        ],
                      ),
                    ),
                    Positioned(
                      top: -60,
                      left: 0,
                      right: 0,
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: TouchableOpacity(
                          onPress: _pickImage,
                          child: Container(
                            width: 120,
                            height: 120,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(100),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  spreadRadius: 2,
                                  blurRadius: 3,
                                  offset: const Offset(0, 1),
                                ),
                              ]
                            ),
                            child: Container(
                              clipBehavior: Clip.hardEdge,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Stack(
                                children: [
                                  (_image != null) ? Image.file(_image!, width: 104, height: 104, fit: BoxFit.cover) 
                                    : (s.store!.storeImage!.isNotEmpty) ? Image.network(s.store!.storeImage!, width: 104, height: 104, fit: BoxFit.cover) 
                                    : Container(
                                    height: 104,
                                    width: 104,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(100),
                                      color: white1Color
                                    ),
                                    child: Center(
                                      child: Text(s.store!.name!.substring(0, 1).toUpperCase(), style: const TextStyle(color: greyDarkColor, fontSize: 52, fontWeight: FontWeight.w400)),
                                    ),
                                  ),
                                  if (uploadingImage) Container(
                                    color: Colors.black.withOpacity(0.1),
                                    child: Center(
                                      child: LoadingAnimationWidget.threeRotatingDots(color: white1Color, size: 16)
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              )
            ],
          ),
        )
      )
    );
  }
}