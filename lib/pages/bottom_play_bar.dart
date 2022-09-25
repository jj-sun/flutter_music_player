import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_music_player/common/state/music_play_state.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class BottomPlayBar extends StatefulWidget {
  const BottomPlayBar({Key? key}) : super(key: key);

  @override
  State<BottomPlayBar> createState() => _BottomPlayBarState();
}

class _BottomPlayBarState extends State<BottomPlayBar> {

  late MusicPlayState musicPlayState;

  var _icons = [
    FontAwesomeIcons.play,
    FontAwesomeIcons.pause
  ];


  @override
  void initState() {
    super.initState();
    musicPlayState = MusicPlayState.of(context);
  }

  Object _images(obj) {
    return obj == null ? AssetImage('') : NetworkImage(musicPlayState.currentMusicInfo?.getImgUrl);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4),
      height: MediaQuery.of(context).size.height * 0.07,
      child: Selector<MusicPlayState,PlayerState>(
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
                borderRadius: BorderRadius.circular(20)
            ),
            leading: InkWell(
              child: CircleAvatar(
                radius: 20,
                backgroundImage: AssetImage('assets/lady.jpeg'),
              ),
            ),
            title: TextButton(
              child: Text(
                '${musicPlayState.currentMusicInfo?.getTitle} - ${musicPlayState.currentMusicInfo?.getArtist}',
                style: TextStyle(
                    fontSize: 14,
                    color: Colors.white
                ),
              ),
              onPressed: () {},
            ),
            actions: [
              IconButton(
                icon: audioState == PlayerState.playing ? FaIcon(_icons[1]) : FaIcon(_icons[0]),
                onPressed: () {
                  print(audioState);
                  if(audioState == PlayerState.paused) {
                    musicPlayState.musicPlay();
                  } else if(audioState == PlayerState.playing) {
                    musicPlayState.musicPause();
                  }
                },
              ),
              IconButton(
                  onPressed: (){},
                  icon: FaIcon(FontAwesomeIcons.outdent)
              ),
            ],
          );
        },
      )
    );
  }
}
