import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:haiyowangi/src/index.dart';
import 'package:validators/validators.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _repasswordController = TextEditingController();

  bool checkController() {
    return _nameController.text.isNotEmpty 
      && _emailController.text.isNotEmpty 
      && _phoneController.text.isNotEmpty 
      && _passwordController.text.isNotEmpty 
      && _repasswordController.text.isNotEmpty;
  }

  void handlerRegister(BuildContext context) async {

    if (!checkController()) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text("Mohon lengkapi semua data yang diperlukan terlebih dahulu!"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (isEmail(_emailController.text) == false) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text("Email tidak valid!"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_passwordController.text != _repasswordController.text) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text("Kata sandi tidak cocok!"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    context.read<AuthBloc>().add(
      AuthRegister(
        name: _nameController.text, 
        email: _emailController.text, 
        phone: _phoneController.text, 
        password: _passwordController.text, 
        confirmPassword: _repasswordController.text
      )
    );

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const FormHeader(title: "Daftar Akun"),
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
                        Input(
                          controller: _emailController,
                          placeholder: "Email",
                          maxCharacter: 50,
                        ),
                        InputPhone(
                          controller: _phoneController,
                        ),
                        Input(
                          controller: _passwordController,
                          placeholder: "Kata sandi",
                          maxCharacter: 32,
                          obscure: true,
                        ),
                        Input(
                          controller: _repasswordController,
                          placeholder: "Kata sandi (Ulangi)",
                          maxCharacter: 32,
                          obscure: true,
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
                        text: "Kembali",
                        margin: const EdgeInsets.only(right: 6),
                        backgroundColor: greyColor,
                        textColor: blackColor,
                        onPress: () => Navigator.pop(context),
                      )
                    ),
                    Expanded(
                      child: ButtonOpacity(
                        onPress: () => handlerRegister(context),
                        text: "Daftar",
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