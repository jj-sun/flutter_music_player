import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_music_player/api/provider/qq.dart';
import 'package:flutter_music_player/common/enums/music_mode_enum.dart';
import 'package:flutter_music_player/model/music_info.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import '../../api/client.dart';
import '../../api/client_factory.dart';

class MusicPlayState extends ChangeNotifier {

  int _currentIndex = 0;
  String _currentPlayId = "";

  List<MusicInfo> _currentPlayList = <MusicInfo>[];

  MusicModeEnum _musicModeEnum = MusicModeEnum.repeat;


  List<MusicInfo> get currentPlayList => _currentPlayList;

  int get currentIndex => _currentIndex;

  String get currentPlayId => _currentPlayId;

  int get musicModeIndex => _musicModeEnum.index;

  MusicInfo get currentMusicInfo{
    if(_currentPlayList.isNotEmpty) {
      return _currentPlayList[_currentIndex];
    } else {
      var d = MusicInfo();
      d.setId('qqtrack_003YC3p31HyR96');
      d.setTitle('最美的期待');
      d.setArtist('周笔畅');
      d.setArtistId('qqartist_004HlS192u9J5g');
      d.setAlbum('最美的期待');
      d.setAlbumId('qqalbum_001Qn04n29RAmP');
      d.setImgUrl('');
      d.setSource('qq');
      d.setSourceUrl('http://y.qq.com/#type=song&mid=003YC3p31HyR96&tpl=yqq_song_detail');
      d.setUrl('');

      //此处需要初始化一首歌
      return d;
    }
  }

  //更新播放列表
  void updatePlayList(List<MusicInfo> list, int currentIndex) {
    _currentPlayList = list;
    _currentIndex = currentIndex;
  }

  void playAll(List<MusicInfo> list) {
    //自动移除会员歌曲
    List<MusicInfo> musicList = [];
    for (var element in list) {
      if(element.getDisabled != true) {
        musicList.add(element);
      }
    }

    if(musicList.isNotEmpty) {
      updatePlayList(list, 0);
      _play();
    }
  }

  //从音乐列表中播放音乐
  void playNewMusic(MusicInfo musicInfo) {
    bool flag = false;
    for(int index = 0; index < _currentPlayList.length; index++) {
      if(_currentPlayList[index].getId == musicInfo.getId) {
        _currentIndex = index;
        _play();
        flag = true;
        break;
      }
    }
    if(!flag) {
      _currentPlayList.add(musicInfo);
      _currentIndex = _currentPlayList.length - 1;
      _play();
    }
    notifyListeners();
  }

  //在播放列表中播放音乐
  void playMusicIndex(int index) {
    if(index >= 0 && index < _currentPlayList.length) {
      _currentIndex = index;
      _play();
    }
  }

  void updatePlayItem(int index) {
    _currentIndex = index;
    musicPlay();
  }

  void remove(int index) {
    if(index == _currentIndex) {
      musicControlNext();
    }
    _currentPlayList.removeAt(index);
  }

  final AudioPlayer _audioPlayer = AudioPlayer();

  late PlayerState _playerState = PlayerState.stopped;

  Duration _duration = Duration();

  Duration _position = Duration.zero;

  get playerState => _playerState;

  Duration get duration => _duration;

  Duration get position => _position;

  MusicPlayState() {

    _setPlaybackRate(1);

    _setListener();

  }

  _setListener() {
    // 播放完成
    _audioPlayer.onPlayerStateChanged.listen((PlayerState playerState) {
      print('状态监听：${playerState}');
      _playerState = playerState;
      notifyListeners();

    });
    //监听时长
    _audioPlayer.onDurationChanged.listen((d) {
      //print('时长监听：${d}');
      _duration = d;
      notifyListeners();
    });

    //监听进度
    _audioPlayer.onPositionChanged.listen((p) {
      //print('进度监听：${p}');
      _position = p;

      notifyListeners();
    });

    _audioPlayer.onPlayerComplete.listen((event) {
      print('播放完成监听');
      if(_musicModeEnum.index == 0) {
        //继续播放当前音乐
        print('顺序播放');
        musicControlNext();
      } else if(_musicModeEnum.index == 1) {
        //随机播放
        print('随机播放');
        musicRandom();
      } else {
        print('单曲播放');
        _play();
      }
      notifyListeners();
    });


  }

  _setPlaybackRate(double playbackRate) {
    _audioPlayer.setPlaybackRate(playbackRate);
  }

  void _play() async {
    print("当前ID：" + _currentPlayId);
    //print("当前音乐" + currentMusicInfo.getId);
    if(_currentPlayId == currentMusicInfo.getId) {
      _resume();
    }
    if(currentMusicInfo != null) {
      _currentPlayId = currentMusicInfo.getId;
      Client client = ClientFactory.getFactory(_currentPlayId.substring(0,2));

      client.bootstrapTrack(_currentPlayId).then((audioUrl) {
        if(audioUrl.isNotEmpty) {
          _audioPlayer.play(UrlSource(audioUrl));
        } else {
          Fluttertoast.showToast(
            msg: "平台版权原因无法播放，请尝试其他平台",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.black87,
            textColor: Colors.white70,
          ).then((value) {
            musicControlNext();
          });
        }
      });
    }
    notifyListeners();
  }

  void _resume() async {
    await _audioPlayer.resume();
  }

  void _pause() async {
    await _audioPlayer.pause();
  }

  void _stop() async {
    await _audioPlayer.stop();
  }

  void musicResume() {
    _resume();
  }

  void musicPause() {
    _pause();
  }

  void musicStop() {
    _stop();
  }

  void musicPlay() {
    _play();
  }

  /// 更新播放进度
  Future<void> musicSeek(double value){
    //final position = value * _duration.inMilliseconds;

    return _seek(value);
  }

  Future<void> _seek(double position) {
    return _audioPlayer.seek(Duration(seconds: position.round()));
  }


  void musicClear(){
     _stop();
    _currentPlayList = <MusicInfo>[];
    _currentIndex = 0;
    _currentPlayId = "";
  }

  //播放上一首
  void musicControlPrevious(){
    musicPreviousIndex();
    _play();
  }

  void musicPreviousIndex(){
    int index = _currentIndex - 1;
    index = index < 0 ? _currentPlayList.length-1 : index;
    _currentIndex = index;
  }

  /// 播放下一首
  void musicControlNext(){
    musicNextIndex();
    _play();
  }

  void musicNextIndex(){
    int index = _currentIndex + 1;
    index = index == _currentPlayList.length ? 0 : index;
    _currentIndex = index;
  }

  /// 随机播放
  void musicRandom() {
    int index = _currentPlayList.isEmpty ? 0 : Random().nextInt(_currentPlayList.length);
    _currentIndex = index;

    _play();
  }

  /// 单曲循环
  void musicOnePlay() {

  }


  /// 更改音乐播放状态，0顺序播放，1随机播放，2单曲循环
  void changeMusicMode() {
    if(_musicModeEnum.index == 0) {
      _musicModeEnum = MusicModeEnum.shuffle;
    } else if(_musicModeEnum.index == 1) {
      _musicModeEnum = MusicModeEnum.repeatOne;
    } else {
      _musicModeEnum = MusicModeEnum.repeat;
    }
    notifyListeners();
  }

  static MusicPlayState of(BuildContext context) {
    return Provider.of<MusicPlayState>(context, listen: false);
  }

}