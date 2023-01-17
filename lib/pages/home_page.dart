import 'package:flutter/material.dart';
import 'package:flutter_music_player/model/music_tag_info.dart';
import 'package:go_router/go_router.dart';
import '../common/Global.dart';
import 'package:flutter_music_player/api/provider/qq.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {

  final ScrollController _scrollController =  ScrollController();

  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  bool _hasMore = true;

  List<MusicTagInfo> _result = [];
  int _count = 0;
  int _page = 0;

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      print(_scrollController.offset);
      if(_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        _loadData(false);
      }
    });
    _page = 0;
    _hasMore = true;
    _loadData(true);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return DefaultTabController(
        initialIndex: 0,
        length: 2,
        child: Scaffold(
            appBar: AppBar(
              primary: true,
              toolbarTextStyle: const TextStyle(color: Colors.black),
              backgroundColor: Colors.white70,
              leading: const Center(
                child: Text('听海'),
              ),
              //centerTitle: true,
              title: const TextField(
                cursorColor: Colors.green,
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.all(10),
                  hintText: '输入歌曲名，歌手',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(4.0)),
                    gapPadding: 4,
                  ),

                ),

              ),
              actions: [
                IconButton(
                    icon: const Icon(Icons.menu_outlined),
                    color: Colors.black,
                    onPressed: () {
                      scaffoldKey.currentState!.openEndDrawer();
                    }
                )
              ],
              bottom: const TabBar(
                unselectedLabelColor: Colors.black54,
                labelColor: Colors.black,
                indicatorColor: Colors.black,
                tabs: [
                  Tab(
                    text: 'QQ',
                  ),
                  Tab(
                    text: '网易云',
                  )
                ],
              ),
            ),
            body: TabBarView(
              children: [
                Container(
                  child: _result.length < 1 ? _buildLoading() : _buildData(),
                ),
                Text('网易云')
              ],
            ),
            key: scaffoldKey,
            endDrawer: Drawer(
              width: screenWidth * 0.7,
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  DrawerHeader(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/green.png')
                      )
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'MUSIC',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                          ),
                        ),
                        Text(
                          '彪悍的人生是不需要解释的',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    )
                  ),
                  ListTile(
                    leading: Icon(Icons.account_circle),
                    title: Text('个人信息'),
                  ),
                  ListTile(
                    leading: Icon(Icons.settings),
                    title: Text('设置'),
                  ),
                  ListTile(
                    leading: Icon(Icons.info_outline),
                    title: Text('关于'),
                    trailing: Icon(Icons.navigate_next),
                  ),
                ],
              ),
            ),
           bottomSheet: Global.bottomPlayBar,
           /* floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
            floatingActionButton: Global.bottomPlayBar,*/

        )
    );
  }

  Future<void> _onRefresh() async {
    await Future.delayed(const Duration(milliseconds:2000),(){
      _loadData(true);
    });
  }

  void _loadData(init) async {
    if(init) {
      _page = 0;
      _hasMore = true;
    }
    if(_hasMore) {
      List<MusicTagInfo> res = await QQUtil.showPlaylist(_page);
      setState(() {
        if(res.length < 30) {
          _hasMore = false;
        }
        if(_page == 0) {
          _result = res;
          _count = res.length;
        } else {
          _result.addAll(res);
          _count += res.length;
        }
        _page++;
      });
    }
    print('获取数据，页数：${_page},总数：${_count}');
  }

  Widget _buildLoading() {
    return const Center(
      child: Text('加载中！！！'),
    );
  }
  //构建数据列表UI
  Widget _buildData() {

    return RefreshIndicator(
        onRefresh: _onRefresh,
        child: GridView.builder(
            controller: _scrollController,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, childAspectRatio: 11 / 18),
            primary: false,
            padding: const EdgeInsets.all(1),
            itemCount: _count,
            itemBuilder: (BuildContext context, int index) {
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
                            child: Image.network(_result[index].getCoverImgUrl,fit: BoxFit.cover,),
                          )
                      ),
                      Text(_result[index].getTitle,
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
                    context.go('/playList', extra: _result[index] );
                    /*Navigator.of(context).pushNamed('/playList', arguments: {
                      'musicTagInfo': _result[index]
                    });*/
                  },
                ),
              );
            })
    );

  }
}
