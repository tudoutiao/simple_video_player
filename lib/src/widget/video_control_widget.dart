import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:simple_video_player/src/manager/video_manager.dart';
import 'package:simple_video_player/src/util/play_state.dart';

import 'anim/auto_hide_widget.dart';
import 'play_progress.dart';
import 'progress_bar_settings.dart';
import 'vertical_progress.dart';

class VideoControlWidget extends StatefulWidget {
  VideoManager? _videoManager;

  VideoControlWidget({@required VideoManager? videoManager})
      : this._videoManager = videoManager;

  @override
  State<StatefulWidget> createState() => _VideoControlWidgetState();
}

class _VideoControlWidgetState extends State<VideoControlWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ViewManagetModel, VideoManagerModel>(
        builder: (context, viewModel, videoModel, child) {
      return AutoHideChild(
          child: Stack(
        children: [
          if (viewModel.isShowThum)
            Positioned.fill(
              child: Image.asset(
                widget._videoManager!.thumImage,
                fit: BoxFit.cover,
              ),
            ),
          Positioned(
              child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (viewModel.isShowBack)
                IconButton(
                  padding: EdgeInsets.all(1),
                  iconSize: 18,
                  icon: Icon(
                    Icons.arrow_back_ios,
                    semanticLabel: "back",
                  ),
                  onPressed: () {},
                ),
              if (viewModel.isShowTitle)
                Padding(
                  padding: EdgeInsets.only(top: 5, left: 5),
                  child: Text(
                    "第${widget._videoManager!.index}个",
                    style: TextStyle(fontSize: 15),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              Container(
                margin: EdgeInsets.only(right: 15),
                child: Row(
                  children: [
                    if (viewModel.isSpeedPlaying) Text("2x"),
                    if (viewModel.isDragPosition) Text("draging"),
                  ],
                ),
              )
            ],
          )),
          if (viewModel.isShowPlayButton)
            Container(
              alignment: Alignment.center,
              child: IconButton(
                iconSize: 30,
                icon: Icon(
                  viewModel.isPlaying
                      ? Icons.pause
                      : (videoModel.playState == PlayState.complete
                          ? Icons.replay
                          : Icons.play_arrow),
                  semanticLabel: "play/pause/replay",
                ),
                onPressed: () {
                  videoModel.togglePlay();
                },
              ),
            ),
          if (viewModel.isDragBrightness)
            Positioned(
                left: 15,
                bottom: viewModel.getSliderBottome(),
                top: 60,
                child: Container(
                  // color: Colors.red,
                  width: 5,
                  // height: 100,
                  child: VierticalProgressWidget(
                    flickProgressBarSettings: FlickProgressBarSettings(
                      height: 5,
                      handleRadius: 5,
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 8,
                      ),
                      getPlayedPaint: (
                          {double? handleRadius,
                          double? height,
                          double? playedPart,
                          double? width}) {
                        return Paint()
                          ..shader = LinearGradient(colors: [
                            Color.fromRGBO(108, 165, 242, 1),
                            Color.fromRGBO(97, 104, 236, 1)
                          ], stops: [
                            0.0,
                            0.5
                          ]).createShader(
                            Rect.fromPoints(
                              Offset(0, 0),
                              Offset(width!, 0),
                            ),
                          );
                      },
                    ),
                    duration: 1.0,
                    position: viewModel.brightness,
                  ),
                )),
          if (viewModel.isDragVolume)
            Positioned(
                right: 15,
                bottom: viewModel.getSliderBottome(),
                top: 60,
                child: Container(
                  // color: Colors.red,
                  width: 5,
                  // height: 100,
                  child: VierticalProgressWidget(
                    flickProgressBarSettings: FlickProgressBarSettings(
                      height: 5,
                      handleRadius: 5,
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 8,
                      ),
                      getPlayedPaint: (
                          {double? handleRadius,
                          double? height,
                          double? playedPart,
                          double? width}) {
                        return Paint()
                          ..shader = LinearGradient(colors: [
                            Color.fromRGBO(108, 165, 242, 1),
                            Color.fromRGBO(97, 104, 236, 1)
                          ], stops: [
                            0.0,
                            0.5
                          ]).createShader(
                            Rect.fromPoints(
                              Offset(0, 0),
                              Offset(width!, 0),
                            ),
                          );
                      },
                    ),
                    duration: 1.0,
                    position: viewModel.volume,
                  ),
                )),
          if (viewModel.isShowProgress)
            Positioned.fill(
                bottom: viewModel.getProgressBottom(),
                left: 15,
                child: Row(
                  children: [
                    Text(viewModel.getCurPosition()),
                    Expanded(
                      child: PlayProgressWidget(
                        flickProgressBarSettings: FlickProgressBarSettings(
                          height: 5,
                          handleRadius: 5,
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.0,
                            vertical: 8,
                          ),
                          backgroundColor: Colors.white24,
                          bufferedColor: Colors.white38,
                          getPlayedPaint: (
                              {double? handleRadius,
                              double? height,
                              double? playedPart,
                              double? width}) {
                            return Paint()
                              ..shader = LinearGradient(colors: [
                                Color.fromRGBO(108, 165, 242, 1),
                                Color.fromRGBO(97, 104, 236, 1)
                              ], stops: [
                                0.0,
                                0.5
                              ]).createShader(
                                Rect.fromPoints(
                                  Offset(0, 0),
                                  Offset(width!, 0),
                                ),
                              );
                          },
                          getHandlePaint: (
                              {double? handleRadius,
                              double? height,
                              double? playedPart,
                              double? width}) {
                            return Paint()
                              ..shader = RadialGradient(
                                colors: [
                                  Color.fromRGBO(97, 104, 236, 1),
                                  Color.fromRGBO(97, 104, 236, 1),
                                  Colors.white,
                                ],
                                stops: [0.0, 0.4, 0.5],
                                radius: 0.4,
                              ).createShader(
                                Rect.fromCircle(
                                  center: Offset(playedPart!, height! / 2),
                                  radius: handleRadius!,
                                ),
                              );
                          },
                        ),
                        duration: videoModel
                            .videoPlayerValue!.duration.inMilliseconds
                            .toDouble(),
                        position: videoModel
                            .videoPlayerValue!.position.inMilliseconds
                            .toDouble(),
                        bufferPosition: viewModel.getBufferValue(),
                        onDragStart: () {},
                        onDragUpdate: (double position) {
                          videoModel.seekToPosition(position);
                        },
                        onDragEnd: () {},
                      ),
                    ),
                    Text(viewModel.getDuration()),
                    IconButton(
                      icon: Icon(
                        Icons.fullscreen,
                        semanticLabel: "fullscreen",
                      ),
                      onPressed: () {
                        widget._videoManager!.setScreenSize(context);
                        videoModel.toggleFullscreen();
                      },
                    ),
                  ],
                )),
          if (videoModel.isFullscreen)
            Positioned(
              right: 1,
              bottom: 80,
              child: IconButton(
                iconSize: 25,
                icon: Icon(
                  viewModel.isLandscape
                      ? Icons.crop_landscape_sharp
                      : Icons.crop_portrait_sharp,
                  semanticLabel: "orientation change",
                ),
                onPressed: () {
                  videoModel.changeOrientation();
                },
              ),
            ),
        ],
      ));
    });
  }
}
