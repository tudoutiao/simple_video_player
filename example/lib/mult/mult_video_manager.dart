
import '../../simple_video_player.dart';

class MultiVideoManager{
  List<VideoManager> _videoManagers = [];
  VideoManager? _activeManager;

  init(VideoManager videoManager) {
    _videoManagers.add(videoManager);
    if (_videoManagers.length == 1) {
      play(videoManager);
    }
  }

  remove(VideoManager videoManager) {
    if (_activeManager == videoManager) {
      _activeManager = null;
    }
    videoManager.dispose();
    _videoManagers.remove(videoManager);
  }

  togglePlay(VideoManager flickManager) {
    if (_activeManager?.videoManagerModel?.isPlaying == true &&
        flickManager == _activeManager) {
      pause();
    } else {
      play(flickManager);
    }
  }

  pause() {
    _activeManager?.videoManagerModel?.pause();
  }

  play([VideoManager? flickManager]) {
    if (flickManager != null) {
      _activeManager?.videoManagerModel?.pause();
      _activeManager = flickManager;
    }

    _activeManager?.videoManagerModel?.play();
  }

}