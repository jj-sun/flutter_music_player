import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_music_player/api/provider/qq.dart';
import 'package:flutter_music_player/model/music_info.dart';
import 'package:provider/provider.dart';

class MusicPlayState extends ChangeNotifier {

  int _currentIndex = 0;
  String _currentPlayId = "";

  List<MusicInfo> _currentPlayList = <MusicInfo>[];


  List<MusicInfo> get currentPlayList => _currentPlayList;

  MusicInfo? get currentMusicInfo{
    if(_currentPlayList.isNotEmpty) {
      return _currentPlayList[_currentIndex];
    } else {
      return null;
    }
  }

  //更新播放列表
  void updatePlayList(List<MusicInfo> list, int currentIndex) {
    _currentPlayList = list;
    _currentIndex = currentIndex;
  }

  void playAll(List<MusicInfo> list) {
    print(list);
    updatePlayList(list, 0);
    _play();
  }

  void playNewMusic(MusicInfo musicInfo) {
    for(int index = 0; index < _currentPlayList.length; index++) {
      if(_currentPlayList[index].getId == musicInfo.getId) {
        _currentIndex = index;
        _play();
        return;
      }
    }
    _currentPlayList.add(musicInfo);
    _currentIndex = _currentPlayList.length - 1;
    _play();
  }

  void updatePlayItem(int index) {
    _currentIndex = index;
    musicPlay();
  }

  final AudioPlayer _audioPlayer = AudioPlayer();

  late PlayerState _playerState = PlayerState.stopped;

  Duration _duration = Duration();

  Duration _position = Duration.zero;

  get playerState => _playerState;

  MusicPlayState() {

    _setPlaybackRate(1);

    _setListener();

  }

  _setListener() {
    print('监听!');
    // 播放完成
    _audioPlayer.onPlayerStateChanged.listen((PlayerState playerState) {
      print('监听${playerState}');
      _playerState = playerState;
      notifyListeners();
    });
    //监听时长
    _audioPlayer.onDurationChanged.listen((d) {
      _duration = d;
      notifyListeners();
    });

    //监听进度
    _audioPlayer.onPositionChanged.listen((p) {
      _position = p;

      notifyListeners();
    });

    _audioPlayer.onPlayerComplete.listen((event) {
      print('监听完成');
      musicControlNext();
    });


  }

  _setPlaybackRate(double playbackRate) {
    _audioPlayer.setPlaybackRate(playbackRate);
  }

  void _play() async {
    print("当前ID：" + _currentPlayId);
    //print("当前音乐" + currentMusicInfo.getId);
    if(_currentPlayId == currentMusicInfo?.getId) {
      _resume();
    }
    _currentPlayId = currentMusicInfo?.getId;
    QQUtil.bootstrapTrack(_currentPlayId).then((audioUrl) {
      //_audioPlayer.stop();
      if(audioUrl.isNotEmpty) {
        _audioPlayer.play(UrlSource(audioUrl));
      } else {
        musicControlNext();
      }
    });


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
    final position = value * _duration.inMilliseconds;

    return _seek(position);
  }

  Future<void> _seek(double position) {
    return _audioPlayer.seek(Duration(milliseconds: position.round()));
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

  //播放下一首
  void musicControlNext(){
    musicNextIndex();
    _play();
  }

  void musicNextIndex(){
    int index = _currentIndex + 1;
    index = index == _currentPlayList.length ? 0 : index;
    _currentIndex = index;
  }

  static MusicPlayState of(BuildContext context) {
    return Provider.of<MusicPlayState>(context, listen: false);
  }

}