import 'package:flutter/material.dart';
import 'package:simple_video_player_example/mult/mult_video_manager.dart';
import 'package:simple_video_player_example/mult/mult_video_widget.dart';
import 'package:visibility_detector/visibility_detector.dart';

import 'mock_data.dart';

void main() => runApp(const VideoPlayerApp());

class VideoPlayerApp extends StatelessWidget {
  const VideoPlayerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video Player Demo',
      home: Scaffold(
        body: FeedPlayerDemo(),
      ),
    );
  }
}

class FeedPlayerDemo extends StatefulWidget {
  FeedPlayerDemo({Key? key}) : super(key: key);

  @override
  _FeedPlayerState createState() => _FeedPlayerState();
}

class _FeedPlayerState extends State<FeedPlayerDemo> {
  List items = mockData['items'];

  late MultiVideoManager multiManager;
  late ScrollController controller;

  @override
  void initState() {
    super.initState();
    multiManager = MultiVideoManager();
    controller = ScrollController()..addListener(() {});
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: ObjectKey(multiManager),
      onVisibilityChanged: (visibility) {
        multiManager.autoPlay();
        if (visibility.visibleFraction == 0 && this.mounted) {
          multiManager.pause();
        }
      },
      child: NotificationListener(
        onNotification: (notification) {
          if (notification is ScrollStartNotification) {
            // print('----------ScrollStartNotification------');
          } else if (notification is ScrollUpdateNotification) {
          } else if (notification is ScrollEndNotification) {
            // print('----------ScrollEndNotification------');
            multiManager.autoPlay();
          }
          return false;
        },
        child: ListView.separated(
          controller: controller,
          cacheExtent: 1.0,
          separatorBuilder: (context, int) => Container(
            height: 20,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            return Container(
                height: 230,
                margin: EdgeInsets.all(2),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: MultiVideoPlayerWidget(
                    index: index,
                    url: items[index]['trailer_url'],
                    multiVideoManager: multiManager,
                    image: items[index]['image'],
                  ),
                ));
          },
        ),
      ),
    );
  }
}
