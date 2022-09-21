import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_music_player/model/music_info.dart';
import 'package:provider/provider.dart';

class MusicPlayState extends ChangeNotifier {

  int _currentIndex = 0;
  String _currentPlayId = "";

  List<MusicInfo> _currentPlayList = <MusicInfo>[];

  AudioPlayer _audioPlayer = AudioPlayer();

  late PlayerState _playerState = PlayerState.stopped;

  Duration _duration = Duration();

  Duration? _position = Duration.zero;

  void initPlayer() {
    _setPlaybackRate(1);
    _setListener();
  }

  _setListener() {
    // 播放完成
    _audioPlayer.onPlayerComplete.listen((event){
      _position = Duration.zero;
      _audioPlayer.release();
      //下一首
    });

    _audioPlayer.onPlayerStateChanged.listen((PlayerState playerState) {
      _playerState = playerState;
    });
    //监听时长
    _audioPlayer.onDurationChanged.listen((d) {
      _duration = d;
    });

    //监听进度
    _audioPlayer.onPositionChanged.listen((p) {
      _position = p;
    });


  }

  _setPlaybackRate(double playbackRate) {
    _audioPlayer.setPlaybackRate(playbackRate);
  }

  void _resume() async {
    await _audioPlayer.resume();
  }

  void _pause() async {
    await _audioPlayer.pause();
  }

  static MusicPlayState of(BuildContext context) {
    return Provider.of<MusicPlayState>(context, listen: false);
  }

}