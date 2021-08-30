import 'package:flutter/cupertino.dart';

import 'progress_bar_settings.dart';

class VierticalProgressWidget extends StatefulWidget {
  double _duration;
  double _position;

  FlickProgressBarSettings _flickProgressBarSettings;

  VierticalProgressWidget({
    FlickProgressBarSettings? flickProgressBarSettings,
    required double duration,
    required double position,
  })  : this._flickProgressBarSettings =
            flickProgressBarSettings ?? FlickProgressBarSettings(),
        this._duration = duration,
        this._position = position;

  @override
  State<StatefulWidget> createState() => _StateVerticalProgressWidget();
}

class _StateVerticalProgressWidget extends State<VierticalProgressWidget> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, size) {
      return GestureDetector(
        child: Container(
          child: CustomPaint(
            painter: _ProgressBarPainter(
              duration: widget._duration,
              position: widget._position,
              flickProgressBarSettings: widget._flickProgressBarSettings,
            ),
          ),
        ),
      );
    });
  }
}

class _ProgressBarPainter extends CustomPainter {
  double? duration;
  double? position;
  List<double>? bufferPosition;
  FlickProgressBarSettings? flickProgressBarSettings;

  _ProgressBarPainter(
      {this.duration, this.position, this.flickProgressBarSettings});

  @override
  bool shouldRepaint(CustomPainter painter) => true;

  @override
  void paint(Canvas canvas, Size size) {
    double height = size.height;
    double width = flickProgressBarSettings!.height;
    double curveRadius = flickProgressBarSettings!.curveRadius;
    double handleRadius = flickProgressBarSettings!.handleRadius;
    //绘制全长进度条
    Paint backgroundPaint = flickProgressBarSettings!.getBackgroundPaint != null
        ? flickProgressBarSettings!.getBackgroundPaint!(
            width: width,
            height: height,
            handleRadius: handleRadius,
          )
        : Paint()
      ..color = flickProgressBarSettings!.backgroundColor;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromPoints(
          Offset(0.0, 0),
          Offset(width, height),
        ),
        Radius.circular(curveRadius),
      ),
      backgroundPaint,
    );
    position = position! < 0 ? 0 : position;
    final double playedPart = position! * height;

    //绘制播放进度
    Paint playedPaint = flickProgressBarSettings!.getPlayedPaint != null
        ? flickProgressBarSettings!.getPlayedPaint!(
            width: width,
            height: height,
            playedPart: playedPart,
            handleRadius: handleRadius,
          )
        : Paint()
      ..color = flickProgressBarSettings!.playedColor;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromPoints(
          Offset(0.0, height),
          Offset(width, height - playedPart),
        ),
        Radius.circular(curveRadius),
      ),
      playedPaint,
    );
  }
}
