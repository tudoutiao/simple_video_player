part of video_data_manager;

class ViewManagetModel extends ChangeNotifier {
  VideoManager _videoManager;

  ///是否显示控制组件
  ///初始化完成 ：显示title+button
  bool _isShowControl = true;

  ///是否显示音量控制，屏幕右侧上下滑动
  bool _isShowVolume = false;

  ///是否显示亮度控制，屏幕左侧上下滑动
  bool _isShowBrightness = false;

  ///播放进度显示
  bool _isShowProgress = false;

  ///
  bool _isShowPlayButton = true;

  ///仅全屏播放时为true
  bool _isShowBack = false;

  ///标题显示
  bool _isShowTitle = true;

  //是否倍速播放
  bool _isSpeedPlaying = false;

  //是否播放进度拖动
  bool _isDragPosition = false;

  //是否拖动亮度
  bool _isDragBrightness = false;

  //是否拖动音量
  bool _isDragVolume = false;

  //是否列表播放，屏幕横竖滑屏操作
  bool _isFeed = false;

  final double THRESHOLDX = 10.0;
  final double THRESHOLDY = 5.0;
  Offset _startDragLocation = Offset.zero;
  int _startDragPlayPosition = 0;
  double _startDragPlayVolume = 0.0;
  double _startDragBrightness = 0.0;
  double _brightness = 0.0;
  double _volume = 0.0;

  bool _mounted = true;
  Timer? _showPlayerControlsTimer;

  ViewManagetModel({VideoManager? videoManager, bool? isFeed})
      : this._videoManager = videoManager!,
        this._isFeed = isFeed!;

  /// is multiple speed playback
  bool get isSpeedPlaying => _isSpeedPlaying;

  bool get isShowProgress => _isShowProgress;

  ///
  bool get isShowBack => _isShowBack;

  bool get isShowTitle => _isShowTitle;

  /// is drag change play position
  bool get isDragPosition => _isDragPosition;

  /// is drag change play brightness
  bool get isDragBrightness => _isDragBrightness;

  /// is drag change play volume
  bool get isDragVolume => _isDragVolume;

  Offset get startDragLocation => _startDragLocation;

  int get startDragPlayPosition => _startDragPlayPosition;

  double get startDragPlayVolume => _startDragPlayVolume;

  double get startDragBrightness => _startDragBrightness;

  double get brightness => _brightness;

  double get volume => _volume;

  bool get isFeed => _isFeed;

  ///play status  complete
  bool get isPlaying => _videoManager.videoManagerModel.isPlaying;

  Duration get curPosition =>
      _videoManager.videoManagerModel.videoPlayerValue!.position;

  bool get isShowVolume => _isShowVolume;

  bool get isShowBrightness => _isShowBrightness;

  bool get isShowPlayButton => _isShowPlayButton;

  bool get isShowControl => _isShowControl;

  String getCurPosition() {
    Duration? position =
        _videoManager.videoManagerModel.videoPlayerValue?.position;
    String? positionInSeconds = position != null
        ? (position - Duration(minutes: position.inMinutes))
            .inSeconds
            .toString()
            .padLeft(2, '0')
        : null;
    String textPosition =
        position != null ? '${position.inMinutes}:$positionInSeconds' : '0:00';
    return textPosition;
  }

  String getDuration() {
    Duration? duration =
        _videoManager.videoManagerModel.videoPlayerValue?.duration;
    String? positionInSeconds = duration != null
        ? (duration - Duration(minutes: duration.inMinutes))
            .inSeconds
            .toString()
            .padLeft(2, '0')
        : null;
    String textPosition =
        duration != null ? '${duration.inMinutes}:$positionInSeconds' : '0:00';
    return textPosition;
  }

  double getSliderValue() {
    return (curPosition.inMilliseconds /
                _videoManager.videoManagerModel.videoPlayerValue!.duration
                    .inMilliseconds)
            .toDouble() *
        100;
  }

  List<double> getBufferValue() {
    if (null == _videoManager.videoManagerModel.videoPlayerValue ||
        _videoManager.videoManagerModel.videoPlayerValue!.isInitialized ==
            false) return [0, 0];
    VideoPlayerValue value = _videoManager.videoManagerModel.videoPlayerValue!;
    for (DurationRange range
        in _videoManager.videoManagerModel.videoPlayerValue!.buffered) {
      double start = range.startFraction(value.duration);
      double end = range.endFraction(value.duration);
      return [start, end];
    }
    return [0, 0];
  }

  double getProgressBottom() {
    double marginBottome = -130;
    if (_videoManager.videoManagerModel.isFullscreen) {
      marginBottome = [
        _videoManager.screenSize!.height,
        _videoManager.screenSize!.width
      ].reduce(min);
      marginBottome = -marginBottome + 90;
    }
    return marginBottome;
  }

  double getSliderBottome() {
    double marginBottom = 50;
    if (_videoManager.videoManagerModel.isFullscreen) {
      marginBottom = 70;
    }
    return marginBottom;
  }

  ///点击播放按钮更新ui
  handleTogglePlay() {
    if (_videoManager.videoManagerModel.playState == PlayState.complete) {
      //重播
      _isShowTitle = false;
      _isShowProgress = false;
      _isShowPlayButton = false;
      _notify();
    }
  }

  ///isShowControl:点击播放界面  显示隐藏所有控制器
  ///手势操作更新ui:点击、横向滑动、纵向滑动
  handleTapVideo() {
    switch (_videoManager.videoManagerModel.playState) {
      case PlayState.init:
        {
          _showPlayerControlsTimer?.cancel();
          _isShowControl = true;
          _isShowTitle = true;
          _isShowProgress = false;
          _isShowPlayButton = true;
          _notify();
          break;
        }
      case PlayState.complete:
        {
          break;
        }
      case PlayState.playing:
        {
          _showPlayerControlsTimer?.cancel();
          _isShowControl = !isShowControl;
          _isShowProgress = true;
          _isShowPlayButton = true;
          _showPlayerControlsTimer = Timer(Duration(seconds: 5), () {
            _isShowPlayButton = false;
            _isShowControl = false;
            _notify();
          });
          _notify();
          break;
        }
      case PlayState.pause:
        {
          _showPlayerControlsTimer?.cancel();
          _isShowControl = !isShowControl;
          _isShowProgress = true;
          _isShowPlayButton = true;
          _notify();
          break;
        }
    }
  }


  ///自然播放时界面更新
  handleChangeStateControlView() {
    switch (_videoManager.videoManagerModel.playState) {
      case PlayState.init:
        {
          _isShowPlayButton = true;
          _isShowProgress = false;
          break;
        }
      case PlayState.prepare:
        {
          _isShowTitle = false;
          _isShowPlayButton = false;
          _isShowProgress = false;
          break;
        }
      case PlayState.playing:
        {
          _isShowTitle = false;
          _isShowPlayButton = false;
          break;
        }
      case PlayState.pause:
        {
          _isShowControl = true;
          _isShowPlayButton = true;
          break;
        }
      case PlayState.complete:
        {
          _isShowControl = true;
          _isShowProgress = true;
          _isShowPlayButton = true;
          break;
        }
    }
    _notify();
  }

  ///滑动修改音量和亮度
  handleShowProgressControl() {
    if (isDragBrightness || isDragVolume) {
      handleControls(true);
    } else if (!isDragBrightness && !isDragVolume) {
      handleControls(false);
    }
    _notify();
  }

  handleShowPlayProgress() {
    handleControls(isDragPosition);
    if (isDragPosition) {
      _isShowProgress = true;
    }
    _notify();
  }

  ///长按快进
  handleLongPressControl(double speed) {
    _isSpeedPlaying = (speed == 1.0 ? false : true);
    handleControls(isSpeedPlaying);
    _notify();
  }

  handleControls(bool isShow) {
    if (isShow) {
      _isShowControl = true;
      _isShowPlayButton = false;
      _isShowProgress = false;
      _isShowTitle = false;
    } else {
      _isShowControl = false;
      _isShowPlayButton = true;
      _isShowProgress = true;
      _isShowTitle = true;
    }
  }

  void dragPosition(DragState state, Offset location) async {
    switch (state) {
      case DragState.HORIZONTAL_START:
      case DragState.VERTICAL_START:
        {
          _isDragPosition = false;
          _isDragBrightness = false;
          _isDragVolume = false;
          handleShowProgressControl();
          _startDragLocation = location;
          _startDragBrightness = await currentBrightness;
          _startDragPlayVolume = await VolumeController().getVolume();
          _startDragPlayPosition = _videoManager
              .videoManagerModel.videoPlayerValue!.position.inMilliseconds;
          break;
        }
      case DragState.HORIZONTAL_UPDATE:
        {
          double distanceX = location.dx - startDragLocation.dx;
          double absDistanceX = distanceX.abs();
          if (!_videoManager.viewManagerModel.isDragPosition) {
            if (absDistanceX > THRESHOLDX) {
              _isDragPosition = true;
            }
          }

          if (_videoManager.viewManagerModel.isDragPosition) {
            int seekDuration = (distanceX *
                    (_videoManager.videoManagerModel.videoPlayerValue!.duration
                            .inMilliseconds)
                        .toDouble() ~/
                    _videoManager.screenSize!.width)
                .toInt();

            Duration duration =
                Duration(milliseconds: startDragPlayPosition + seekDuration);
            _videoManager.videoManagerModel.seekTo(duration);
            if (distanceX > 0) {
              //向右前进
            } else {
              //向左后退
            }
          }

          handleShowPlayProgress();
          break;
        }
      case DragState.VERTICAL_UPDATE:
        {
          double distanceY = location.dy - startDragLocation.dy;
          double absDistanceY = distanceY.abs();
          if (!isDragBrightness && !isDragVolume && absDistanceY > THRESHOLDY) {
            if (startDragLocation.dx < _videoManager.screenSize!.width * 0.5) {
              _isDragBrightness = true;
            } else {
              _isDragVolume = true;
            }
          }
          handleShowProgressControl();
          if (isDragBrightness) {
            double seekBrightness =
                (distanceY / _videoManager.screenSize!.height).toDouble();
            // print("startDragBrightness: ${startDragBrightness}===distanceY :${distanceY}=== _videoManager!.screenSize!.height :${_videoManager!.screenSize!.height}===seekBrightness :${seekBrightness}");
            setBrightness(startDragBrightness - seekBrightness);
            if (distanceY > 0) {
              //向下降低
            } else {
              //向上升高
            }
          }
          if (isDragVolume) {
            double seekVolume =
                (distanceY / _videoManager.screenSize!.height).toDouble();
            // print("startDragPlayVolume: ${startDragPlayVolume}===seekVolume :${seekVolume}");
            setVolume(startDragPlayVolume - seekVolume);
            // setVolume(0.9);
          }
          break;
        }
      case DragState.VERTICAL_END:
      case DragState.HORIZONTAL_END:
        {
          _videoManager.viewManagerModel._isDragPosition = false;
          _isDragBrightness = false;
          _isDragVolume = false;
          _startDragLocation = Offset.zero;
          handleShowProgressControl();
          break;
        }
    }
  }

  Future<double> get currentBrightness async {
    try {
      _brightness = await ScreenBrightness.current;
      return _brightness;
    } catch (e) {
      print(e);
      throw 'Failed to get current brightness';
    }
  }

  Future<void> setBrightness(double brightness) async {
    try {
      _brightness = brightness;
      await ScreenBrightness.setScreenBrightness(brightness);
      _notify();
    } catch (e) {
      print(e);
      throw 'Failed to set brightness';
    }
  }

  /// change volume
  void setVolume(double volume) {
    _volume = volume;
    VolumeController().setVolume(volume, showSystemUI: false);
    _notify();
  }

  ///
  Future<double> get currentVolume async {
    _volume = await VolumeController().getVolume();
    return _volume;
  }

  _notify() {
    if (_mounted) {
      notifyListeners();
    }
  }

  dispose() {
    _mounted = false;
    super.dispose();
  }
}
