import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:simple_video_player/simple_video_player.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock/wakelock.dart';


void main() => runApp(const VideoPlayerApp());

class VideoPlayerApp extends StatelessWidget {
  const VideoPlayerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Video Player Demo',
      home: VideoPlayerScreen(),
    );
  }
}

class VideoPlayerScreen extends StatefulWidget {
  const VideoPlayerScreen({
    Key? key,
    this.systemUIOverlay = SystemUiOverlay.values,
    this.systemUIOverlayFullscreen = const [],
    this.preferredDeviceOrientation = const [
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ],
    this.preferredDeviceOrientationFullscreen = const [
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight
    ],
  }) : super(key: key);

  /// SystemUIOverlay to show.
  ///
  /// SystemUIOverlay is changed in init.
  final List<SystemUiOverlay> systemUIOverlay;

  /// SystemUIOverlay to show in full-screen.
  final List<SystemUiOverlay> systemUIOverlayFullscreen;

  /// Use [preferredDeviceOrientationFullscreen] to manage orientation for full-screen.
  final List<DeviceOrientation> preferredDeviceOrientation;

  /// Preferred device orientation in full-screen.
  final List<DeviceOrientation> preferredDeviceOrientationFullscreen;

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  VideoManager? videoManager;
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    // // Initialize the controller and store the Future for later use.
    // _initializeVideoPlayerFuture = _controller.initialize();
    //
    // // Use the controller to loop the video.
    // _controller.setLooping(true);
    super.initState();

    videoManager = VideoManager(
        videoPlayerController: VideoPlayerController.network(
      'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
    ));

    videoManager!.videoManagerModel.addListener(listener);
  }

  // Listener on [FlickControlManager],
  // Pushes the full-screen if [FlickControlManager] is changed to full-screen.
  void listener() async {
    if (videoManager!.videoManagerModel.isFullscreen) {
      _switchToFullscreen();
    } else if (!videoManager!.videoManagerModel.isFullscreen) {
      _exitFullscreen();
    }
  }

  @override
  void dispose() {
    videoManager!.videoManagerModel.removeListener(listener);
    // Ensure disposing of the VideoPlayerController to free up resources.
    videoManager!.dispose();
    super.dispose();
  }

  _switchToFullscreen() {
    /// Disable previous wakelock setting.
    Wakelock.disable();
    Wakelock.enable();

    _setPreferredOrientation();
    _setSystemUIOverlays();

    _overlayEntry = OverlayEntry(builder: (context) {
      return ChangeNotifierProvider<VideoManagerModel>.value(
        value: videoManager!.videoManagerModel,
        child: Consumer<VideoManagerModel>(
          builder: (context, model, child) {
            return Scaffold(
              body: FutureBuilder(
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    // If the VideoPlayerController has finished initialization, use
                    // the data it provides to limit the aspect ratio of the video.
                    return LayoutBuilder(
                      builder: (context, size) {
                        double aspectRatio = model.videoPlayerValue!.aspectRatio;
                        return AspectRatio(
                          aspectRatio: 1.5,
                          child: FittedBox(
                            fit: BoxFit.cover,
                            child: model.videoPlayerValue?.isInitialized == true
                                ? Container(
                                    height: model.videoPlayerValue!.size.height,
                                    width: model.videoPlayerValue!.size.width,
                                    child: VideoPlayer(
                                        model.videoPlayerController!),
                                  )
                                : Container(),
                          ),
                        );
                      },
                    );
                  } else {
                    // If the VideoPlayerController is still initializing, show a
                    // loading spinner.
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: () {
                  model.togglePlay();
                },
                // Display the correct icon depending on the state of the player.
                child: Icon(
                  model.videoPlayerValue!.isPlaying
                      ? Icons.pause
                      : Icons.play_arrow,
                ),
              ),
            );
          },
        ),
      );
    });

    Overlay.of(context)!.insert(_overlayEntry!);
  }

  _exitFullscreen() {
      /// Disable previous wakelock setting.
      /// 常亮，不休眠
      Wakelock.disable();
      Wakelock.enable();


    _overlayEntry?.remove();
    _overlayEntry = null;
    _setPreferredOrientation();
    _setSystemUIOverlays();
  }

  _setPreferredOrientation() {
    if (videoManager!.videoManagerModel.isFullscreen) {
      //设置屏幕方向
      SystemChrome.setPreferredOrientations(
          widget.preferredDeviceOrientationFullscreen);
    } else {
      SystemChrome.setPreferredOrientations(widget.preferredDeviceOrientation);
    }
  }

  _setSystemUIOverlays() {
    if (videoManager!.videoManagerModel.isFullscreen) {
      //状态栏基底部虚拟按键展示与取消展示
      SystemChrome.setEnabledSystemUIOverlays(widget.systemUIOverlayFullscreen);
    } else {
      SystemChrome.setEnabledSystemUIOverlays(widget.systemUIOverlay);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<VideoManagerModel>.value(
      value: videoManager!.videoManagerModel,
      child: Consumer<VideoManagerModel>(
        builder: (context, model, child) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Butterfly Video'),
            ),
            // Use a FutureBuilder to display a loading spinner while waiting for the
            // VideoPlayerController to finish initializing.
            body: FutureBuilder(
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  // If the VideoPlayerController has finished initialization, use
                  // the data it provides to limit the aspect ratio of the video.
                  return Container(
                    child: Column(
                      children: [
                        AspectRatio(
                          aspectRatio: model.videoPlayerValue!.aspectRatio,
                          // Use the VideoPlayer widget to display the video.
                          child: VideoPlayer(model.videoPlayerController!),
                        ),
                        positionWidget(),
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.play_arrow,
                                semanticLabel: "play",
                              ),
                              onPressed: () {
                                model.play();
                              },
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.pause,
                                semanticLabel: "pause",
                              ),
                              onPressed: () {
                                model.pause();
                              },
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.fullscreen,
                                semanticLabel: "fullscreen",
                              ),
                              onPressed: () {
                                  model.toggleFullscreen();
                              },
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.fullscreen_exit,
                                semanticLabel: "exitfullscreen",
                              ),
                              onPressed: () {},
                            ),
                          ],
                        )
                      ],
                    ),
                  );
                } else {
                  // If the VideoPlayerController is still initializing, show a
                  // loading spinner.
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                model.togglePlay();
              },
              // Display the correct icon depending on the state of the player.
              child: Icon(
                model.videoPlayerValue!.isPlaying
                    ? Icons.pause
                    : Icons.play_arrow,
              ),
            ),
          );
        },
      ),
    );
  }


  positionWidget() {
    return Consumer<VideoManagerModel>(builder: (context, model, child) {
      Duration position = model.videoPlayerValue!.position;

      String? positionInSeconds;
      if (null != position) {
        positionInSeconds = (position - Duration(minutes: position.inMinutes))
            .inSeconds
            .toString()
            .padLeft(2, '0');
      }

      String textPosition = position != null
          ? '${position.inMinutes}:$positionInSeconds'
          : '0:00';

      return Container(
        margin: EdgeInsets.all(10),
        child: Text(textPosition),
      );
    });
  }
}
