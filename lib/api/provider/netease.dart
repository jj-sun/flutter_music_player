import 'dart:convert';
import 'dart:core';
import 'package:flutter_music_player/utils/request_util.dart';
import 'package:flutter_music_player/model/music_info.dart';

import '../../model/music_tag_info.dart';

import '../../utils/crypto.dart';

class NeteaseUtil {

  static Future requestAPI(String url, Map<String, dynamic> data) async {
    var headers = {
      'referer': 'https://music.163.com/',
      'content-type': 'application/x-www-form-urlencoded',
      'user-agent':
          'Mozilla/5.0 (Linux; U; Android 8.1.0; zh-cn; BLA-AL00 Build/HUAWEIBLA-AL00) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/57.0.2987.132 MQQBrowser/8.9 Mobile Safari/537.36',
    };
    var query = CryptoUtil.weapi(data);
    print(query);
    return await RequestUtil.postAction(url, data: query, headers: headers);
  }

  static String getSmallImageUrl(String url) {
    return '$url?param=140y140';
  }

  static Future<List<MusicTagInfo>> showPlaylist(int offset) async {

    print('参数： ${offset}');

    Map<String, dynamic> query = {
      'cat': '全部',
      'order': 'hot',
      'limit': 30,
      'offset': offset,
      'total': true
    };

    const url = 'https://music.163.com/weapi/playlist/list';

    var data = await requestAPI(url, query);
    
    print('得到数据：${data}');

    const JsonDecoder decoder = JsonDecoder();
    final Map<String, dynamic> object = decoder.convert(data.toString());
    List<dynamic> list = object['playlists'];

    List<MusicTagInfo> playlists = [];

    list.forEach((item) {
      var musicTagInfo = MusicTagInfo(
          getSmallImageUrl(item['coverImgUrl']),
          item['name'],
          'neplaylist_${item['id']}',
          'http://music.163.com/#/playlist?id=${item['dissid']}');
      playlists.add(musicTagInfo);
    });

    print('网易云playList: ${playlists}');

    return playlists;
  }

  static num getNEScore(song) {
    if (!song) return 0;
    var privilege = song.privilege;

    if (song.program) return 0;

    if (privilege) {
      if (privilege.st != null && privilege.st < 0) {
        return 100;
      }
      if (privilege.fee > 0 &&
          privilege.fee != 8 &&
          privilege.payed == 0 &&
          privilege.pl <= 0) return 10;
      if (privilege.fee == 16 || (privilege.fee == 4 && privilege.flag & 2048))
        return 11;
      if ((privilege.fee == 0 || privilege.payed) &&
          privilege.pl > 0 &&
          privilege.dl == 0) return 1e3;

      if (privilege.pl == 0 && privilege.dl == 0) return 100;

      return 0;
    }

    if (song.status >= 0) return 0;
    if (song.fee > 0) return 10;

    return 100;
  }

  static bool isPlayable(song) {
    return getNEScore(song) < 100;
  }

  static MusicInfo convert(songInfo, allowAll) {
    return MusicInfo(
      'netrack_${songInfo.id}',
      songInfo.name,
      songInfo.ar[0].name,
      'neartist_${songInfo.ar[0].id}',
      songInfo.al.name,
      'nealbum_${songInfo.al.id}',
      'netease',
      'http://music.163.com/#/song?id=${songInfo.id}',
      songInfo.al.picUrl,
      'netrack_${songInfo.id}',
      allowAll ? false : !isPlayable(songInfo),
    );
  }

  static Future<Map<String, dynamic>> getPlaylist(String playlistId) async {
    String listId = playlistId.split('_').last;
    Map<String, dynamic> data = {
      'id': listId,
      'offset': 0,
      'total': true,
      'limit': 1000,
      'n': 1000,
      'csrf_token': '',
    };

    const playlist_url = 'http://music.163.com/weapi/v3/playlist/detail';
    const tracks_url = 'https://music.163.com/weapi/v3/song/detail';

    return requestAPI(playlist_url, data).then((resData) {
      Map<String, dynamic> info = {
        'id': 'neplaylist_${listId}',
        'cover_img_url':
            getSmallImageUrl(resData['playlist']['coverImgUrl'].toString()),
        'title': resData['playlist']['name'],
        'source_url': 'http://music.163.com/#/playlist?id=${listId}',
      };

      // request all tracks to fetch song info
      // Code reference from listen1_chrome_extension
      List<String> track_ids = resData.playlist.trackIds.map((i) => i.id);
      Map<String, dynamic> data = {
        'c': '[' + track_ids.map((id) => '{"id":' + id + '}').join(',') + ']',
        'ids': '[' + track_ids.join(',') + ']',
      };

      return requestAPI(tracks_url, data).then((response) {
        List<MusicInfo> tracks =
            response.songs.map((item) => convert(item, true));
        return {'info': info, 'tracks': tracks};
      });
    });
  }

  static Future<String> bootstrapTrack(String trackId) {
    String url =
        'http://music.163.com/weapi/song/enhance/player/url/v1?csrf_token=';

    String songId = trackId.substring('netrack_'.length);

    Map<String, dynamic> data = {
      'ids': [songId],
      'level': 'standard',
      'encodeType': 'aac',
      'csrf_token': '',
    };

    return requestAPI(url, data).then((resData) {
      var songUrl = resData.data[0]['url'];
      if (songUrl == null) {
        return '';
      }
      return songUrl;
    });
  }

  static Future<Map<String, dynamic>> search(keyword, page) {
    String url = 'https://music.163.com/weapi/cloudsearch/get/web';
    Map<String, dynamic> data = {
      'csrf_token': '',
      'hlposttag': '</span>',
      'hlpretag': '<span class="s-fc7">',
      'limit': '30',
      'offset': (30 * (page - 1)).toString(),
      's': keyword,
      'total': 'false',
      'type': '1',
    };

    return requestAPI(url, data).then((resData) {

      List<MusicInfo> tracks = resData.result.songs.map((item) => convert(item,false));
      return {
        'result': tracks,
        'total': resData.result.songCount,
      };
    });
  }

  static Map<String, dynamic>? parseUrl(String url) {

    Iterable<Match> r = '/\/\/music\.163\.com\/playlist\/([0-9]+)/g'.allMatches(url);

    if (r != null) {
      return {
        'type': 'playlist',
        'id': 'neplaylist_${r.toList()[1].group(0)}',
      };
    }

    if (
      url.contains('//music.163.com/#/m/playlist') ||
      url.contains('//music.163.com/#/playlist') ||
      url.contains('//music.163.com/playlist') ||
      url.contains('//music.163.com/#/my/m/music/playlist')
    ) {
     var queryParameters = Uri.parse(url).queryParameters;

     return {
      'type': 'playlist',
      'id': 'neplaylist_${queryParameters['id']}',
      };
    }

    return null;
  }

  static var meta = { 'name': '网易', 'platformId': 'ne', 'enName': 'netease' };

}
