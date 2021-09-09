import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:wakelock/wakelock.dart';

import 'manager/video_manager.dart';

class VideoPlayerWidget extends StatefulWidget {
  VideoPlayerWidget({
    required this.videoManager,
    required this.videoWithControls,
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
    this.wakelockEnabled = true,
    this.wakelockEnabledFullscreen = true,
  });

  final VideoManager videoManager;
  final Widget videoWithControls;

  /// SystemUIOverlay to show.
  ///
  /// SystemUIOverlay is changed in init.
  final List<SystemUiOverlay> systemUIOverlay;

  /// SystemUIOverlay to show in full-screen.
  final List<SystemUiOverlay> systemUIOverlayFullscreen;

  /// Preferred device orientation.
  ///
  /// Use [preferredDeviceOrientationFullscreen] to manage orientation for full-screen.
  /// 纵向
  final List<DeviceOrientation> preferredDeviceOrientation;

  /// Preferred device orientation in full-screen.
  /// 横向
  final List<DeviceOrientation> preferredDeviceOrientationFullscreen;

  /// Prevents the screen from turning off automatically.
  ///
  /// Use [wakeLockEnabledFullscreen] to manage wakelock for full-screen.
  final bool wakelockEnabled;

  /// Prevents the screen from turning off automatically in full-screen.
  final bool wakelockEnabledFullscreen;

  @override
  State<StatefulWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoManager videoManager;
  bool _isFullscreen = false;
  bool _isLandscape = true;
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    this.videoManager = widget.videoManager;
    videoManager.registerContext(context);
    videoManager.videoManagerModel.addListener(listener);
    super.initState();
  }

  @override
  void dispose() {
    videoManager.videoManagerModel.removeListener(listener);
    if (widget.wakelockEnabled) {
      Wakelock.disable();
    }
    super.dispose();
  }

  // Listener on [videoManagerModel],
  // Pushes the full-screen if [videoManagerModel] is changed to full-screen.
  void listener() async {
    // print("${videoManager.videoManagerModel.isFullscreen}===${_isFullscreen}");

    if (videoManager.videoManagerModel.isFullscreen && !_isFullscreen) {
      _switchToFullscreen();
    } else if (_isFullscreen && !videoManager.videoManagerModel.isFullscreen) {
      _exitFullscreen();
    } else if (videoManager.videoManagerModel.isFullscreen &&
        _isFullscreen &&
        _isLandscape == videoManager.viewManagerModel.isLandscape) {
      if (videoManager.viewManagerModel.isLandscape) {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight
        ]);
        _isLandscape = false;
      } else {
        SystemChrome.setPreferredOrientations(
            [DeviceOrientation.portraitDown, DeviceOrientation.portraitUp]);
        _isLandscape = true;
      }
    }
  }

  _switchToFullscreen() {
    if (widget.wakelockEnabledFullscreen) {
      /// Disable previous wakelock setting.
      Wakelock.disable();
      Wakelock.enable();
    }

    _isFullscreen = true;
    _setPreferredOrientation();
    _setSystemUIOverlays();

    _overlayEntry = OverlayEntry(builder: (context) {
      return Scaffold(
        body: MultiProvider(
          providers: [
            ChangeNotifierProvider<ViewManagetModel>.value(
                value: videoManager.viewManagerModel),
            ChangeNotifierProvider<VideoManagerModel>.value(
                value: videoManager.videoManagerModel),
          ],
          child: widget.videoWithControls,
        ),
      );
    });

    Overlay.of(context)!.insert(_overlayEntry!);
  }

  _exitFullscreen() {
    if (widget.wakelockEnabled) {
      /// Disable previous wakelock setting.
      /// 常亮，不休眠
      Wakelock.disable();
      Wakelock.enable();
    }

    _isFullscreen = false;
    _isLandscape = true;
    if (!videoManager.viewManagerModel.isLandscape) {
      videoManager.videoManagerModel.changeOrientation();
    }
    _overlayEntry?.remove();
    _overlayEntry = null;
    _setPreferredOrientation();
    _setSystemUIOverlays();
  }

  _setPreferredOrientation() {
    if (_isFullscreen) {
      //设置屏幕方向
      SystemChrome.setPreferredOrientations(
          widget.preferredDeviceOrientationFullscreen);
    } else {
      SystemChrome.setPreferredOrientations(widget.preferredDeviceOrientation);
    }
  }

  _setSystemUIOverlays() {
    if (_isFullscreen) {
      //状态栏基底部虚拟按键展示与取消展示
      SystemChrome.setEnabledSystemUIOverlays(widget.systemUIOverlayFullscreen);
    } else {
      SystemChrome.setEnabledSystemUIOverlays(widget.systemUIOverlay);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ViewManagetModel>.value(
            value: videoManager.viewManagerModel),
        ChangeNotifierProvider<VideoManagerModel>.value(
            value: videoManager.videoManagerModel),
      ],
      child: widget.videoWithControls,
    );
  }
}
