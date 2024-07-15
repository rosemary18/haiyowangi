
import 'package:dio/dio.dart';
import 'package:haiyowangi/src/index.dart';

class UserRepository {

  Future<Response> getUser(String id) async {
    
    String url = "/user/$id";
    Response response = await getFetch(url);
    return response;
  }
}