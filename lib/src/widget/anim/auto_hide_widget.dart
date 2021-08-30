import 'package:flutter/cupertino.dart';
import 'package:simple_video_player/src/manager/video_manager.dart';
import 'package:provider/provider.dart';

class AutoHideChild extends StatelessWidget {
  final Widget child;
  final bool autoHide;

  const AutoHideChild({
    Key? key,
    required this.child,
    this.autoHide = true,
    this.showIfVideoNotInitialized = true,
  }) : super(key: key);

  /// Show the child if video is not initialized.
  final bool showIfVideoNotInitialized;

  @override
  Widget build(BuildContext context) {
    return Consumer2<VideoManagerModel, ViewManagetModel>(
        builder: (context, videoModel, viewModel, childWidget) {
      return (!videoModel.isVideoInitialized && !showIfVideoNotInitialized)
          ? Container()
          : AnimatedSwitcher(
                  duration: Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: child,
                    );
                  },
                  child: (viewModel.isShowControl) ? child : Container(),
                )
      ;
    });
  }
}
