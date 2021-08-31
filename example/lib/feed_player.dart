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
    return  MaterialApp(
      title: 'Video Player Demo',
      home: Scaffold (
        body: FeedPlayer(),
      ),
    );
  }
}

class FeedPlayer extends StatefulWidget {
  FeedPlayer({Key? key}) : super(key: key);

  @override
  _FeedPlayerState createState() => _FeedPlayerState();
}

class _FeedPlayerState extends State<FeedPlayer> {
  List items = mockData['items'];

  late MultiVideoManager multiManager;

  @override
  void initState() {
    super.initState();
    multiManager = MultiVideoManager();
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: ObjectKey(multiManager),
      onVisibilityChanged: (visibility) {
        if (visibility.visibleFraction == 0 && this.mounted) {
          multiManager.pause();
        }
      },
      child: Container(
        child: ListView.separated(
          separatorBuilder: (context, int) => Container(
            height: 50,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            return Container(
                height: 200,
                margin: EdgeInsets.all(2),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child:
                  // Text("===${items[index]['trailer_url']}===="),
                  MultiVideoPlayerWidget(
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
