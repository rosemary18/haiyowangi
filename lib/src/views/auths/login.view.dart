import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:haiyowangi/src/index.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {

  final TextEditingController _emailResetPasswordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(AuthRefreshToken());
  }

  void viewForgotPassword(BuildContext context) {
    _emailResetPasswordController.clear();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Lupa Password', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
          titlePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          content: SizedBox(
            width: MediaQuery.of(context).size.width*.75,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(bottom: 12), 
                  child: Text(
                    'Masukkan alamat email dibawah ini dan sistem akan mengirimkan link reset password untuk mengatur ulang kata sandi anda.', 
                    style: TextStyle(color: Colors.black, fontSize: 14)
                  ),
                ),
                Input(
                  controller: _emailResetPasswordController,
                  placeholder: "Email",
                  maxCharacter: 50,
                ),
              ],
            )
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
                context.read<AuthBloc>().add(AuthRequestResetPassword(email: _emailResetPasswordController.text));
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                margin: const EdgeInsets.only(left: 6),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: const Text(
                  'Kirim', 
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
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (ctx, state) {

          if (state.isAuthenticated == null) {
            return Container(
              color: Colors.white,
              height: double.infinity,
              width: double.infinity,
              child: Center(
                child: LoadingAnimationWidget.threeArchedCircle(size: 50, color: primaryColor),
              ),
            );
          }

          if (state.isAuthenticated == false) {
            return Container(
              color: Colors.white,
              height: double.infinity,
              width: double.infinity,
              child: SingleChildScrollView(
                child: SafeArea(
                  child: Container(
                    color: Colors.white,
                    width: double.infinity,
                    margin: EdgeInsets.symmetric(horizontal: isTablet ? MediaQuery.of(ctx).size.width/4 : 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          height: max(MediaQuery.of(context).size.height * 0.2, 200),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: AlignmentDirectional.topCenter,
                              end: Alignment.bottomCenter,
                              stops: const [.3, .9],
                              colors: [
                                Colors.white.withOpacity(.2),
                                const Color(0xFFF8C90F).withOpacity(.2),
                                // primaryColor.withOpacity(0.2),
                              ],
                            ),
                          ),
                          child: Center(
                            child: Image.asset(
                              appImages["IMG_LOGO"]!,
                              width: 120,
                              height: 120,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Input(
                                controller: _emailController,
                                placeholder: "Email",
                                maxCharacter: 50,
                              ),
                              Input(
                                controller: _passwordController,
                                placeholder: "Password",
                                obscure: true,
                                maxCharacter: 16
                              ),
                              TouchableOpacity(
                                onPress: () {
                                  if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("Email dan Password harus diisi"),
                                        backgroundColor: Colors.red
                                      )
                                    );
                                  }
                                  context.read<AuthBloc>().add(AuthLogin(email: _emailController.text, password: _passwordController.text));
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: primaryColor,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      "Masuk", 
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.symmetric(vertical: 24),
                                child: Center(
                                  child: TouchableOpacity(
                                    onPress: () => viewForgotPassword(context),
                                    child: const Text(
                                      "Lupa Password?",
                                      style: TextStyle(
                                        color: Colors.blueAccent,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500
                                      ),
                                    ),
                                  )
                                ),
                              ),
                              TouchableOpacity(
                                onPress: () => context.pushNamed(appRoutes.register.name),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: const Color.fromARGB(120, 106, 106, 106),
                                      width: 1
                                    )
                                  ),
                                  child: const Center(
                                    child: Text(
                                      "Daftar", 
                                      style: TextStyle(
                                        color: Color.fromARGB(255, 106, 106, 106),
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ]
                          ),
                        )
                      ]
                    ),
                  )
                )
              )
            );
          }

          return Container();
        }
      )
    );
  }
}