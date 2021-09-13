import 'package:flutter/material.dart';
import 'package:simple_video_player/simple_video_player.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

import 'mult_video_manager.dart';

class MultiVideoPlayerWidget extends StatefulWidget {
  late String url;
  int? index;
  late MultiVideoManager multiVideoManager;
  String? image;

  MultiVideoPlayerWidget(
      {required this.url,
      required this.multiVideoManager,
      this.image,
      this.index});

  @override
  State<StatefulWidget> createState() => _StateMultiVideoPlayerWidget();
}

class _StateMultiVideoPlayerWidget extends State<MultiVideoPlayerWidget> {
  late VideoManager videoManager;

  @override
  void initState() {
    videoManager = VideoManager(
        index: widget.index!,
        thumImage: widget.image,
        isFeed: true,
        videoPlayerController: VideoPlayerController.network(widget.url));
    widget.multiVideoManager.init(videoManager);
    super.initState();
  }

  @override
  void dispose() {
    widget.multiVideoManager.remove(videoManager);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: ObjectKey(videoManager),
      onVisibilityChanged: (visiblityInfo) {
        if (visiblityInfo.visibleFraction == 1.0) {
          widget.multiVideoManager.addData(videoManager);
        } else {
          widget.multiVideoManager.removeData(videoManager);
        }
      },
      child: Container(
        width: double.infinity,
        height: 230,
        child: VideoPlayerWidget(
            videoManager: videoManager,
            videoWithControls: FeedVideoPlayerWithControlWidget(
              controls: VideoControlWidget(videoManager: videoManager),
            )),
      ),
    );
  }
}
