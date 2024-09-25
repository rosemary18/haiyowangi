import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:haiyowangi/src/index.dart';

class StoreRepository {

  Future<Response> getAllStores() async {
    
    String url = "/store";
    Response response = await getFetch(url);
    return response;
  }
  
  Future<Response> getStores(String id) async {
    
    String url = "/store/user/$id";
    Response response = await getFetch(url);
    return response;
  }

  Future<Response> getStore(String id) async {
    
    String url = "/store/$id";
    Response response = await getFetch(url);
    return response;
  }

  Future<Response> createStore(Object? data) async {
    
    showModalLoader();

    String url = "/store";
    Response response = await postFetch(url, data: data);

    rootNavigatorKey.currentState?.pop();
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(response.data["message"]! ?? response.statusMessage!),
        backgroundColor: (response.statusCode != 200) ? Colors.red : Colors.green,
      ),
    );

    return response;
  }

  Future<Response> uploadStoreImage(String id, Object? data) async {
    
    String url = "/store/$id/update-photo";
    Response response = await putFetch(url, data: data, options: Options(headers: {"Content-Type": "multipart/form-data"}));

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

  Future<Response> updateStore(String id, Object? data) async {
    
    showModalLoader();
    
    String url = "/store/$id";
    Response response = await putFetch(url, data: data);

    rootNavigatorKey.currentState?.pop();

    return response;
  }

  Future<Response> deleteStore(String id) async {
    
    showModalLoader();
    
    String url = "/store/$id";
    Response response = await delFetch(url);

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