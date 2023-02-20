import 'dart:core';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_music_player/api/client.dart';
import 'package:flutter_music_player/utils/request_util.dart';
import 'package:flutter_music_player/model/music_info.dart';
import 'package:flutter_music_player/model/music_tag_info.dart';
import 'dart:developer';

class QQ implements Client {
   String _htmlDecode(s) {
    return s;
  }

   String _qqGetImageUrl(String qqimgid, String imgType) {
    if (qqimgid.isEmpty) {
      return '';
    }
    String category = '';

    if (imgType == 'artist') {
      category = 'T001R300x300M000';
    }
    if (imgType == 'album') {
      category = 'T002R300x300M000';
    }
    String s = category + qqimgid;
    String url = 'https://y.gtimg.cn/music/photo_new/$s.jpg';

    return url;
  }

   bool _qqIsPlayable(song) {
    //print(song['switch'].runtimeType);
    var switchFlag = song['switch'].toRadixString(2).toString().split('');
    List<String> switchF = switchFlag.take(switchFlag.length - 1).toList();
    //switchFlag.pop();

    // flag switch table meaning:
    // ["play_lq", "play_hq", "play_sq", "down_lq", "down_hq", "down_sq", "soso",
    //  "fav", "share", "bgm", "ring", "sing", "radio", "try", "give"]
    var playFlag = switchF.reversed.first;
    var tryFlag = switchF.reversed.elementAt(13);
    return playFlag == '1' || (playFlag == '1' && tryFlag == '1');
  }

   MusicInfo _qqConvertSong(song) {

    var d = MusicInfo();
    d.setId('qqtrack_${song['songmid']}');
    d.setTitle(_htmlDecode(song['songname']));
    d.setArtist(_htmlDecode(song['singer'][0]['name']));
    d.setArtistId('qqartist_${song['singer'][0]['mid']}');
    d.setAlbum(_htmlDecode(song['albumname']));
    d.setAlbumId('qqalbum_${song['albummid']}');
    d.setImgUrl(_qqGetImageUrl(song['albummid'], 'album'));
    d.setSource('qq');
    d.setSourceUrl('http://y.qq.com/#type=song&mid=${song['songmid']}&tpl=yqq_song_detail');
    d.setUrl(!_qqIsPlayable(song) ? '' : null);
    return d;
  }

   MusicInfo _qqConvertSong2(song) {
     var d = MusicInfo();
     d.setId('qqtrack_${song['songmid']}');
     d.setTitle(_htmlDecode(song['songname']));
     d.setArtist(_htmlDecode(song['singer'][0]['name']));
     d.setArtistId('qqartist_${song['singer'][0]['mid']}');
     d.setAlbum(_htmlDecode(song['albumname']));
     d.setAlbumId('qqalbum_${song['albummid']}');
     d.setImgUrl(_qqGetImageUrl(song['albummid'], 'album'));
     d.setSource('qq');
     d.setSourceUrl('http://y.qq.com/#type=song&mid=${song['songmid']}&tpl=yqq_song_detail');
     d.setUrl('');
     return d;
   }

  /**
   * 获取分类表单信息
   */
   @override
   Future<List<MusicTagInfo>> showPlaylist(
      int offset) async {
    String url =
        'https://c.y.qq.com/splcloud/fcgi-bin/fcg_get_diss_by_tag.fcg?picmid=1&loginUin=0&hostUin=0&format=json&inCharset=utf8&outCharset=utf-8&notice=0&platform=yqq.json&needNewCode=0&categoryId=10000000&sortId=5&sin=${offset}&ein=${29 + offset}';
    var data = await RequestUtil.getAction(
      url,
      headers: {
        'Referer': 'https://y.qq.com/',
      },
    );
    const JsonDecoder decoder = JsonDecoder();
    final Map<String, dynamic> object = decoder.convert(data.toString());
    List<dynamic> list = object['data']['list'];

    List<MusicTagInfo> playlists = [];

    list.forEach((item) {
      var musicTagInfo = MusicTagInfo(
          item['imgurl'],
          item['dissname'],
          'qqplaylist_${item['dissid']}',
          'https://y.qq.com/n/ryqq/playlist${item['dissid']}');
      playlists.add(musicTagInfo);
      // playlists.add({
      //   'cover_img_url': item['imgurl'],
      //   'title': item['dissname'],
      //   'id': 'qqplaylist_${item['dissid']}',
      //   'source_url': 'http://y.qq.com/#type=taoge&id=${item['dissid']}',
      // });
    });
    // List<Map<String, dynamic>> playlists = list.map((item) => {
    //   'cover_img_url': item['imgurl'],
    //   'title': item['dissname'],
    //   'id': 'qqplaylist_${item['dissid']}',
    //   'source_url': 'http://y.qq.com/#type=taoge&id=${item['dissid']}',
    // });
    //print(playlists);
    return playlists;
  }

  /**
   * 查询歌曲
   */
   @override
   Future<Map<String,dynamic>> search(String keyword, int page) async {
    String url =
    'http://i.y.qq.com/s.music/fcgi-bin/search_for_qq_cp?g_tk=938407465&uin=0&format=jsonp&inCharset=utf-8&outCharset=utf-8&notice=0&platform=h5&needNewCode=1&w=${keyword}&zhidaqu=1&catZhida=1&t=0&flag=1&ie=utf-8&sem=1&aggr=0&perpage=20&n=20&p=${page}&remoteplace=txt.mqq.all&_=1459991037831&jsonpCallback=jsonp4';

    var data = await RequestUtil.getAction(
      url,
      headers: {
        'Referer': 'https://y.qq.com/',
      },
    );
    String? text = data?.substring('jsonCallback('.length, data.length-1);
    const JsonDecoder jsonDecoder = JsonDecoder();
    var jsonData = jsonDecoder.convert(text!);
    List<MusicInfo> tracks = jsonData['data']['song']['list'].map((item) => _qqConvertSong(item));
    return {
      'result': tracks,
      'total': jsonData['data']['song']['totalnum']
    };

    // return fetch(url, {
    //   headers: {
    //   Referer: 'https://y.qq.com/',
    // },
    // })
    //     .then(response => {
    // return response.text();
    // })
    //     .then(textData => {
    // const text = textData.slice('jsonp4('.length, -')'.length);
    // const jsonData = JSON.parse(text);
    // const tracks = jsonData.data.song.list.map(item => qqConvertSong(item));
    //
    // return { result: tracks, total: jsonData.data.song.totalnum };
    // })
    //     .catch(() => {
    // // console.error(error);
    // });
  }

  /**
   * 根据分类获取分类歌单的播放列表
   */
   @override
   Future<Map<String, dynamic>> getPlaylist(String playlistId) async {
    var listId = playlistId.split('_')[1];
    var targetUrl =
    'http://i.y.qq.com/qzone-music/fcg-bin/fcg_ucc_getcdinfo_byids_cp.fcg?type=1&json=1&utf8=1&onlysong=0&jsonpCallback=jsonCallback&nosign=1&disstid=${listId}&g_tk=5381&loginUin=0&hostUin=0&format=jsonp&inCharset=GB2312&outCharset=utf-8&notice=0&platform=yqq&jsonpCallback=jsonCallback&needNewCode=0';

    var data = await RequestUtil.getAction(
      targetUrl,
      headers: {
        'Referer': 'https://y.qq.com/',
      },
    );
    String? text = data?.substring('jsonCallback('.length, data.length-1);
    const JsonDecoder jsonDecoder = JsonDecoder();
    var jsonData = jsonDecoder.convert(text!);
    // print(jsonData);
    // print(jsonData['cdlist'][0]['logo']);
    // print(jsonData['cdlist'][0]['dissname']);
    
    var info = MusicTagInfo(jsonData['cdlist'][0]['logo'], jsonData['cdlist'][0]['dissname'], 'qqplaylist_${listId}', 'http://y.qq.com/#type=taoge&id=${listId}');
    List<dynamic> songlist = jsonData['cdlist'][0]['songlist'];
    List<MusicInfo> tracks = songlist.map((item) => _qqConvertSong(item)).toList();

    //log(tracks.toString());

    return {
        'tracks': tracks,
        'info': info,
    };
  }

  @override
  Future<String> bootstrapTrack(String trackId) async {
    if(trackId.isEmpty) {
      return '';
    }
    var songId = trackId.substring('qqtrack_'.length);
    var targetUrl =
    'https://u.y.qq.com/cgi-bin/musicu.fcg?loginUin=0&hostUin=0&format=json&inCharset=utf8&outCharset=utf-8&notice=0&platform=yqq.json&needNewCode=0&data=%7B%22req_0%22%3A%7B%22module%22%3A%22vkey.GetVkeyServer%22%2C%22method%22%3A%22CgiGetVkey%22%2C%22param%22%3A%7B%22guid%22%3A%2210000%22%2C%22songmid%22%3A%5B%22${songId}%22%5D%2C%22songtype%22%3A%5B0%5D%2C%22uin%22%3A%220%22%2C%22loginflag%22%3A1%2C%22platform%22%3A%2220%22%7D%7D%2C%22comm%22%3A%7B%22uin%22%3A0%2C%22format%22%3A%22json%22%2C%22ct%22%3A20%2C%22cv%22%3A0%7D%7D';


    String? data = await RequestUtil.getAction(
      targetUrl,
      headers: {
        'Referer': 'https://y.qq.com/',
        'User-Agent': 'Mozilla/5.0 (Linux; U; Android 8.1.0; zh-cn; BLA-AL00 Build/HUAWEIBLA-AL00) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/57.0.2987.132 MQQBrowser/8.9 Mobile Safari/537.36',
      },
    );
    //print('获取的数据${data}');
    const JsonDecoder jsonDecoder = JsonDecoder();
    var jsonData = jsonDecoder.convert(data!);
    //print('获取数据${jsonData['req_0']['data']['midurlinfo'][0]['purl']}');
    if(jsonData['req_0']['data']['midurlinfo'][0]['purl'] == '') {
      return '';
    }
    var url = jsonData['req_0']['data']['sip'][0] + jsonData['req_0']['data']['midurlinfo'][0]['purl'];
    //print('播放源:' + url);
    return url;
  }

  Map<String, String> _parseUrl(url) {
    var result = <String, String>{};
    var match = '/\/\/y.qq.com\/n\/yqq\/playlist\/([0-9]+)/'.allMatches(url);

    if (match != null) {
      var playlistId = match.toList()[1].group(0);

      result = {
      'type': 'playlist',
      'id': 'qqplaylist_${playlistId}',
      };
    }
    match = '/\/\/y.qq.com\/n\/yqq\/playsquare\/([0-9]+)/'.allMatches(url);
    if (match != null) {
      var playlistId = match.toList()[1].group(0);

      result = {
      'type': 'playlist',
      'id': 'qqplaylist_${playlistId}',
      };
    }
    match = '/\/\/y.qq.com\/n\/m\/detail\/taoge\/index.html\?id=([0-9]+)/'.allMatches(url);
    if (match != null) {
      var playlistId = match.toList()[1].group(0);

      result = {
      'type': 'playlist',
      'id': 'qqplaylist_${playlistId}',
      };
    }

    return result;
  }
  static var meta = { 'name': 'QQ', 'platformId': 'qq', 'enName': 'qq' };

}
