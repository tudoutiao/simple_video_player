import 'package:flutter/material.dart';
import 'package:simple_video_player/simple_video_player.dart';
import 'package:video_player/video_player.dart';


void main() {
  runApp(const MyVideoPlayerDemo());
}

class MyVideoPlayerDemo extends StatelessWidget {
  const MyVideoPlayerDemo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Video Player Demo',
      home: Scaffold(
        backgroundColor: Color.fromRGBO(246, 245, 250, 1),
        body: SafeArea(child: VideoPlayerPage()),
      ),
    );
  }
}

class VideoPlayerPage extends StatefulWidget {
  const VideoPlayerPage({
    Key? key,
  }) : super(key: key);

  @override
  _VideoPlayerPageState createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  late VideoManager videoManager;

  @override
  void initState() {
    super.initState();
    videoManager = VideoManager(
        videoPlayerController: VideoPlayerController.network(
      'http://img3.chouti.com/f6f8c2f4-dd30-4032-930a-31358e5e6305.mp4',
    ));
  }

  @override
  void dispose() {
    super.dispose();
    videoManager.videoManagerModel.pause();
  }

  @override
  Widget build(BuildContext context) {
    videoManager.setScreenSize(context);
    return Container(
        child: Column(
      children: [
        Container(
          width: double.infinity,
          height: 200,
          child: VideoPlayerWidget(
              videoManager: videoManager,
              videoWithControls: VideoPlayerWithControlWidget(
                controls:VideoControlWidget(videoManager: videoManager),
              )),
        ),
      ],
    ));
  }
}
