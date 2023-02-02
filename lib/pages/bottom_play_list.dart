import 'package:flutter/material.dart';
import 'package:flutter_music_player/common/enums/music_mode_enum.dart';
import 'package:provider/provider.dart';

import '../common/state/music_play_state.dart';
import '../model/music_info.dart';

class BottomPlayList extends StatefulWidget {

  const BottomPlayList({Key? key}) : super(key: key);

  @override
  State<BottomPlayList> createState() => _BottomPlayListState();

}

class _BottomPlayListState extends State<BottomPlayList> {

  late MusicPlayState musicPlayState = MusicPlayState.of(context);

  final ScrollController _scrollController = ScrollController();


  @override
  void initState() {

    super.initState();

    _scrollController.addListener(() {
      print('dsss: ${_scrollController.offset}');
      print('wwww: ${_scrollController.position}');
      /*if(_scrollController.offset > 5) {
        _scrollController.jumpTo(20);
      }*/
    });
  }



  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth  = MediaQuery.of(context).size.width;

    var modeIcons = [Icons.repeat, Icons.shuffle, Icons.repeat_one];


    List<MusicInfo> musicInfoList =
        musicPlayState.currentPlayList;

    return Container(
      height: screenHeight * 0.75,
      color: Colors.white,
      child: Column(
        children: [
          Selector<MusicPlayState, int>(
            selector: (context, state) {
              return state.musicModeIndex;
            },
            shouldRebuild: (pre, next) {
              return pre != next;
            },
            builder: (context, musicModeIndex, child) {
              return ListTile(
                leading: Icon(modeIcons[musicPlayState.musicModeIndex], color: Colors.black,),
                title: Text('播放列表(${musicInfoList.length}首)'),
                onTap: () {
                  musicPlayState.changeMusicMode();
                }
              );
            },
          ),
          const Divider(),
          Expanded(
              child: Scrollbar(
                controller: _scrollController,
                child: Selector<MusicPlayState, String>(
                  selector: (context, state) {
                    return state.currentPlayId;
                  },
                  shouldRebuild: (pre, next){
                    return pre != next;
                  },
                  builder: (context, currentPlayId, child) {
                    return ListView.builder(
                        //controller: _scrollController,
                        padding: EdgeInsets.zero,
                        primary: true,
                        shrinkWrap: true,
                        itemCount: musicInfoList.length,
                        itemExtent: screenHeight * 0.09,
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
  }

}