import 'dart:developer';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_music_player/common/state/bottom_play_bar_state.dart';
import 'package:flutter_music_player/common/state/music_play_state.dart';
import 'package:flutter_music_player/model/music_info.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class BottomPlayBar extends StatefulWidget {

  const BottomPlayBar({Key? key}) : super(key: key);

  @override
  State<BottomPlayBar> createState() => _BottomPlayBarState();
}

class _BottomPlayBarState extends State<BottomPlayBar> {

  late BottomPlayBarState bottomPlayBarState = BottomPlayBarState.of(context);


  late MusicPlayState musicPlayState = MusicPlayState.of(context);


  var _icons = [Icons.play_circle_outline, Icons.pause_circle_outline];

  @override
  void initState() {
    super.initState();
    //musicPlayState =
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth  = MediaQuery.of(context).size.width;


    Offset _initSwipeOffset = Offset(0, 0);
    Offset _finalSwipeOffset = Offset(0, 0);

    return Visibility(
        visible: bottomPlayBarState.visible,
        maintainState: true,
        child: Container(
            padding: EdgeInsets.zero,
            color: Colors.black12,
            height: MediaQuery.of(context).size.height * 0.05,
            child: Selector<MusicPlayState, PlayerState>(
              shouldRebuild: (pre, next) {
                return pre != next;
              },
              selector: (context, state) {
                return state.playerState;
              },
              builder: (context, audioState, _) {
                return GestureDetector(
                  child: AppBar(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    //shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),AssetImage('assets/lady.jpeg')
                    leading: InkWell(
                      child: musicPlayState.currentMusicInfo.getImgUrl.isEmpty ? Image.asset('assets/lady.jpeg',fit: BoxFit.fill) : Image.network(musicPlayState.currentMusicInfo.getImgUrl,fit: BoxFit.fill,),
                    ),
                    title: Text(
                      '${musicPlayState.currentMusicInfo.getTitle} - ${musicPlayState.currentMusicInfo.getArtist}',
                      style: const TextStyle(fontSize: 14, color: Colors.black, overflow: TextOverflow.ellipsis),
                    ),
                    actions: [
                      IconButton(
                        icon: audioState == PlayerState.playing
                            ? Icon(_icons[1])
                            : Icon(_icons[0]),
                        onPressed: () {
                          print(audioState);
                          if (audioState == PlayerState.paused) {
                            musicPlayState.musicResume();
                          } else if (audioState == PlayerState.playing) {
                            musicPlayState.musicPause();
                          } else if (audioState == PlayerState.stopped) {
                            musicPlayState.musicPlay();
                          }
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.queue_music),
                        onPressed: () {
                          List<MusicInfo> musicInfoList =
                              musicPlayState.currentPlayList;
                          print(musicInfoList.length);
                          if(musicInfoList.isNotEmpty) {
                            bottomPlayBarState.hideBottomPlayBar();
                            showModalBottomSheet(context: context, builder: (BuildContext context) {
                              return Container(
                                height: screenHeight * 0.75,
                                color: Colors.white,
                                child: Column(
                                  children: [
                                    ListTile(
                                      leading: Icon(Icons.repeat),
                                      title: Text('播放列表(${musicInfoList.length}首)'),
                                    ),
                                    Divider(),
                                    Expanded(
                                        child: Scrollbar(
                                          child: Selector<MusicPlayState, String>(
                                            selector: (context, state) {
                                              return state.currentPlayId;
                                            },
                                            shouldRebuild: (pre, next){
                                              return pre != next;
                                            },
                                            builder: (context, currentPlayId, child) {
                                              return ListView.builder(
                                                  padding: EdgeInsets.zero,
                                                  primary: true,
                                                  shrinkWrap: true,
                                                  itemCount: musicInfoList.length,
                                                  itemBuilder: (BuildContext context, int index) {
                                                    return ListTile(
                                                        textColor: currentPlayId == musicInfoList[index].getId ? Colors.red : musicInfoList[index].getDisabled ? Colors.black12 : Colors.black,
                                                        leading: Text((index+1).toString()),
                                                        title: Text(
                                                            musicInfoList[index].getTitle,
                                                            overflow: TextOverflow.ellipsis
                                                        ),
                                                        subtitle: Text(musicInfoList[index].getArtist,overflow: TextOverflow.ellipsis),
                                                        onTap: () {
                                                          if(!musicInfoList[index].getDisabled) {
                                                            musicPlayState.playMusicIndex(index);
                                                          }
                                                        },
                                                        trailing: IconButton(
                                                            onPressed: () {
                                                              musicPlayState.remove(index);
                                                            },
                                                            icon: const Icon(Icons.close)
                                                        )
                                                    );
                                                  }
                                              );
                                            },
                                          ),
                                        )
                                    )
                                  ],
                                ),
                              );
                            }).then((value) => bottomPlayBarState.showBottomPlayBar());
                          }
                        },
                      ),
                    ],
                  ),
                  onTap: () {
                    context.go('/playDetail');
                  },
                  onHorizontalDragStart: (details) {
                    _initSwipeOffset = details.globalPosition;
                  },
                  onHorizontalDragUpdate: (details) {
                    _finalSwipeOffset = details.globalPosition;
                  },
                  onHorizontalDragEnd: (details) {
                    log('${_initSwipeOffset.dx} - ${_finalSwipeOffset.dx}');
                    if(_initSwipeOffset != null) {
                      final offsetDifference = _initSwipeOffset.dx - _finalSwipeOffset.dx;
                      if(offsetDifference > 0) {
                        // 左滑 下一首
                        musicPlayState.musicControlNext();
                      } else {
                        //右滑 上一首
                        musicPlayState.musicControlPrevious();
                      }
                    }
                  },
                );
              },
            )));
  }
}
