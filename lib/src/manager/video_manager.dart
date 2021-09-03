library video_data_manager;

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:simple_video_player/src/util/video_control_util.dart';
import 'package:video_player/video_player.dart';
import 'package:volume_controller/volume_controller.dart';

part 'video_manager_model.dart';

part 'view_manager_model.dart';

class VideoManager {
  VideoManagerModel? _videoManagerModel;
  ViewManagetModel? _viewManagerModel;
  BuildContext? _context;
  Size? _screenSize;
  bool? isFeed;
  int? _index;
  String? _thumImage;

  VideoManager(
      {VideoPlayerController? videoPlayerController,
      this.isFeed,
      String? thumImage,
      int index = -1}) {
    _videoManagerModel = VideoManagerModel(videoManager: this);
    _viewManagerModel =
        ViewManagetModel(videoManager: this, isFeed: isFeed ?? false);
    viewManagerModel.currentBrightness;
    viewManagerModel.currentVolume;
    _videoManagerModel!._handleChangeVideo(videoPlayerController!);
    _index = index;
    _thumImage = thumImage;
  }

  VideoManagerModel get videoManagerModel => _videoManagerModel!;

  ViewManagetModel get viewManagerModel => _viewManagerModel!;

  String get thumImage => _thumImage!;

  BuildContext? get context => _context;

  Size? get screenSize => _screenSize;

  int? get index => _index;

  registerContext(BuildContext context) {
    this._context = context;
  }

  setScreenSize(BuildContext context) {
    this._screenSize = MediaQuery.of(context).size;
  }

  _handleErrorInVideo() {}

  dispose() {
    _videoManagerModel!.dispose();
  }
}
