import 'package:flutter/material.dart';
import 'package:flutter_music_player/model/music_tag_info.dart';
import '../common/Global.dart';
import 'package:flutter_music_player/api/provider/qq.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  
  late TabController _tabController;

  Future<List<MusicTagInfo>> _result = QQUtil.showPlaylist(0);

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
                  child: FutureBuilder(
                    future: _result,
                    builder: (BuildContext context, AsyncSnapshot<List<MusicTagInfo>> snapshot) {
                      var widget;
                      if(snapshot.connectionState == ConnectionState.done) {
                        if(snapshot.hasData) {
                          widget = _buildData(snapshot.data);
                        } else {
                          widget = Container(
                            child: Text('数据加载错误！'),
                          );
                        }
                      } else {
                        widget = Container(
                          child: Text('数据加载中...！'),
                        );
                      }
                      return widget;
                    },
                  ),
                ),
                Text('网易云')
              ],
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Global.bottomPlayBar
    );
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  //构建数据列表UI
  Widget _buildData(List<MusicTagInfo>? result) {
    if(result == null) {
      return Container(
        child: Text('暂无数据！'),
      );
    } else {
      return GridView.builder(
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
                  if(result[index] != null) {
                    Navigator.of(context).pushNamed('/playList', arguments: {
                      'musicTagInfo': result[index]
                    });
                  }
                },
              ),
            );
          }
      );
    }

  }
}
