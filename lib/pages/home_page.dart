
import 'package:flutter/material.dart';
import 'package:flutter_music_player/api/client.dart';
import 'package:flutter_music_player/api/client_factory.dart';
import 'package:flutter_music_player/model/music_tag_info.dart';
import 'package:go_router/go_router.dart';
import '../common/Global.dart';
import 'package:flutter_music_player/api/provider/qq.dart';
import 'dart:developer';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {

  static const List<Tab> myTabs = <Tab>[
       Tab(key: Key('qq'),text: 'QQ'),
       Tab(key: Key('ne'),text: '网易云'),
     ];
  static const List<String> platformIds = ['qq','ne'];

  late TabController _tabController;

  final ScrollController _scrollController = ScrollController();

  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  bool _hasMore = true;

  List<MusicTagInfo> _result = [];
  int _page = 0;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(vsync: this, length: myTabs.length);

    _tabController.addListener(() {
      //log('Tab Index：${_tabController.index}');
      if(_tabController.indexIsChanging){
        log('Tab Index：${_tabController.index}');
        _loadData(true);
      }
    });

    _scrollController.addListener(() {
      //print(_scrollController.offset);
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _loadData(false);
      }
    });

    _page = 0;
    _hasMore = true;
    _loadData(true);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        primary: true,
        toolbarTextStyle: const TextStyle(color: Colors.black),
        backgroundColor: Colors.white70,
        leading: const Center(
          child: Text('辞盈'),
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
              })
        ],
        bottom: TabBar(
          controller: _tabController,
          unselectedLabelColor: Colors.black54,
          labelColor: Colors.black,
          indicatorColor: Colors.black,
          tabs: myTabs,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          Container(
            child: _result.length < 1 ? _buildLoading() : _buildData(),
          ),
          Container(
            child: _result.length < 1 ? _buildLoading() : _buildData(),
          )
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
                        image: AssetImage('assets/green.png'))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '辞盈',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                      ),
                    ),
                    Text(
                      '山不让尘，川不辞盈',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ],
                )),
            ListTile(
              leading: Icon(Icons.account_circle),
              title: Text('备份'),
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('恢复'),
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
    );
  }

  Future<void> _onRefresh() async {
    await Future.delayed(const Duration(milliseconds: 2000), () {
      _loadData(true);
    });
  }

  void _loadData(init) async {
    if (init) {
      _page = 0;
      _hasMore = true;
    }
    if (_hasMore) {
      Client client = ClientFactory.getFactory(platformIds[_tabController.index]);
      List<MusicTagInfo> res = await client.showPlaylist(_page);
      setState(() {
        if (res.length < 30) {
          _hasMore = false;
        }
        if (_page == 0) {
          _result = res;
          _page = res.length;
        } else {
          _result.addAll(res);
          _page += res.length;
        }
      });
    }
    print('获取数据，偏移量：${_page},总数：${_result.length}');
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
            itemCount: _result.length,
            itemBuilder: (BuildContext context, int index) {
              return Container(
                color: Colors.white,
                child: TextButton(
                  child: Column(
                    children: [
                      AspectRatio(
                          aspectRatio: 7 / 9,
                          child: Container(
                            clipBehavior: Clip.hardEdge,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            //child: Image.asset('assets/lady.jpeg'),
                            child: Image.network(
                              _result[index].getCoverImgUrl,
                              fit: BoxFit.cover,
                            ),
                          )),
                      Text(
                        _result[index].getTitle,
                        style: TextStyle(fontSize: 14, color: Colors.black),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      )
                    ],
                  ),
                  onPressed: () {
                    context.go('/playList', extra: _result[index]);
                    /*Navigator.of(context).pushNamed('/playList', arguments: {
                      'musicTagInfo': _result[index]
                    });*/
                  },
                ),
              );
            }));
  }
}
