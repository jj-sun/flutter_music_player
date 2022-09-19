import 'package:flutter/material.dart';
import 'package:flutter_music_player/model/music_tag_info.dart';
import 'bottom_play_bar.dart';
import 'package:flutter_music_player/api/provider/qq.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  
  late TabController _tabController;

  late List<MusicTagInfo> result = [];

  void initPlayList() {
    setState(() {
      QQUtil.showPlaylist(0).then((value) => {
        result = value.values.first
      });
    });
  }
  
  @override
  Widget build(BuildContext context) {

    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth  = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        leading: const Center(
          child: Text('MUSIC'),
        ),
        title: TextField(
            decoration: InputDecoration(
              hintText: '输入歌曲名，歌手',
              border: OutlineInputBorder()
            ),
        ),
        actions: [
          IconButton(
              icon: Icon(Icons.menu_outlined),
              onPressed: (){}
          )
        ],
      ),
      body: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Expanded(
                  child: TabBar(
                    controller: _tabController,
                    tabs: const [
                      Tab(text: 'QQ',),
                      Tab(text: '网易云',)
                    ],
                  )
              )
            ],
          ),
        ),
        body: Stack(
          children: [
            TabBarView(
              controller: _tabController,
              children: [
                Container(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 11/18
                    ),
                    primary: false,
                    padding: const EdgeInsets.all(1),
                    itemCount: result.length,
                    itemBuilder: (BuildContext context, int index){
                      return Container(
                          color: Colors.white,
                          child: TextButton(
                            child: Column(
                              children: [
                                AspectRatio(
                                    aspectRatio: 7/9,
                                    child: Container(
                                      clipBehavior: Clip.hardEdge,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      //child: Image.asset('assets/lady.jpeg'),
                                      child: Image.network(result[index].getCoverImgUrl,fit: BoxFit.cover,),
                                    )
                                ),
                                Text(result[index].getTitle,
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                )
                              ],
                            ),
                            onPressed: () {
                              print(result[index].getId);
                              if(result[index] != null) {
                                Navigator.of(context).pushNamed('/playList', arguments: {
                                  'musicTagInfo': result[index]
                                });
                              }

                            },
                          ),
                        );
                    }
                  )
                ),
                Text('网易云')
              ],
            ),
            // Positioned(
            //   left: 5,
            //   right: 5,
            //   bottom: 5,
            //   child: BottomPlayBar()
            // )
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: BottomPlayBar()
    );
  }

  @override
  void initState() {
    super.initState();
    _tabController = new TabController(length: 2, vsync: this);
    _tabController.addListener(() { 
      print(_tabController.index);
      if(_tabController.index == 0) {
       initPlayList();
      }

    });

  }
}
