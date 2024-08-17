import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:haiyowangi/src/index.dart';
import 'package:validators/validators.dart';

class FormStaffView extends StatefulWidget {
  const FormStaffView({super.key});

  @override
  State<FormStaffView> createState() => _FormStaffViewState();
}

class _FormStaffViewState extends State<FormStaffView> {

  final repository = StaffRepository();
  final _controllerName = TextEditingController();
  final _controllerEmail = TextEditingController();
  final _controllerPhone = TextEditingController();
  final _controllerSalary = TextEditingController();
  final _controllerDateJoined = TextEditingController();
  final _controllerPOSPassCode = TextEditingController();
  final _controllerAddress= TextEditingController();

  bool isCashier = false;

  @override
  void initState() {
    super.initState();

    _controllerPOSPassCode.text = generateRandomString(6, numsOnly: true).toString();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void handlerSubmit() async {

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
      "store_id": context.read<AuthBloc>().state.store?.id,
      "name": _controllerName.text,
      "email": _controllerEmail.text,
      "phone": _controllerPhone.text.replaceAll("-", ""),
      "salary": parseFromInput(_controllerSalary.text),
      "date_joined": _controllerDateJoined.text,
      "is_cashier": isCashier,
      "pos_passcode": _controllerPOSPassCode.text,
      "address": _controllerAddress.text,
    };

    Response response = await repository.create(data);

    if (response.statusCode == 200) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text("Staff baru telah ditambahkan!"),
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
      appBar: const FormHeader(title: "Tambah Staff"),
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