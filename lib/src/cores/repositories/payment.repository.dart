import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:haiyowangi/src/index.dart';

class PaymentRepository {

  Future<Response> getData(String storeId, { Map<String, dynamic>? queryParams }) async {

    String url = "/payment/store/$storeId";
    Response response = await getFetch(url, queryParameters: queryParams);
    return response;
  }

  Future<Response> getDetail(String id) async {

    String url = "/payment/$id";
    Response response = await getFetch(url);

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

  Future<Response> getTypes() async {

    String url = "/payment/types";
    Response response = await getFetch(url);
    return response;
  }
  
}