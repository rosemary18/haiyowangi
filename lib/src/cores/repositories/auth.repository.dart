import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:haiyowangi/src/index.dart';
import 'package:hive/hive.dart';

class AuthRepository {

  Future<Response> login({ 
    required String email,
    required String password,
  }) async {

    String url = "/auth/login";

    showModalLoader();
    
    Response response = await postFetch(url, data: {
      "email": email.toString(),
      "password": password.toString()
    });

    rootNavigatorKey.currentState?.pop();
    
    if (response.statusCode != 200) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text(response.data["message"]! ?? response.statusMessage),
          backgroundColor: Colors.red,
        ),
      );
    }

    return response;
  }

  Future<Response> register({ 
    required String name,
    required String email,
    required String phone,
    required String password,
    required String confirmPassword
  }) async {
    
    showModalLoader();
    
    String url = "/auth/register";
    Response response = await postFetch(url, data: {
      "name": name.toString(),
      "email": email.toString(),
      "phone": phone.toString(),
      "password": password.toString(),
      "confirm_password": confirmPassword.toString()
    });

    if (response.statusCode != 200) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text(response.data["message"]! ?? response.statusMessage!),
          backgroundColor: Colors.red,
        ),
      );
    }

    if (response.statusCode == 200) {
      rootNavigatorKey.currentState?.pop();
      scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text("Akun anda telah terdaftar!\nSilahkan login menggunakan email dan kata sandi yang telah anda daftarkan."),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 5),
        ),
      );
    }

    rootNavigatorKey.currentState?.pop();

    return response;
  }

  Future<Response> refreshToken() async {

    String url = "/auth/refresh-token";
    final box = Hive.box("storage");
    final refreshToken = box.get("refresh_token");

    Response response = await postFetch(url, data: {
      "refresh_token": refreshToken.toString()
    });

    return response;
  }

  Future<Response> forgotPassword({ 
    required String email,
  }) async {

    showModalLoader();
    
    String url = "/auth/request-reset-password";
    Response response = await postFetch(url, data: {
      "email": email.toString()
    });

    if (response.statusCode != 200) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text(response.data["message"]! ?? response.statusMessage!),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text(response.data["message"]! ?? response.statusMessage!),
          backgroundColor: Colors.green,
        ),
      );
    }

    rootNavigatorKey.currentState?.pop();
    return response;
  }

  Future<bool> logout() async {
    
    return false;
  }

}