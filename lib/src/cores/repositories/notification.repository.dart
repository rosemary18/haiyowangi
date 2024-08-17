
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:haiyowangi/src/index.dart';

class NotificationRepository {

  Future<Response> getNotifications(String store_id, {int page = 1}) async {
    
    String url = "/notification/store/$store_id";
    Response response = await getFetch(url, queryParameters: {"page": page});
    return response;
  }

  Future<Response> read(String id) async {
    
    String url = "/notification/$id";
    Response response = await putFetch(url);

    return response;
  }

  Future<Response> readAll(String id) async {

    showModalLoader();
    
    String url = "/notification/store/$id";
    Response response = await putFetch(url);

    rootNavigatorKey.currentState?.pop();
    
    return response;
  }

  Future<Response> deleteByStore(String id) async {

    showModalLoader();
    
    String url = "/notification/store/$id";
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

  Future<Response> delete(String id) async {

    showModalLoader();
    
    String url = "/notification/$id";
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