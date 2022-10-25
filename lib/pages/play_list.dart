import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_music_player/model/music_info.dart';
import 'package:flutter_music_player/model/music_tag_info.dart';
import 'package:flutter_music_player/api/provider/qq.dart';
import 'package:provider/provider.dart';
import 'package:flutter_music_player/common/state/music_play_state.dart';

import '../common/Global.dart';

class PlayList extends StatefulWidget {

  final arguments;

  PlayList({Key? key,this.arguments}) : super(key: key);

  @override
  State<PlayList> createState() => _PlayListState(arguments);
}

class _PlayListState extends State<PlayList> {

  final arguments;

  late MusicTagInfo musicTagInfo;

  late List<MusicInfo> tracks;

  MusicTagInfo? tagInfo;

  late MusicPlayState musicPlayState;

  _PlayListState(this.arguments);

  MusicTagInfo covertModel() {
    return arguments['musicTagInfo'];
  }

  void printResult(values) {
    setState(() {
      tracks = values['tracks'];
      tagInfo = values['info'];
    });
  }



  @override
  Widget build(BuildContext context) {

    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth  = MediaQuery.of(context).size.width;
    
    if(tagInfo == null) {
      return Scaffold(
        body: Center(
          child: Text('加载中...'),
        ),
      );
    }
    musicPlayState = Provider.of(context);

    return Scaffold(
      // appBar: AppBar(
      //   title: Text(musicTagInfo.getTitle),
      // ),
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool b) {
          return [
            SliverAppBar(
              pinned: true,
              floating: true,
              expandedHeight: screenHeight * 0.4,
              backgroundColor: Colors.blueGrey,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(musicTagInfo.getTitle),
                centerTitle: true,
                background: Image.network(musicTagInfo.getCoverImgUrl,fit: BoxFit.cover),
              ),
            ),
          ];
        },
        body: ListView.builder(
            padding: EdgeInsets.zero,
            primary: true,
            shrinkWrap: true,
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: (tracks.length + 1),
            itemBuilder: (BuildContext context, int index) {
              if(index == 0) {
                return Container(
                  color: Colors.white30,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                          icon: Icon(
                            Icons.not_started_rounded,
                            size: 28,
                            color: Colors.green,
                          ),
                          onPressed: (){}
                      ),
                      TextButton(
                        child: Text(
                          '全部播放(${tracks.length})',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                          ),
                        ),
                        onPressed: (){
                          musicPlayState.playAll(tracks);
                        },
                      ),
                    ],
                  ),
                );
              } else {
                return ListTile(
                    leading: Text((index).toString()),
                    title: Text(tracks[index-1].getTitle, style:
                      TextStyle(
                        color: tracks[index-1].getDisabled ? Colors.red : Colors.black
                      ),
                    ),
                    subtitle: Text(tracks[index-1].getArtist),
                    trailing: IconButton(
                        onPressed: (){
                          musicPlayState.playNewMusic(tracks[index-1]);
                        },
                        icon: Icon(Icons.not_started_outlined)
                    )
                );
              }
            }
        ),
      ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: Global.bottomPlayBar,
    );
  }
  

  
  @override
  void initState() {
    super.initState();
    musicTagInfo = covertModel();
    QQUtil.getPlaylist(musicTagInfo.getId).then((value){
      printResult(value);
    });
  }

}
