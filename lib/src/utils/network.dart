import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'unauthorized.dart';

class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    debugPrint('[${options.method}]: ${options.uri}');
    debugPrint('Headers: ${options.headers}');
    debugPrint('Data: ${options.data}');
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint('[RES CODE]: ${response.statusCode}');
    debugPrint('Data: ${response.data}');
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint('[FETCH ERROR]: ${err.error}');
    debugPrint('Error Message: ${err.message}');
    debugPrint('Response: ${err.response}');
    super.onError(err, handler);
  }
}

final dio = Dio(
  BaseOptions(
    baseUrl: '${dotenv.env['BASE_PRODUCTION_API']!}/api',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {
      'Content-Type': 'application/json', // Content-Type default
      // Tambahkan header lainnya jika diperlukan
    },
    validateStatus: (status) => true
  )
)..interceptors.add(LoggingInterceptor());

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
    if (response.statusCode == 401) unAuthorizing();
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
    if (response.statusCode == 401) unAuthorizing();
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
    if (response.statusCode == 401) unAuthorizing();
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
    if (response.statusCode == 401) unAuthorizing();
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