import 'dart:core';
import 'package:dio/dio.dart';

class RequestUtil {

  static Future<String?> getAction (url,{queryParameters, headers}) async {
    var dio = Dio();
    dio.options.headers = headers;
    Response<String> response = await dio.get<String>(url, queryParameters: queryParameters);
    return response.data.toString();
  }

  static Future<String?> postAction(url,{queryParameters, headers}) async {
    var dio = Dio();
    dio.options.headers = headers;
    Response response = await dio.post(url, queryParameters: queryParameters);
    return response.data.toString();
  }

}

