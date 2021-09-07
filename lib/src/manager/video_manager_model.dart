part of video_data_manager;

class VideoManagerModel extends ChangeNotifier {
  VideoManager? _videoManager;
  VideoPlayerController? _videoPlayerController;
  VideoPlayerValue? _videoPlayerValue;

  bool _mounted = true;
  bool _isMute = false;
  bool _isFullscreen = false;
  PlayState _playState = PlayState.init;

  VideoManagerModel({VideoManager? videoManager})
      : this._videoManager = videoManager!;

  bool get isMute => _isMute;

  /// Is player in full-screen.
  bool get isFullscreen => _isFullscreen;

  PlayState get playState => _playState;

  /// [videoPlayerController.value]
  VideoPlayerValue? get videoPlayerValue => _videoPlayerValue!;

  /// Current playing video controller.
  VideoPlayerController? get videoPlayerController => _videoPlayerController;

  /// Is current video initialized.
  /// true:开始播放
  bool get isVideoInitialized =>
      videoPlayerController?.value.isInitialized ?? false;

  bool get isPlaying => _videoPlayerController!.value.isPlaying;

  _handleChangeVideo(VideoPlayerController newController) async {
    _changeVideo(newController);
  }

  _changeVideo(VideoPlayerController newController) async {
    _videoPlayerController = newController;
    videoPlayerController!.addListener(_videoListener);
    _videoPlayerValue = videoPlayerController!.value;
    if (!videoPlayerController!.value.isInitialized) {
      try {
        await videoPlayerController!.initialize();
      } catch (err) {
        _videoManager!._handleErrorInVideo();
      }
    }
  }

  _videoListener() {
    _videoPlayerValue = videoPlayerController!.value;
    PlayState? state;
    // print("${_videoPlayerValue}");
    if (!_videoPlayerValue!.isInitialized && !_videoPlayerValue!.isPlaying) {
      //初始化
      state = PlayState.init;
    } else if (!_videoPlayerValue!.isInitialized &&
        _videoPlayerValue!.isPlaying) {
      //点击播放按钮
      state = PlayState.prepare;
    } else if (_videoPlayerValue!.isInitialized &&
        _videoPlayerValue!.isPlaying) {
      //开始播放
      state = PlayState.playing;
    } else if (_videoPlayerValue!.isInitialized &&
        !_videoPlayerValue!.isPlaying &&
        _videoPlayerValue!.position == _videoPlayerValue!.duration) {
      //播放完成
      state = PlayState.complete;
    } else if (_videoPlayerValue!.isInitialized &&
        !_videoPlayerValue!.isPlaying) {
      //暂停播放
      state = PlayState.pause;
    }

    if (null == state || playState != state) {
      _playState = state!;
      _videoManager!.viewManagerModel.handleChangeStateControlView();
    }
  }

  void changeVideo() async {
    _videoPlayerController!.addListener(_videoListener);
    _notify();
  }

  void setMute() {
    if (isMute)
      _videoPlayerController?.setVolume(1.0);
    else
      _videoPlayerController?.setVolume(0.0);
  }

  Future<double> get initialBrightness async {
    try {
      return await ScreenBrightness.initial;
    } catch (e) {
      print(e);
      throw 'Failed to get initial brightness';
    }
  }

  /// Enter full-screen.
  void enterFullscreen() {
    _isFullscreen = true;
    _notify();
  }

  /// Exit full-screen.
  void exitFullscreen() {
    _isFullscreen = false;

    _notify();
  }

  /// Toggle full-screen.
  void toggleFullscreen() {
    if (_isFullscreen) {
      exitFullscreen();
    } else {
      enterFullscreen();
    }
  }

  /// Toggle play.
  void togglePlay() {
    isPlaying ? pause() : play();
  }

  /// Play the video.
  Future<void> play() async {
    await videoPlayerController!.play();
    _notify();
    // _videoManager!.viewManagerModel.handleShowPlayerControls();
  }

  /// Pause the video.
  Future<void> pause() async {
    if (!videoPlayerValue!.isPlaying) return;
    await videoPlayerController!.pause();
    _notify();
  }

  ///play speed
  Future<void> setPlaybackSpeed(double speed) async {
    if (!isPlaying) return;
    await _videoPlayerController!.setPlaybackSpeed(speed);
    _videoManager!.viewManagerModel.handleLongPressControl(speed);
    _notify();
  }

  Future<void> seekToPosition(double pos) async {
    // print("====${pos}");
    if (videoPlayerValue!.isInitialized) {
      Duration position = new Duration(milliseconds: pos.toInt());
      await _videoPlayerController!.seekTo(position);
    }
  }

  /// Seek video to a duration.
  Future<void> seekTo(Duration moment) async {
    await _videoPlayerController!.seekTo(moment);
  }

  _notify() {
    if (_mounted) {
      notifyListeners();
    }
  }

  dispose() {
    _mounted = false;
    videoPlayerController?.pause();
    videoPlayerController?.removeListener(_videoListener);
    videoPlayerController?.dispose();

    super.dispose();
  }
}
