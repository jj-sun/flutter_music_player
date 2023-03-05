import 'dart:core';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';

class RequestUtil {

  static Dio dio = Dio();

  static void init() {
    //绕过ssl验证
    (dio.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate =  (HttpClient client) {
      client.badCertificateCallback = (X509Certificate cert, String host, int port) =>true;
      return client;
    };
  }

  static Future<String?> getAction (url,{queryParameters, headers}) async {
    init();
    dio.options.headers = headers;
    Response<String> response = await dio.get<String>(url, queryParameters: queryParameters);
    return response.data.toString();
  }

  static Future<String?> postAction(url,{queryParameters,data, headers}) async {
    init();
    dio.options.headers = headers;
    Response response = await dio.post<String>(url, queryParameters: queryParameters,data: data);
    return response.data.toString();
  }

}

