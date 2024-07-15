import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:haiyowangi/src/index.dart';

class StoreRepository {

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
        content: Text(response.data["message"]!),
        backgroundColor: (response.statusCode != 200) ? Colors.red : Colors.green,
      ),
    );

    return response;
  }
  
}