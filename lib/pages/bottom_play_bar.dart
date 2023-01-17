import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_music_player/common/state/bottom_play_bar_state.dart';
import 'package:flutter_music_player/common/state/music_play_state.dart';
import 'package:flutter_music_player/model/music_info.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class BottomPlayBar extends StatefulWidget {

  const BottomPlayBar({Key? key}) : super(key: key);

  @override
  State<BottomPlayBar> createState() => _BottomPlayBarState();
}

class _BottomPlayBarState extends State<BottomPlayBar> {

  late BottomPlayBarState bottomPlayBarState = BottomPlayBarState.of(context);

  late MusicPlayState musicPlayState = MusicPlayState.of(context);

  var _icons = [FontAwesomeIcons.circlePlay, FontAwesomeIcons.circlePause];

  @override
  void initState() {
    super.initState();
    //musicPlayState =
  }



  /*Object _images(obj) {
    return obj == null
        ? AssetImage('')
        : NetworkImage(musicPlayState.currentMusicInfo?.getImgUrl);
  }*/

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth  = MediaQuery.of(context).size.width;
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
                return AppBar(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  //shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),AssetImage('assets/lady.jpeg')
                  leading: InkWell(
                    child: Image.asset('assets/lady.jpeg',fit: BoxFit.fill,),
                  ),
                  title: TextButton(
                    child: Text(
                      '${musicPlayState.currentMusicInfo?.getTitle} - ${musicPlayState.currentMusicInfo?.getArtist}',
                      style: const TextStyle(fontSize: 14, color: Colors.black, overflow: TextOverflow.ellipsis),
                    ),
                    onPressed: () {},
                  ),
                  actions: [
                    IconButton(
                      icon: audioState == PlayerState.playing
                          ? FaIcon(_icons[1])
                          : FaIcon(_icons[0]),
                      onPressed: () {
                        print(audioState);
                        if (audioState == PlayerState.paused) {
                          musicPlayState.musicPlay();
                        } else if (audioState == PlayerState.playing) {
                          musicPlayState.musicPause();
                        }
                      },
                    ),
                    IconButton(
                      icon: FaIcon(FontAwesomeIcons.outdent),
                      onPressed: () {
                        List<MusicInfo> musicInfoList =
                            musicPlayState.currentPlayList;
                        print(musicInfoList.length);
                        if(musicInfoList.isNotEmpty) {
                          /*setState(() {
                            this.visible = false;
                          });*/
                          bottomPlayBarState.hideBottomPlayBar();
                          showModalBottomSheet(context: context, builder: (BuildContext context) {
                            return Container(
                              height: screenHeight * 0.75,
                              color: Colors.white,
                              child: Column(
                                children: [
                                  ListTile(
                                    leading: FaIcon(FontAwesomeIcons.repeat),
                                    title: Text('播放列表(${musicInfoList.length}首)'),
                                  ),
                                  Divider(),
                                  Expanded(
                                      child: Scrollbar(
                                        child: ListView.builder(
                                            padding: EdgeInsets.zero,
                                            primary: true,
                                            shrinkWrap: true,
                                            itemCount: musicInfoList.length,
                                            itemBuilder: (BuildContext context, int index) {

                                              return ListTile(
                                                  textColor: musicPlayState.currentMusicInfo?.getId == musicInfoList[index].getId ? Colors.red : musicInfoList[index].getDisabled ? Colors.black12 : Colors.black,
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
                );
              },
            )));
  }
}
