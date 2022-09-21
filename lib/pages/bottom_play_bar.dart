import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class BottomPlayBar extends StatefulWidget {
  const BottomPlayBar({Key? key}) : super(key: key);

  @override
  State<BottomPlayBar> createState() => _BottomPlayBarState();
}

class _BottomPlayBarState extends State<BottomPlayBar> {

  late AudioPlayer audioPlayer;

  bool isPlaying = false;

  bool isPaused = false;

  bool isLoop = false;

  Duration _duration = Duration();

  Duration? _position = Duration.zero;

  late AssetSource source;

  var _icons = [
    FontAwesomeIcons.play,
    FontAwesomeIcons.pause
  ];

  @override
  void initState() {
    super.initState();
    audioPlayer = AudioPlayer();
    //source = AssetSource("love.mp3")
    _setListener();
    _setSource();
  }

  _setSource() async {
    audioPlayer.setPlaybackRate(1);
    await audioPlayer.setSourceAsset("love.mp3");
  }

  _setListener() {
    // 播放完成
    audioPlayer.onPlayerComplete.listen((event){
      setState(() {
        isPlaying = false;
        _position = Duration.zero;
        audioPlayer.release();
      });

      //下一首
    });
    //监听时长
    audioPlayer.onDurationChanged.listen((d) {
      setState(() {
        _duration = d;
      });
    });

    //监听进度
    audioPlayer.onPositionChanged.listen((p) {
      setState(() {
        _position = p;
      });
    });


  }

  _resume() async {
    await audioPlayer.resume();
  }

  _pause() async {
    await audioPlayer.pause();
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4),
      height: MediaQuery.of(context).size.height * 0.07,
      child: AppBar(
        backgroundColor: Colors.blueGrey,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)
        ),
        leading: InkWell(
          child: CircleAvatar(
            radius: 20,
            backgroundImage: AssetImage("assets/lady.jpeg"),
          ),
        ),
        title: TextButton(
          child: Text(
              '爱要怎么说出口 - 赵传',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white
            ),
          ),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: isPlaying == false ? FaIcon(_icons[0]) : FaIcon(_icons[1]),
            onPressed: () {
              if(this.isPlaying == false) {
                _resume();
                setState(() {
                  this.isPlaying = true;
                });
              } else if(this.isPlaying == true) {
                _pause();
                setState(() {
                  this.isPlaying = false;
                });
              }
            },
          ),
          IconButton(
              onPressed: (){},
              icon: FaIcon(FontAwesomeIcons.outdent)
          ),
        ],
      )
    );
  }
}
