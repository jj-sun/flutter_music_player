import 'dart:core';
import 'dart:io';
import 'package:dio/dio.dart';
import'package:dio/adapter.dart';

class RequestUtil {

  static Future<String?> getAction (url,{queryParameters, headers}) async {
    var dio = Dio();
    //绕过ssl验证
    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =  (HttpClient client) {
      client.badCertificateCallback = (X509Certificate cert, String host, int port) =>true;
      return client;
    };
    dio.options.headers = headers;
    Response<String> response = await dio.get<String>(url, queryParameters: queryParameters);
    if(response == null) {
      return '';
    }
    return response.data.toString();
  }

  static Future<String?> postAction(url,{data, headers}) async {
    var dio = Dio();
    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =  (HttpClient client) {
      client.badCertificateCallback = (X509Certificate cert, String host, int port) =>true;
      return client;
    };
    dio.options.headers = headers;
    Response response = await dio.post<String>(url, data: data);
    print('post: ${response.data.toString()}');
    if(response == null) {
      return '';
    }
    return response.data.toString();
  }

}

