import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:haiyowangi/src/index.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:validators/validators.dart';

class DetailStaffView extends StatefulWidget {

  final String data;

  const DetailStaffView({
    super.key, 
    required this.data
  });

  @override
  State<DetailStaffView> createState() => _DetailStaffViewState();
}

class _DetailStaffViewState extends State<DetailStaffView> {

  final repository = StaffRepository();
  final _controllerName = TextEditingController();
  final _controllerEmail = TextEditingController();
  final _controllerPhone = TextEditingController();
  final _controllerSalary = TextEditingController();
  final _controllerDateJoined = TextEditingController();
  final _controllerPOSPassCode = TextEditingController();
  final _controllerAddress= TextEditingController();
  
  late StaffModel _staff;

  bool isEditing = false;
  bool isCashier = false;
  bool uploadingImage = false;
  File? _image;


  @override
  void initState() {
    super.initState();
    _staff = StaffModel.fromJson(jsonDecode(widget.data));
    handlerGetDetail();
    setState(() {});
  }

  Future<void> handlerGetDetail() async {
    
    Response response = await repository.getDetail("${_staff.id}");
    debugPrint(response.data.toString());
    if (response.statusCode == 200) {
      _staff = StaffModel.fromJson(response.data!["data"]);
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

    _controllerName.text = _staff.name!;
    _controllerEmail.text = _staff.email!;
    _controllerPhone.text = _staff.phone!;
    _controllerSalary.text = _staff.salary!.toString();
    _controllerDateJoined.text = _staff.dateJoined!;
    _controllerPOSPassCode.text = _staff.posPasscode!;
    _controllerAddress.text = _staff.address!;
    isCashier = _staff.isCashier!;

    isEditing = true;
    setState(() {});
  }

  Future<void> handlerUpdate() async {

    if (_controllerName.text.isEmpty || _controllerEmail.text.isEmpty || _controllerPhone.text.isEmpty || _controllerSalary.text.isEmpty || _controllerDateJoined.text.isEmpty || _controllerPOSPassCode.text.isEmpty) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text("Lengkapi data terlebih dahulu"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_controllerSalary.text.replaceAll(RegExp(r'[^\d]'), '') == "0") {
      scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text("Gaji harus lebih dari 0"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (isEmail(_controllerEmail.text) == false) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text("Email tidak valid!"),
          backgroundColor: Colors.red,
        )
      );
    }

    final data = {
      "name": _controllerName.text,
      "email": _controllerEmail.text,
      "phone": _controllerPhone.text.replaceAll("-", ""),
      "salary": parsePriceFromInput(_controllerSalary.text),
      "date_joined": _controllerDateJoined.text,
      "pos_passcode": _controllerPOSPassCode.text,
      "address": _controllerAddress.text,
      "is_cashier": isCashier
    };

    Response response = await repository.update("${_staff.id}", data);
    if (response.statusCode == 200) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text("Staff telah diubah!"),
          backgroundColor: Colors.green,
        )
      );
      handlerGetDetail();
      isEditing = false;
      setState(() {});
    }
  }

  void handlerDelete() async {

    final response = await repository.delete("${_staff.id}");
    if (response.statusCode == 200) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text("Staff berhasil dihapus!"),
          backgroundColor: Colors.green,
        )
      );
      Navigator.pop(context, true);
    }
  }

  Future<void> handlerUpdateStaffImage() async {

    setState(() {
      uploadingImage = true;
    });

    FormData formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(_image!.path, filename: "image.png"),
    });

    Response response = await repository.uploadImage("${_staff.id}", formData);

    if (response.statusCode == 200) {
      _staff = StaffModel.fromJson(response.data["data"]);
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

  Future<void> _pickImage() async {

    if (uploadingImage) return;

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      await handlerUpdateStaffImage();
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
          content: const Text("Apakah anda yakin ingin menghapus staff ini?"),
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
      appBar: DetailHeader(title: _staff.code ?? "Detail Staff"), 
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
                    margin: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Input(
                          controller: _controllerName,
                          title: "Nama",
                          margin: const EdgeInsets.only(bottom: 6),
                        ),
                        Input(
                          controller: _controllerEmail,
                          title: "Email",
                          margin: const EdgeInsets.only(bottom: 6),
                        ),
                        InputPhone(
                          controller: _controllerPhone,
                          title: "Nomor Telepon",
                          margin: const EdgeInsets.only(bottom: 12),
                        ),
                        Input(
                          controller: _controllerAddress,
                          title: "Alamat",
                          maxLines: 10,
                          margin: const EdgeInsets.only(bottom: 12),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 12),
                          child: const Divider(color: greyLightColor),
                        ),
                        Input(
                          controller: _controllerSalary,
                          isCurrency: true,
                          title: "Gaji",
                          margin: const EdgeInsets.only(bottom: 6),
                        ),
                        InputDate(
                          controller: _controllerDateJoined,
                          title: "Tanggal Bergabung",
                          margin: const EdgeInsets.only(bottom: 6),
                        ),
                        SwitchLabel(
                          title: "Kasir?",
                          desc: "Staff bertugas sebagai kasir",
                          value: isCashier, 
                          onChanged: (e) => setState(() => isCashier = e),
                        ),
                        if (isCashier) Input(
                          controller: _controllerPOSPassCode,
                          title: "POS Kode",
                          readOnly: true,
                          margin: const EdgeInsets.only(bottom: 12),
                          suffixIcon: TouchableOpacity(
                            onPress: () {
                              setState(() {
                                _controllerPOSPassCode.text = generateRandomString(6, numsOnly: true).toString();
                              });
                            },
                            child: const Icon(Icons.replay, color: greyDarkColor),
                          ),
                        ),
                      ],
                    ),
                  ) : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        color: primaryColor,
                        height: 120,
                      ),
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
                                Container(
                                  decoration: BoxDecoration(
                                    color: white1Color,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  padding: const EdgeInsets.all(8),
                                  margin: const EdgeInsets.only(top: 92),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text("Kode Staff", style: TextStyle(fontSize: 12, color: greyTextColor)),
                                          Text(_staff.code.toString(), style: const TextStyle(fontSize: 12))
                                        ],
                                      ),
                                      const Divider(color: greyLightColor),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text("Email", style: TextStyle(fontSize: 12, color: greyTextColor)),
                                          Text(_staff.email.toString(), style: const TextStyle(fontSize: 12))
                                        ],
                                      ),
                                      const Divider(color: greyLightColor),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text("Nomor Telepon", style: TextStyle(fontSize: 12, color: greyTextColor)),
                                          Text(_staff.phone!.isNotEmpty ? "0${_staff.phone.toString()}" : "-", style: const TextStyle(fontSize: 12))
                                        ],
                                      ),
                                      const Divider(color: greyLightColor),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text("Gaji", style: TextStyle(fontSize: 12, color: greyTextColor)),
                                          Text(parseRupiahCurrency(_staff.salary.toString()), style: const TextStyle(fontSize: 12))
                                        ],
                                      ),
                                      const Divider(color: greyLightColor),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text("Tanggal Bergabung", style: TextStyle(fontSize: 12, color: greyTextColor)),
                                          Text(formatDateFromString("${_staff.dateJoined}", format: "EEEE, dd/MM/yyyy"), style: const TextStyle(fontSize: 12))
                                        ],
                                      ),
                                      const Divider(color: greyLightColor),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text("Terakhir diubah", style: TextStyle(fontSize: 12, color: greyTextColor)),
                                          Text(formatDateFromString(_staff.updatedAt ?? ""), style: const TextStyle(fontSize: 12)),
                                        ],
                                      ),
                                      const Divider(color: greyLightColor),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text("Dibuat pada", style: TextStyle(fontSize: 12, color: greyTextColor)),
                                          Text(formatDateFromString(_staff.createdAt ?? ""), style: const TextStyle(fontSize: 12)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                const Text("Alamat", style: TextStyle(fontSize: 12, fontFamily: FontMedium)),
                                const SizedBox(height: 4),
                                Text("${_staff.address!.isNotEmpty ? _staff.address : "-"}", style: const TextStyle(fontSize: 10, color: greyTextColor)),
                                const SizedBox(height: 12),
                                const Text("Akses Kasir", style: TextStyle(fontSize: 12, fontFamily: FontMedium)),
                                const SizedBox(height: 4),
                                Text(_staff.isCashier == true ? "Ya" : "Tidak", style: const TextStyle(fontSize: 10, color: greyTextColor)),
                                if (_staff.isCashier == true) Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 12),
                                    const Text("Kode Pass", style: TextStyle(fontSize: 12, fontFamily: FontMedium)),
                                    const SizedBox(height: 4),
                                    Text(_staff.posPasscode.toString(), style: const TextStyle(fontSize: 10, color: greyTextColor))
                                  ],
                                ),
                              ],
                            ),
                            Positioned(
                              top: -80,
                              left: 0,
                              right: 0,
                              child: Align(
                                alignment: Alignment.topCenter,
                                child: TouchableOpacity(
                                  onPress: _pickImage,
                                  child: Column(
                                    children: [
                                      Container(
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
                                                : (_staff.profilePhoto!.isNotEmpty) ? Image.network(_staff.profilePhoto!, width: 104, height: 104, fit: BoxFit.cover) 
                                                : Container(
                                                height: 104,
                                                width: 104,
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(100),
                                                  color: white1Color
                                                ),
                                                child: Center(
                                                  child: Text(_staff.name!.substring(0, 1).toUpperCase(), style: const TextStyle(color: greyDarkColor, fontSize: 52, fontWeight: FontWeight.w400)),
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
                                      const SizedBox(height: 12),
                                      Text("${_staff.name}", style: const TextStyle(fontSize: 12, color: greyTextColor)),
                                    ]
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
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