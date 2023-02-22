import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_music_player/common/state/bottom_play_bar_state.dart';
import 'package:flutter_music_player/model/music_info.dart';
import 'package:flutter_music_player/model/music_tag_info.dart';
import 'package:flutter_music_player/api/provider/qq.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_music_player/common/state/music_play_state.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../api/client.dart';
import '../api/client_factory.dart';
import '../common/Global.dart';

class PlayList extends StatefulWidget {

  late MusicTagInfo musicTagInfo;

  PlayList(Object? musicTagInfo, {Key? key}) : super(key:key) {
    this.musicTagInfo =  musicTagInfo as MusicTagInfo;
  }

  @override
  State<PlayList> createState() => _PlayListState(musicTagInfo);
}

class _PlayListState extends State<PlayList> {

  late MusicTagInfo musicTagInfo;

  late List<MusicInfo> tracks;

  MusicTagInfo? tagInfo;

  late BottomPlayBarState bottomPlayBarState;

  late MusicPlayState musicPlayState;

  _PlayListState(this.musicTagInfo);

  void printResult(values) {
    setState(() {
      tracks = values['tracks'];
      tagInfo = values['info'];
    });
    //log(values['tracks'].toString());
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

    bottomPlayBarState = BottomPlayBarState.of(context);

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
                    leading: tracks[index-1].getImgUrl.isEmpty ? Image.asset('assets/lady.jpeg',fit: BoxFit.fill,width: screenWidth*0.12, height: screenHeight*0.05,) : Image.network(tracks[index-1].getImgUrl,fit: BoxFit.fill, width: screenWidth*0.12, height: screenHeight*0.05,),
                    textColor: Colors.black,
                    title: Text(tracks[index-1].getTitle),
                    subtitle: Text('${tracks[index-1].getArtist} - ${tracks[index-1].getAlbum}',maxLines: 1, overflow: TextOverflow.ellipsis,),
                    trailing: IconButton(
                        onPressed: (){

                          bottomPlayBarState.hideBottomPlayBar();

                          showModalBottomSheet(context: context, builder: (BuildContext context) {
                            return Container(
                              height: screenHeight * 0.4,
                              color: Colors.white,
                              child: Column(
                                children: [
                                  ListTile(
                                    contentPadding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                    title: Text(tracks[index-1].getTitle),
                                  ),
                                  Divider(color: Colors.black,),
                                  Expanded(
                                      child: Scrollbar(
                                        child: ListView(
                                          padding: EdgeInsets.zero,
                                          children: [
                                            ListTile(
                                              leading: Icon(Icons.play_circle),
                                              contentPadding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                                              title: Text('下一首播放'),
                                              onTap: () {
                                                // 点击加入下一首播放列表
                                              },
                                            ),
                                            ListTile(
                                              leading: Icon(Icons.playlist_add),
                                              contentPadding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                                              title: Text('收藏到歌单'),
                                            ),
                                            ListTile(
                                              leading: Icon(Icons.person),
                                              contentPadding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                                              title: Text('歌手：${tracks[index-1].getArtist}'),
                                            ),
                                            ListTile(
                                              leading: Icon(Icons.album),
                                              contentPadding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                                              title: Text('专辑：${tracks[index-1].getAlbum}'),
                                            ),
                                          ],
                                        ),
                                      )
                                  ),
                                ],
                              ),
                            );
                          }).then((value) => bottomPlayBarState.showBottomPlayBar());

                        },
                        icon: Icon(Icons.more_vert)
                    ),
                    onTap: () {
                      musicPlayState.playNewMusic(tracks[index-1]);
                      /*if(tracks[index-1].getDisabled) {
                        Fluttertoast.showToast(
                          msg: "平台版权原因无法播放，请尝试其他平台",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.CENTER,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.black87,
                          textColor: Colors.white70,
                        );
                      } else {
                        musicPlayState.playNewMusic(tracks[index-1]);
                      }*/
                    },
                );
              }
            }
        ),
      ),
      bottomSheet: Global.bottomPlayBar,
    );
  }
  

  
  @override
  void initState() {
    super.initState();
    //musicTagInfo = covertModel();
    Client client = ClientFactory.getFactory(musicTagInfo.getId.substring(0,2));
    client.getPlaylist(musicTagInfo.getId).then((value){
      printResult(value);
    });
  }

}


/*
*
*
*
* {_id: qqtrack_000WjZVc1HXBrs, _title: 故事随时间慷慨, _artist: 毛正安, _artistId: qqartist_000oNmuT1SQUPt, _album: 故事随时间慷慨, _albumId: qqalbum_003PIvrw2oFVkt,
* _imgUrl: http://imgcache.qq.com/music/photo/mid_album_300/k/t/003PIvrw2oFVkt.jpg,
* _source: qq, _sourceUrl: http://y.qq.com/#type=song&mid=000WjZVc1HXBrs&tpl=yqq_song_detail, _url: qqtrack_000WjZVc1HXBrs, _disabled: false}
* */