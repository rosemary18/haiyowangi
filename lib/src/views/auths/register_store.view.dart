import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:haiyowangi/src/index.dart';

class RegisterStoreView extends StatefulWidget {
  const RegisterStoreView({super.key});

  @override
  State<RegisterStoreView> createState() => _RegisterStoreViewState();
}

class _RegisterStoreViewState extends State<RegisterStoreView> {

  final StoreRepository _storeRepo = StoreRepository();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  bool checkController() {
    return _nameController.text.isNotEmpty 
      && _addressController.text.isNotEmpty 
      && _phoneController.text.isNotEmpty;
  }

  void handlerCreateStore() async {

    if (!checkController()) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text("Mohon lengkapi semua data yang diperlukan terlebih dahulu!"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final data = {
      "name": _nameController.text,
      "address": _addressController.text,
      "phone": _phoneController.text
    };

    final response = await _storeRepo.createStore(jsonEncode(data));
    if (response.statusCode == 200) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const FormHeader(title: "Tambah Toko"),
      body: SafeArea(
        child: Container(
          color: Colors.white,
          height: double.infinity,
          width: double.infinity,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Input(
                          controller: _nameController,
                          placeholder: "Nama",
                          maxCharacter: 50,
                        ),
                        InputPhone(
                          controller: _phoneController,
                        ),
                        Input(
                          controller: _addressController,
                          placeholder: "Address",
                          maxLines: 5
                        ),
                      ],
                    ),
                  )
                )
              ),
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 12),
                padding: EdgeInsets.symmetric(horizontal: isTablet ? MediaQuery.of(context).size.width/4 : 12),
                width: double.infinity,
                color: Colors.white,
                child: Row(
                  children: [
                    Expanded(
                      child: ButtonOpacity(
                        text: "Batal",
                        margin: const EdgeInsets.only(right: 6),
                        backgroundColor: greyColor,
                        textColor: blackColor,
                        onPress: () => Navigator.pop(context),
                      )
                    ),
                    Expanded(
                      child: ButtonOpacity(
                        onPress: handlerCreateStore,
                        text: "Tambah",
                        margin: const EdgeInsets.only(left: 6),
                        backgroundColor: primaryColor,
                      )
                    ),
                  ],
                ),
              )
            ]
          ),
        )
      )
    );
  }
}