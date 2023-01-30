import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_music_player/common/state/music_play_state.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';

import '../model/music_info.dart';

class PlayDetailPage extends StatefulWidget {

  const PlayDetailPage({Key? key}) : super(key: key);

  @override
  State<PlayDetailPage> createState() => _PlayDetailPageState();
}

class _PlayDetailPageState extends State<PlayDetailPage> {

  late MusicPlayState musicPlayStateProvider = MusicPlayState.of(context);
  

  @override
  Widget build(BuildContext context) {

    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    var _icons = [Icons.play_circle_outline, Icons.pause_circle_outline];

    var _modeIcons = [Icons.repeat, Icons.shuffle, Icons.repeat_one];

    return Scaffold(
      appBar: AppBar(
        toolbarTextStyle: const TextStyle(color: Colors.red),
        backgroundColor: Colors.black12,
        leading: IconButton(
          icon: Icon(Icons.expand_more_outlined, color: Colors.black,),
          onPressed: () {
            context.pop();
          },
        ),
        //title: Text('播放器', style: TextStyle(color: Colors.black),),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.more_horiz, color: Colors.black,),
            onPressed: () {
              showModalBottomSheet(context: context, builder: (BuildContext context) {
                return Container(
                  height: screenHeight * 0.4,
                  color: Colors.white,
                  child: Column(
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                        title: Text(musicPlayStateProvider.currentMusicInfo.getTitle),
                      ),
                      Divider(color: Colors.black,),
                      Expanded(
                          child: Scrollbar(
                            child: ListView(
                              padding: EdgeInsets.zero,
                              children: [
                                ListTile(
                                  leading: Icon(Icons.playlist_add),
                                  contentPadding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                                  title: Text('收藏到歌单'),
                                ),
                                ListTile(
                                  leading: Icon(Icons.person),
                                  contentPadding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                                  title: Text('歌手：${musicPlayStateProvider.currentMusicInfo.getArtist}'),
                                ),
                                ListTile(
                                  leading: Icon(Icons.album),
                                  contentPadding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                                  title: Text('专辑：${musicPlayStateProvider.currentMusicInfo.getAlbum}'),
                                ),
                                ListTile(
                                  leading: Icon(Icons.link),
                                  contentPadding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                                  title: Text('来源：${musicPlayStateProvider.currentMusicInfo.getSource}'),
                                ),
                              ],
                            ),
                          )
                      ),
                    ],
                  ),
                );
              });
            },
          )
        ]
      ),
      body: Container(
        child: Consumer<MusicPlayState>(
          builder: (context, musicPlayState,child) {
            return Column(
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    height: screenHeight * 0.5,
                    width: screenWidth,
                    padding: EdgeInsets.all(10),
                    child: Image.network(musicPlayState.currentMusicInfo.getImgUrl),
                    color: Colors.black12,
                  ),
                ),
                Container(
                  height: screenHeight * 0.3,
                  width: screenWidth,
                  padding: EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(musicPlayState.currentMusicInfo.getTitle, style: TextStyle(fontSize: 20),),
                      Text(musicPlayState.currentMusicInfo.getArtist, style: TextStyle(color: Colors.black54),),
                    ],
                  ),
                  color: Colors.black12,
                ),
                Container(
                    height: screenHeight * 0.1,
                    padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: Row(
                      children: [
                        Text(musicPlayState.position.toString().split('.')[0]),
                        Expanded(
                          child: _sliderTheme(context, musicPlayState),
                        ),
                        Text(musicPlayState.duration.toString().split('.')[0])
                      ],
                    ),
                    color: Colors.black12
                ),
                Container(
                  height: screenHeight * 0.1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    verticalDirection: VerticalDirection.up,
                    children: [
                      IconButton(icon: Icon(_modeIcons[musicPlayState.musicModeIndex]),
                          onPressed: () {
                            // shuffle 随机  repeat-one
                            musicPlayState.changeMusicMode();
                          }
                      ),
                      IconButton(icon: Icon(Icons.skip_previous),
                          onPressed: () {
                            musicPlayState.musicControlPrevious();
                          }
                      ),
                      IconButton(
                          icon: musicPlayState.playerState == PlayerState.playing
                              ? Icon(_icons[1])
                              : Icon(_icons[0]),
                          iconSize: 50,
                          onPressed: () {
                            if (musicPlayState.playerState == PlayerState.paused) {
                              musicPlayState.musicResume();
                            } else if (musicPlayState.playerState == PlayerState.playing) {
                              musicPlayState.musicPause();
                            } else if (musicPlayState.playerState == PlayerState.stopped) {
                              musicPlayState.musicPlay();
                            }
                          }
                      ),
                      IconButton(icon: Icon(Icons.skip_next),
                          onPressed: () {
                            musicPlayState.musicControlNext();
                          }
                      ),
                      IconButton(icon: Icon(Icons.queue_music),
                          onPressed: () {
                            if(musicPlayState.currentPlayList.isNotEmpty) {
                              showModalBottomSheet(context: context, builder: (BuildContext context) {
                                return Container(
                                  height: screenHeight * 0.75,
                                  color: Colors.white,
                                  child: Column(
                                    children: [
                                      ListTile(
                                        leading: Icon(Icons.repeat),
                                        title: Text('播放列表(${musicPlayState.currentPlayList.length}首)'),
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

                                                List<MusicInfo> musicInfoList =
                                                    musicPlayState.currentPlayList;

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
                              });
                            }

                          }
                      )
                    ],
                  ),
                ),

              ],
            );
          },
        ),
      ),
    );
  }



  Widget _sliderTheme(context, MusicPlayState musicPlayState) {

    double _value = musicPlayState.position.inSeconds.toDouble();
    double _max = musicPlayState.duration.inSeconds.toDouble();

    return SliderTheme(
        data: SliderThemeData(
            trackHeight: 1,
            thumbShape: RoundSliderThumbShape(enabledThumbRadius: 5)
        ),
        child: Slider(
            activeColor: Colors.red,
            inactiveColor: Colors.black,
            thumbColor: Colors.green,
            value: _value,
            min: 0,
            max: _max,
            onChanged: (double newValue){
              setState(() {
                _value = newValue;
                musicPlayState.musicSeek(_value);
              });

            })
    );
  }

}

