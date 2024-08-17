import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:haiyowangi/src/index.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class AccountView extends StatefulWidget {

  const AccountView({super.key});

  @override
  State<AccountView> createState() => _AccountViewState();
}

class _AccountViewState extends State<AccountView> {

  final TextEditingController _inputController = TextEditingController();
  final UserRepository _userRepository = UserRepository();
  File? _image;
  bool uploadingProfile = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _pickImage() async {

    if (uploadingProfile) return;

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      await handlerUpdateProfileImage();
    }
  }

  Future<void> handlerUpdateProfileImage() async {

    setState(() {
      uploadingProfile = true;
    });

    final state = context.read<AuthBloc>().state;
    FormData formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(_image!.path, filename: "image.png"),
    });

    debugPrint(formData.files.toList().toString());

    Response response = await _userRepository.uploadPhotoProfile("${state.user?.id}", formData);
    if (response.statusCode == 200) {
      state.user = UserModel.fromJson(response.data["data"]);
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
      uploadingProfile = false;
    });
  }

  Future<void> handlerUpdateProfileData(String type) async {
    
    Map<String, dynamic> data = {};

    if (type == "password") {
      data = {"password": _inputController.text};
    } else if (type == "name") {
      data = {"name": _inputController.text};
    } else if (type == "email") {
      data = {"email": _inputController.text};
    } else if (type == "phone") {
      data = {"phone": _inputController.text.replaceAll("-", "") };
    }

    final state = context.read<AuthBloc>().state;
    Response response = await _userRepository.updateProfile("${state.user?.id}", jsonEncode(data));
    if (response.statusCode == 200) {
      state.user = UserModel.fromJson(response.data["data"]);
      context.read<AuthBloc>().add(AuthUpdateState(state: state));
      scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text("Profil berhasil diubah!"),
          backgroundColor: Colors.green,
        ),
      );
      setState(() {});
      if (type == "password") context.read<AuthBloc>().add(AuthLogout());
    }
  }
  
  // Views

  void viewUpdateModal(String type) {
    _inputController.clear();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Ubah profil', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
          titlePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          content: SizedBox(
            width: MediaQuery.of(context).size.width*.75,
            child: Column(
              children: [
                (type == "phone") ? InputPhone(controller: _inputController) : Input(
                  controller: _inputController,
                  placeholder: type == "password" ? "Password" : type == "name" ? "Nama" : "Email",
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
                handlerUpdateProfileData(type);
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
                            child: Text("${s.user?.username} • ${s.user?.name}", style: const TextStyle(color: Color.fromARGB(180, 9, 9, 9), fontSize: 10))
                          ),
                          Container(
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
                                              "${s.user!.name}", 
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
                                            const Text("Email", style: TextStyle(color: blackColor, fontSize: 13, fontFamily: FontMedium)),
                                            Text(
                                              "${s.user!.email}", 
                                              style: const TextStyle(color: greyTextColor, fontSize: 12, fontWeight: FontWeight.w400), 
                                              maxLines: 2, 
                                              overflow: TextOverflow.ellipsis
                                            ),
                                          ],
                                        )
                                      ),
                                      TouchableOpacity(
                                        onPress: () => viewUpdateModal("email"),
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
                                            const Text("Nomor Telepon", style: TextStyle(color: blackColor, fontSize: 13, fontFamily: FontMedium)),
                                            Text("${s.user!.phone}", style: const TextStyle(color: greyTextColor, fontSize: 12, fontWeight: FontWeight.w400)),
                                          ],
                                        )
                                      ),
                                      TouchableOpacity(
                                        onPress: () => viewUpdateModal("phone"),
                                        child: const Icon(
                                          Icons.mode_edit_outline_outlined,
                                          size: 16,
                                          color: primaryColor,
                                        ), 
                                      )
                                    ],
                                  ),
                                ),
                                ButtonOpacity(
                                  onPress: () => viewUpdateModal("password"),
                                  margin: const EdgeInsets.only(top: 12),
                                  backgroundColor: Colors.white,
                                  text: "Ganti Password",
                                  textColor: Colors.black54,
                                )
                              ],
                            ),
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
                                    : (s.user?.profilePhoto != null && s.user!.profilePhoto!.isNotEmpty) ? Image.network(s.user!.profilePhoto!, width: 104, height: 104, fit: BoxFit.cover) 
                                    : Image.asset(
                                      appImages["IMG_AVATAR"]!, 
                                      width: 104, 
                                      height: 104, 
                                      fit: BoxFit.cover
                                  ),
                                  if (uploadingProfile) Container(
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