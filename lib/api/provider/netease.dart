import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'dart:math';

import 'package:flutter_music_player/api/client.dart';
import 'package:flutter_music_player/utils/request_util.dart';
import 'package:flutter_music_player/model/music_info.dart';
import 'package:html/parser.dart' as htmlparser;
import 'package:html/dom.dart' as dom;
import 'package:cookie_jar/cookie_jar.dart';


import '../../model/music_tag_info.dart';

import '../../utils/crypto.dart';

import 'dart:developer';

class Netease implements Client {

  var headers = {
    'referer': 'https://music.163.com/',
    'content-type': 'application/x-www-form-urlencoded',
    'user-agent':
    'Mozilla/5.0 (Linux; U; Android 8.1.0; zh-cn; BLA-AL00 Build/HUAWEIBLA-AL00) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/57.0.2987.132 MQQBrowser/8.9 Mobile Safari/537.36',
  };

  Future _requestAPI(String url, Map<String, dynamic> data) async {

    var query = CryptoUtil.weapi(data);
    print(query);
    return await RequestUtil.postAction(url, data: query, headers: headers);
  }

  String _getSmallImageUrl(String url) {
    return '$url?param=140y140';
  }

  /*@override
  Future<List<MusicTagInfo>> showPlaylist(int offset, String? filterId) async {
    print('参数： ${offset}');

    Map<String, dynamic> query = {
      'cat': '全部',
      'order': 'hot',
      'limit': 30,
      'offset': offset,
      'total': true
    };

    const url = 'https://music.163.com/weapi/playlist/list';

    var data = await _requestAPI(url, query);

    print('得到数据：${data}');

    const JsonDecoder decoder = JsonDecoder();
    final Map<String, dynamic> object = decoder.convert(data.toString());
    List<dynamic> list = object['playlists'];

    List<MusicTagInfo> playlists = [];

    list.forEach((item) {
      var musicTagInfo = MusicTagInfo(
          _getSmallImageUrl(item['coverImgUrl']),
          item['name'],
          'neplaylist_${item['id']}',
          'http://music.163.com/#/playlist?id=${item['dissid']}');
      playlists.add(musicTagInfo);
    });

    print('网易云playList: ${playlists}');

    return playlists;
  }*/

  Future<List<MusicTagInfo>> showTopList(int offset) async {
    List<MusicTagInfo> playlists = [];
    if(offset > 0) {
      return playlists;
    }

    String url = 'https://music.163.com/weapi/toplist/detail';

    String repData = await _requestAPI(url, {});

    final Map<String, dynamic> object = jsonDecode(repData);

    List<dynamic> list = object['list'];

    list.forEach((item) {
      var musicTagInfo = MusicTagInfo(
          _getSmallImageUrl(item['coverImgUrl']),
          item['name'],
          'neplaylist_${item['id']}',
          'http://music.163.com/#/playlist?id=${item['id']}');
      playlists.add(musicTagInfo);
    });

    return playlists;

  }

  Future<List<MusicTagInfo>> showPlaylist(int offset, { String? filterId }) async {

    String order = 'hot';

    if(filterId != null && filterId == 'toplist') {
      return showTopList(offset);
    }

    String filter = '';
    if(filterId != null && filterId.isNotEmpty) {
      filter = '&cat=${filterId}';
    }

    String targetUrl = '';
    if(offset > 0) {
      targetUrl = 'https://music.163.com/discover/playlist/?order=${order}${filter}&limit=35&offset=${offset}';
    } else {
     targetUrl = 'https://music.163.com/discover/playlist/?order=${order}${filter}';
    }

    var respData = await RequestUtil.getAction(targetUrl);

    dom.Document document = htmlparser.parse(respData);


    var listElements = document.getElementsByClassName('m-cvrlst').first.children;

    List<MusicTagInfo> playlists = [];

    listElements.forEach((element) {
      //print(element.getElementsByTagName('img').first.attributes['src']?.replaceFirst('140y140', '512y512'));
     // print(element.getElementsByTagName('div').first.getElementsByTagName('a').first.attributes['title']);
      String? id = Uri.parse(element.getElementsByTagName('div').first.getElementsByTagName('a').first.attributes['href'].toString()).queryParameters['id'];
      //print('neplaylist_${id}');
      //print('https://music.163.com/#/playlist?id=${id}');

      var musicTagInfo = MusicTagInfo(
          element.getElementsByTagName('img').first.attributes['src'].toString(), //!.replaceFirst('140y140', '512y512')
          element.getElementsByTagName('div').first.getElementsByTagName('a').first.attributes['title'].toString(),
          'neplaylist_${id}',
          'https://music.163.com/#/playlist?id=${id}');
      playlists.add(musicTagInfo);
    });

    return playlists;

  }

  String _createSecretKey(int size) {
    List<String> result = [];
    List<String> choice = '012345679abcdef'.split('');
    for (int i = 0; i < size; i += 1) {
      int index = Random().nextInt(choice.length);
      result.add(choice[index]);
    }
    return result.join('');

  }

  Future ensureCookie() async {

    String domain = 'https://music.163.com';
    String nuidName = '_ntes_nuid';
    String nnidName = '_ntes_nnid';

    final cookieJar = CookieJar();

    cookieJar.loadForRequest(Uri.parse(domain)).then((value) {
      if(value.where((element) => element.name == nuidName).isEmpty) {
        String nuidValue = _createSecretKey(32);
        String nnidValue = '$nuidName%2C${DateTime.now().millisecondsSinceEpoch}';
        // netease default cookie expire time: 100 years
        DateTime expire = DateTime.now().add(const Duration(days: 100 * 365));
        Cookie nuidNameCookie = Cookie(nuidName, nuidValue);
        nuidNameCookie.expires = expire;

        Cookie nnidNameCookie = Cookie(nnidName, nnidValue);
        nnidNameCookie.expires = expire;

        List<Cookie> cookies = [nuidNameCookie, nnidNameCookie];

        cookieJar.saveFromResponse(Uri.parse(domain), cookies);
      }
    });

  }


  MusicInfo _convert(songInfo, allowAll) {
    var d = MusicInfo();

    d.setId('netrack_${songInfo['id']}');
    d.setTitle(songInfo['name']);
    d.setArtist(songInfo['ar'][0]['name'],);
    d.setArtistId('neartist_${songInfo['ar'][0]['id']}');
    d.setAlbum(songInfo['al']['name']);
    d.setAlbumId('nealbum_${songInfo['al']['id']}');
    d.setImgUrl(songInfo['al']['picUrl']);
    d.setSource('netease');
    d.setSourceUrl('http://music.163.com/#/song?id=${songInfo['id']}');
    //d.setUrl(!_qqIsPlayable(song) ? '' : null);

    return d;
  }

  Future<List<MusicInfo>> _parsePlaylistTracks(track_ids) async {

    String tracksUrl = 'https://music.163.com/weapi/v3/song/detail';

    Map<String, dynamic> query = {
      'c': '[' + track_ids.map((id) => '{"id":' + id.toString() + '}').join(',') + ']',
      'ids': '[' + track_ids.join(',') + ']',
    };

    String response = await _requestAPI(tracksUrl, query);
    final Map<String, dynamic> responseData = jsonDecode(response);
    List<MusicInfo> tracks = [];
    responseData['songs'].forEach((item) {
      tracks.add(_convert(item, true));
    });
    return tracks;
  }

  @override
  Future<Map<String, dynamic>> getPlaylist(String playlistId) async {
    String listId = playlistId.split('_').last;
    Map<String, dynamic> query = {
      'id': listId,
      'offset': 0,
      'total': true,
      'limit': 1000,
      'n': 1000,
      'csrf_token': '',
    };

    const playlist_url = 'http://music.163.com/weapi/v3/playlist/detail';


    await ensureCookie();

    String resData = await _requestAPI(playlist_url, query);

    final Map<String, dynamic> jsonData = jsonDecode(resData.toString());
    //log(jsonData);

    MusicTagInfo info = MusicTagInfo(_getSmallImageUrl(jsonData['playlist']['coverImgUrl'].toString()), jsonData['playlist']['name'], 'neplaylist_${listId}', 'http://music.163.com/#/playlist?id=${listId}');
    /*{
        'id': 'neplaylist_${listId}',
        'cover_img_url':
            _getSmallImageUrl(jsonData['playlist']['coverImgUrl'].toString()),
        'title': jsonData['playlist']['name'],
        'source_url': 'http://music.163.com/#/playlist?id=${listId}',
      };*/

    // request all tracks to fetch song info
    // Code reference from listen1_chrome_extension

    List<dynamic> track_ids = jsonData['playlist']['trackIds'].map((i) => i['id']).toList();

    List<MusicInfo> tracks = await _parsePlaylistTracks(track_ids);

    return {'info': info, 'tracks': tracks};
  }

  @override
  Future<String> bootstrapTrack(String trackId) async {
    String url =
        'https://interface3.music.163.com/eapi/song/enhance/player/url';

    String eapiUrl = '/api/song/enhance/player/url';

    String songId = trackId.substring('netrack_'.length);

    Map<String, dynamic> d = {
      'ids': [songId],
      'br': 999000,
    };

    var data = CryptoUtil.eapi(eapiUrl, d);

    DateTime expire = DateTime.now().add(const Duration(days: 100 * 365));

    final cookieJar = CookieJar();

    Cookie cookie = Cookie('os', 'pc');
    cookie.expires = expire;

    var cookies = [cookie];

    await cookieJar.saveFromResponse(Uri.parse('https://interface3.music.163.com'), cookies);

    return RequestUtil.postAction(url, data: data, headers: headers).then((resData){
      print('结果：${resData}');
      var jsonData = jsonDecode(resData!);
      var songUrl = jsonData['data'][0]['url'];
      if (songUrl == null) {
        return '';
      }
      return songUrl;
    });

    /*return _requestAPI(url, data).then((resData) {

      var jsonData = jsonDecode(resData);

      var songUrl = jsonData['data'][0]['url'];
      if (songUrl == null) {
        return '';
      }
      return songUrl;
    });*/
  }

  @override
  Future<Map<String, dynamic>> search(keyword, page) {
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

    return _requestAPI(url, data).then((resData) {
      List<MusicInfo> tracks =
          resData.result.songs.map((item) => _convert(item, false));
      return {
        'result': tracks,
        'total': resData.result.songCount,
      };
    });
  }

  Map<String, dynamic>? _parseUrl(String url) {
    Iterable<Match> r =
        '/\/\/music\.163\.com\/playlist\/([0-9]+)/g'.allMatches(url);

    if (r.isNotEmpty) {
      return {
        'type': 'playlist',
        'id': 'neplaylist_${r.toList()[1].group(0)}',
      };
    }

    if (url.contains('//music.163.com/#/m/playlist') ||
        url.contains('//music.163.com/#/playlist') ||
        url.contains('//music.163.com/playlist') ||
        url.contains('//music.163.com/#/my/m/music/playlist')) {
      var queryParameters = Uri.parse(url).queryParameters;

      return {
        'type': 'playlist',
        'id': 'neplaylist_${queryParameters['id']}',
      };
    }

    return null;
  }

  var meta = {'name': '网易', 'platformId': 'ne', 'enName': 'netease'};
}
