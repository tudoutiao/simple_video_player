part of video_data_manager;

class VideoManagerModel extends ChangeNotifier {
  VideoManager? _videoManager;
  VideoPlayerController? _videoPlayerController;
  VideoPlayerValue? _videoPlayerValue;

  bool _mounted = true;
  bool _isMute = false;
  bool _isFullscreen = false;
  bool _currentVideoEnded = false;

  VideoManagerModel({VideoManager? videoManager})
      : this._videoManager = videoManager!;

  bool get isMute => _isMute;

  /// Is player in full-screen.
  bool get isFullscreen => _isFullscreen;

  ///play status  complete
  bool get isComplete => _currentVideoEnded;

  /// [videoPlayerController.value]
  VideoPlayerValue? get videoPlayerValue => _videoPlayerValue!;

  /// Current playing video controller.
  VideoPlayerController? get videoPlayerController => _videoPlayerController;

  /// Is current video initialized.
  ///
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
    if (videoPlayerValue != null &&
        // videoPlayerValue!.position != null &&
        videoPlayerValue!.duration != null &&
        (videoPlayerValue!.position) >= videoPlayerValue!.duration) {
    }

    if (_videoPlayerValue!.position == _videoPlayerValue!.duration &&
        videoPlayerValue!.isInitialized) {
      _currentVideoEnded = true;
      _videoManager!.viewManagerModel.handleShowPlayerControls();
    }

    if (videoPlayerValue!.isInitialized) _notify();
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
    _currentVideoEnded = false;
    await videoPlayerController!.play();
    _videoManager!.viewManagerModel.handleShowPlayerControls();
    _notify();
  }

  /// Pause the video.
  Future<void> pause() async {
    await videoPlayerController!.pause();
    _notify();
  }

  ///play speed
  Future<void> setPlaybackSpeed(double speed) async {
    if(!isPlaying)
      return;
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
