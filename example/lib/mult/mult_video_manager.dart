import 'package:simple_video_player/simple_video_player.dart';

class MultiVideoManager {
  List<VideoManager> _videoManagers = [];
  VideoManager? _activeManager;
  bool isScroll = false;
  bool isInit = false;

  List<VideoManager> _visibleMangers = [];

  init(VideoManager videoManager) {
    _videoManagers.add(videoManager);
  }

  remove(VideoManager videoManager) {
    if (_activeManager == videoManager) {
      _activeManager = null;
    }
    videoManager.dispose();
    _videoManagers.remove(videoManager);
  }

  addData(VideoManager videoManager) {
    if (null != videoManager && !_visibleMangers.contains(videoManager)) {
      _visibleMangers.add(videoManager);
      _visibleMangers
          .sort((left, right) => left.index!.compareTo(right.index!));
    }
  }

  removeData(VideoManager? videoManager) {
    if (null == videoManager) return;
    videoManager.videoManagerModel.pauseListItem();
    if (_visibleMangers.contains(videoManager)) {
      if (_activeManager == videoManager) {
        _activeManager = null;
      }
      _visibleMangers.remove(videoManager);
    }
  }

  autoPlay() {
    if (_visibleMangers.length == 0 ||
        (null != _activeManager && _activeManager == _visibleMangers[0])) return;
    if (null != _activeManager) {
      _activeManager!.videoManagerModel.pauseListItem();
    }
    _activeManager = _visibleMangers[0];
    _activeManager!.videoManagerModel.play();
  }


  pause() {
    _activeManager?.videoManagerModel?.pauseListItem();
  }

}
