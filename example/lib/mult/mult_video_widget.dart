
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../simple_video_player.dart';

class MultiVideoPlayerWidget extends StatefulWidget{

  late String url;
  MultiVideoPlayerWidget({required this.url});

  @override
  State<StatefulWidget> createState()=>_StateMultiVideoPlayerWidget();

}

class _StateMultiVideoPlayerWidget extends State<MultiVideoPlayerWidget>{
  late VideoManager videoManager;
  @override
  void initState() {
    videoManager=VideoManager(videoPlayerController: VideoPlayerController.network(dataSource));
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: ObjectKey(),
      onVisibilityChanged: (visibilityInfo){

      },
    );
  }

}