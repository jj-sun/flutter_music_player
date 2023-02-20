

import 'package:flutter_music_player/api/client.dart';
import 'package:flutter_music_player/api/provider/netease.dart';
import 'package:flutter_music_player/api/provider/qq.dart';

class ClientFactory {

  static Client getFactory(String platformId) {
    if(platformId == 'ne') {
      return Netease();
    }
    return QQ();
  }

}