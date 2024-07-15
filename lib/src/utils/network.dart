import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../types/index.dart';
import 'unauthorized.dart';

final dio = Dio(BaseOptions(
    baseUrl: '${dotenv.env['BASE_PRODUCTION_API']!}/api',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {
      'Content-Type': 'application/json', // Content-Type default
      // Tambahkan header lainnya jika diperlukan
    },
    validateStatus: (status) => true
  ));

Future<Response> getFetch(String path, { 
    Object? data, 
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onReceiveProgress 
  }) async {
  
  Response response;
  try {
    response = await dio.get(
      path,
      data: data,
      queryParameters : queryParameters,
      options: options,
      cancelToken: cancelToken,
      onReceiveProgress: onReceiveProgress
    );
    if (response.statusCode == 401 && IS_POS) unAuthorizing();
    return response;
  } on HttpException {
    RequestOptions requestOptions = RequestOptions(path: path);
    response = Response(statusCode: 100, statusMessage: "No Internet", requestOptions: requestOptions); 
    return response;
  } on FormatException {
    RequestOptions requestOptions = RequestOptions(path: path);
    response = Response(statusCode: 101, statusMessage: "Format Exception", requestOptions: requestOptions); 
    return response;
  } catch (e) {
    RequestOptions requestOptions = RequestOptions(path: path);
    response = Response(statusCode: 102, statusMessage: "Unknown Error", requestOptions: requestOptions); 
    return response;
  }
}

Future<Response> postFetch(String path, { 
    Object? data, 
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress 
  }) async {
  
  Response response;
  try {
    response = await dio.post(
      path,
      data: data,
      queryParameters : queryParameters,
      options: options,
      cancelToken: cancelToken,
      onReceiveProgress: onReceiveProgress
    );
    if (response.statusCode == 401 && IS_POS) unAuthorizing();
    return response;
  } on HttpException {
    RequestOptions requestOptions = RequestOptions(path: path);
    response = Response(statusCode: 100, statusMessage: "No Internet", requestOptions: requestOptions); 
    return response;
  } on FormatException {
    RequestOptions requestOptions = RequestOptions(path: path);
    response = Response(statusCode: 101, statusMessage: "Format Exception", requestOptions: requestOptions); 
    return response;
  } catch (e) {
    debugPrint(e.toString());
    RequestOptions requestOptions = RequestOptions(path: path);
    response = Response(statusCode: 102, statusMessage: "Unknown Error", requestOptions: requestOptions); 
    return response;
  }
}

Future<Response> putFetch(String path, { 
    Object? data, 
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress 
  }) async {
  
  Response response;
  try {
    response = await dio.put(
      path,
      data: data,
      queryParameters : queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress
    );
    if (response.statusCode == 401 && IS_POS) unAuthorizing();
    return response;
  } on HttpException {
    RequestOptions requestOptions = RequestOptions(path: path);
    response = Response(statusCode: 100, statusMessage: "No Internet", requestOptions: requestOptions); 
    return response;
  } on FormatException {
    RequestOptions requestOptions = RequestOptions(path: path);
    response = Response(statusCode: 101, statusMessage: "Format Exception", requestOptions: requestOptions); 
    return response;
  } catch (e) {
    RequestOptions requestOptions = RequestOptions(path: path);
    response = Response(statusCode: 102, statusMessage: "Unknown Error", requestOptions: requestOptions); 
    return response;
  }
}

Future<Response> delFetch(String path, { 
    Object? data, 
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
  
  Response response;
  try {
    response = await dio.delete(
      path,
      data: data,
      queryParameters : queryParameters,
      options: options,
      cancelToken: cancelToken
    );
    if (response.statusCode == 401 && IS_POS) unAuthorizing();
    return response;
  } on HttpException {
    RequestOptions requestOptions = RequestOptions(path: path);
    response = Response(statusCode: 100, statusMessage: "No Internet", requestOptions: requestOptions); 
    return response;
  } on FormatException {
    RequestOptions requestOptions = RequestOptions(path: path);
    response = Response(statusCode: 101, statusMessage: "Format Exception", requestOptions: requestOptions); 
    return response;
  } catch (e) {
    RequestOptions requestOptions = RequestOptions(path: path);
    response = Response(statusCode: 102, statusMessage: "Unknown Error", requestOptions: requestOptions); 
    return response;
  }
}