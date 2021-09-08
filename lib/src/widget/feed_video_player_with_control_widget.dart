import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_video_player/src/util/play_state.dart';
import 'package:simple_video_player/src/util/video_control_util.dart';
import 'package:video_player/video_player.dart';

import '../manager/video_manager.dart';
import '../native_video_player.dart';

class FeedVideoPlayerWithControlWidget extends StatefulWidget {
  const FeedVideoPlayerWithControlWidget({
    Key? key,
    this.controls,
    this.videoFit = BoxFit.cover,
    this.playerLoadingFallback = const Center(
      child: CircularProgressIndicator(),
    ),
    this.playerErrorFallback = const Center(
      child: const Icon(
        Icons.error,
        color: Colors.white,
      ),
    ),
    this.backgroundColor = Colors.black,
    this.iconThemeData = const IconThemeData(
      color: Colors.white,
      size: 20,
    ),
    this.textStyle = const TextStyle(
      color: Colors.white,
      fontSize: 12,
    ),
    this.aspectRatioWhenLoading = 16 / 9,
    this.willVideoPlayerControllerChange = true,
  }) : super(key: key);

  /// Conditionally rendered if player is not initialized.
  final Widget playerLoadingFallback;

  /// Conditionally rendered if player is has errors.
  final Widget playerErrorFallback;

  /// Property passed to [FlickVideoPlayer]
  final BoxFit videoFit;
  final Color backgroundColor;

  /// Used in [DefaultTextStyle]
  ///
  /// Use this property if you require to override the text style provided by the default Flick widgets.
  ///
  /// If any text style property is passed to Flick Widget at the time of widget creation, that style wont be overridden.
  final TextStyle textStyle;

  /// Used in [IconTheme]
  ///
  /// Use this property if you require to override the icon style provided by the default Flick widgets.
  ///
  /// If any icon style is passed to Flick Widget at the time of widget creation, that style wont be overridden.
  final IconThemeData iconThemeData;

  /// If [FlickPlayer] has unbounded constraints this aspectRatio is used to take the size on the screen.
  ///
  /// Once the video is initialized, video determines size taken.
  final double aspectRatioWhenLoading;

  /// If false videoPlayerController will not be updated.
  final bool willVideoPlayerControllerChange;

  //video play control widget
  final Widget? controls;

  @override
  State<StatefulWidget> createState() =>
      _StateFeedVideoPlayerWithControlWidget();
}

class _StateFeedVideoPlayerWithControlWidget
    extends State<FeedVideoPlayerWithControlWidget> {
  VideoPlayerController? _videoPlayerController;

  @override
  void didChangeDependencies() {
    VideoPlayerController? newController =
        Provider.of<VideoManagerModel>(context).videoPlayerController;
    if ((widget.willVideoPlayerControllerChange &&
            _videoPlayerController != newController) ||
        _videoPlayerController == null) {
      _videoPlayerController = newController;
    }

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<VideoManagerModel, ViewManagetModel>(
        builder: (context, videoModel, viewModel, child) {
      return GestureDetector(
          onTap: () {
            viewModel.handleTapVideo();
          },
          onLongPressStart: (detail) {
            videoModel.setPlaybackSpeed(2.0);
          },
          onLongPressEnd: (detail) {
            videoModel.setPlaybackSpeed(1.0);
          },
          onHorizontalDragStart: videoModel.isFullscreen
              ? (v) => {
                    viewModel.dragPosition(
                        DragState.HORIZONTAL_START, v.localPosition),
                  }
              : null,
          onHorizontalDragUpdate: videoModel.isFullscreen
              ? (v) => {
                    viewModel.dragPosition(
                        DragState.HORIZONTAL_UPDATE, v.localPosition)
                  }
              : null,
          onHorizontalDragEnd: videoModel.isFullscreen
              ? (v) => {
                    viewModel.dragPosition(
                        DragState.HORIZONTAL_END, Offset.zero)
                  }
              : null,
          onVerticalDragStart: videoModel.isFullscreen
              ? (v) => {
                    viewModel.dragPosition(
                        DragState.VERTICAL_START, v.localPosition)
                  }
              : null,
          onVerticalDragUpdate: videoModel.isFullscreen
              ? (v) => {
                    viewModel.dragPosition(
                        DragState.VERTICAL_UPDATE, v.localPosition)
                  }
              : null,
          onVerticalDragEnd: videoModel.isFullscreen
              ? (v) =>
                  {viewModel.dragPosition(DragState.VERTICAL_END, Offset.zero)}
              : null,
          child: IconTheme(
              data: widget.iconThemeData,
              child: LayoutBuilder(builder: (context, size) {
                return Container(
                    color: widget.backgroundColor,
                    child: DefaultTextStyle(
                      style: widget.textStyle,
                      child: Stack(children: <Widget>[
                        Center(
                          child: NativeVideoPlayer(
                            videoPlayerController:
                                videoModel.videoPlayerController,
                            fit: widget.videoFit,
                            aspectRatioWhenLoading:
                                widget.aspectRatioWhenLoading,
                          ),
                        ),
                        Positioned.fill(
                          child: Stack(
                            children: <Widget>[
                              if (videoModel.videoPlayerValue!.hasError ==
                                      false &&
                                  videoModel.playState == PlayState.prepare)
                                widget.playerLoadingFallback,
                              if (videoModel.videoPlayerValue!.hasError == true)
                                widget.playerErrorFallback,
                              widget.controls ?? Container(),
                            ],
                          ),
                        ),
                      ]),
                    ));
              })));
    });
  }
}
