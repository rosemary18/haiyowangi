
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:haiyowangi/src/index.dart';

class UserRepository {

  Future<Response> getUser(String id) async {
    
    String url = "/user/$id";
    Response response = await getFetch(url);
    return response;
  }

  Future<Response> uploadPhotoProfile(String id, Object? data) async {
    
    String url = "/user/$id/update-photo";
    Response response = await putFetch(url, data: data, options: Options(headers: {"Content-Type": "multipart/form-data"}));
    return response;
  }

  Future<Response> updateProfile(String id, Object? data) async {

    showModalLoader();
    
    String url = "/user/$id";
    Response response = await putFetch(url, data: data);

    rootNavigatorKey.currentState?.pop();
    
    if (response.statusCode != 200) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text(response.data["message"]! ?? response.statusMessage!),
          backgroundColor: Colors.red,
        ),
      );
    }

    return response;
  }
}