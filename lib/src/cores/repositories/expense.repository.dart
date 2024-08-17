import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:haiyowangi/src/index.dart';

class ExpenseRepository {

  Future<Response> getData(String storeId, {Map<String, dynamic>? queryParams}) async {
    
    String url = "/expense/store/$storeId";
    Response response = await getFetch(url, queryParameters: queryParams);
    return response;
  }

  Future<Response> getTags({Map<String, dynamic>? queryParams}) async {
    
    String url = "/expense/tags";
    Response response = await getFetch(url, queryParameters: queryParams);
    return response;
  }

  Future<Response> getDetail(String id) async {
    
    String url = "/expense/$id";
    Response response = await getFetch(url);
    
    return response;
  }

  Future<Response> create(Map<String, dynamic> data) async {
    showModalLoader();

    String url = "/expense";
    Response response = await postFetch(url, data: data);

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

  Future<Response> update(String id, Map<String, dynamic> data) async {

    showModalLoader();

    String url = "/expense/$id";
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

  Future<Response> delete(String id) async {
  
    showModalLoader();

    String url = "/expense/$id";
    Response response = await delFetch(url);
    
    rootNavigatorKey.currentState?.pop();
  
    return response;
  }
}
