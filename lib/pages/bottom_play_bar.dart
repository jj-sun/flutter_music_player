import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
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
  late MusicPlayState musicPlayState;

  var _icons = [FontAwesomeIcons.circlePlay, FontAwesomeIcons.circlePause];

  bool visible = true;

  @override
  void initState() {
    super.initState();
    musicPlayState = MusicPlayState.of(context);
  }

  Object _images(obj) {
    return obj == null
        ? AssetImage('')
        : NetworkImage(musicPlayState.currentMusicInfo?.getImgUrl);
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth  = MediaQuery.of(context).size.width;
    return Visibility(
        visible: visible,
        child: Container(
            padding: EdgeInsets.all(4),
            height: MediaQuery.of(context).size.height * 0.07,
            child: Selector<MusicPlayState, PlayerState>(
              shouldRebuild: (pre, next) {
                return pre != next;
              },
              selector: (context, state) {
                return state.playerState;
              },
              builder: (context, audioState, _) {
                return AppBar(
                  backgroundColor: Colors.blueGrey,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  leading: InkWell(
                    child: CircleAvatar(
                      radius: 20,
                      backgroundImage: AssetImage('assets/lady.jpeg'),
                    ),
                  ),
                  title: TextButton(
                    child: Text(
                      '${musicPlayState.currentMusicInfo?.getTitle} - ${musicPlayState.currentMusicInfo?.getArtist}',
                      style: TextStyle(fontSize: 14, color: Colors.white),
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
                          setState(() {
                            this.visible = false;
                          });
                          Scaffold.of(context).showBottomSheet((context) {
                            return Container(
                              height: screenHeight * 0.8,
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
                                                  title: Text(
                                                    musicInfoList[index].getTitle,
                                                  ),
                                                  //subtitle: Text(musicInfoList[index].getArtist),
                                                  onTap: () {
                                                    musicPlayState.playMusicIndex(index);
                                                  },
                                                  trailing: IconButton(
                                                      onPressed: () {
                                                        musicPlayState.remove(index);
                                                      },
                                                      icon: Icon(
                                                          Icons.close)));
                                            }
                                        ),
                                      )
                                  ),
                                  Divider(),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      TextButton(
                                          onPressed: (){
                                            Navigator.pop(context);
                                            setState(() {
                                              this.visible = true;
                                            });
                                          },
                                          child: Text('关闭',
                                            style: TextStyle(
                                              fontSize: 18,
                                              color: Colors.black
                                            ),)
                                      )
                                    ],
                                  ),
                                  SizedBox(height: 10,)
                                ],
                              ),
                            );
                          });
                        }
                      },
                    ),
                  ],
                );
              },
            )));
  }
}
