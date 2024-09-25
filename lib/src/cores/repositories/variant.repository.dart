import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:haiyowangi/src/index.dart';

class VariantRepository {

  Future<Response> getData(String storeId, { Map<String, dynamic>? queryParams }) async {

    String url = "/variant/store/$storeId";
    Response response = await getFetch(url, queryParameters: queryParams);
    return response;
  }

  Future<Response> getDetail(String id) async {

    String url = "/variant/$id";
    Response response = await getFetch(url);
    return response;
  }

  Future<Response> getVariantTypes(String productId) async {
    
    String url = "/variant/type/product/$productId";
    Response response = await getFetch(url);
    return response;
  }

  Future<Response> create(Map<String, dynamic> data) async {

    showModalLoader();

    String url = "/variant";
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

  Future<Response> uploadImage(String id, Object? data) async {

    String url = "/variant/update-photo/$id";
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

  Future<Response> update(String id, Map<String, dynamic> data) async {

    showModalLoader();

    String url = "/variant/$id";
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

  Future<Response> updateVariantType(String id, Map<String, dynamic> data) async {

    showModalLoader();

    String url = "/variant/type/$id";
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

  Future<Response> addVariantType(Map<String, dynamic> data) async {

    showModalLoader();
    
    String url = "/variant/type";
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

  Future<Response> addVariantTypeItem(Map<String, dynamic> data) async {

    showModalLoader();
    
    String url = "/variant/type/item";
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

  Future<Response> delete(String id) async {

    showModalLoader();

    String url = "/variant/$id";
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

  Future<Response> deleteVariantType(String id) async {

    showModalLoader();

    String url = "/variant/type/$id";
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

  Future<Response> deleteVariantTypeItem(String id) async {

    showModalLoader();

    String url = "/variant/type/item/$id";
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