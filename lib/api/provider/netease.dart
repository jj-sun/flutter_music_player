import 'dart:core';
import 'package:flutter_music_player/api/request_util.dart';

class NeteaseUtil {

  static void requestAPI(String url,Map<String, dynamic> data) {

    var headers = {
      'referer': 'https://music.163.com/',
      'content-type': 'application/x-www-form-urlencoded',
      'user-agent':
      'Mozilla/5.0 (Linux; U; Android 8.1.0; zh-cn; BLA-AL00 Build/HUAWEIBLA-AL00) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/57.0.2987.132 MQQBrowser/8.9 Mobile Safari/537.36',
    };

    //RequestUtil.postAction(url, queryParameters: data, headers: headers);
  }

}

