import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'base_test.dart';
import 'feed_player.dart';
import 'my_video_test.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with AutomaticKeepAliveClientMixin {
  final arr = ["MyVideo", "Feeds"];

  @override
  bool get wantKeepAlive => true;

  TabController? tabController;
  late ValueNotifier<int> valueNotifier;

  @override
  void initState() {
    valueNotifier = ValueNotifier(0);
    super.initState();
  }

  @override
  void dispose() {
    valueNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableProvider<int>.value(
      value: valueNotifier,
      child: DefaultTabController(
        length: arr.length,
        initialIndex: valueNotifier.value,
        child: Builder(
          builder: (context) {
            if (tabController == null) {
              tabController = DefaultTabController.of(context);
              tabController!.addListener(() {
                valueNotifier.value = tabController!.index;
              });
            }
            return Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.white,
                title: Container(
                  child: Container(
                    child: Center(
                      child: _appBarView(),
                    ),
                  ),
                ),
              ),
              body: TabBarView(
                children: arr.map((e) {
                 if (e == arr[0]) {
                    return Center(
                      child: VideoPlayerPage(),
                    );
                  } else {
                    return Center(
                      child: FeedPlayerDemo(),
                    );
                  }
                }).toList(),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _appBarView() {
    return TabBar(
        tabs: arr.map((e) {
          return Tab(
            child: Text(e),
          );
        }).toList(),
        indicatorColor: Colors.black,
        indicatorSize: TabBarIndicatorSize.label,
        isScrollable: true,
        labelColor: Colors.black,
        unselectedLabelColor: Colors.grey[400],
        labelStyle: TextStyle(height: 2));
  }
}
