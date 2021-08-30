import 'package:flutter/material.dart';

import 'progress_bar_settings.dart';

class PlayProgressWidget extends StatefulWidget {
  FlickProgressBarSettings _flickProgressBarSettings;
  double _duration;
  double? _position;
  List<double>? _bufferPosition;
  Function()? onDragStart;
  Function()? onDragEnd;
  Function(double position)? onDragUpdate;

  PlayProgressWidget({
    FlickProgressBarSettings? flickProgressBarSettings,
    required double duration,
    double? position,
    List<double>? bufferPosition,
     this.onDragEnd,
     this.onDragStart,
     this.onDragUpdate,
  })  : _flickProgressBarSettings =
            flickProgressBarSettings ?? FlickProgressBarSettings(),
        this._duration = duration,
        this._position = position,
        this._bufferPosition = bufferPosition;

  @override
  State<StatefulWidget> createState() => _StatePlayProgressWidget();
}

class _StatePlayProgressWidget extends State<PlayProgressWidget> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, size) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: size.maxWidth,
          padding: widget._flickProgressBarSettings.padding,
          child: Container(
            height: widget._flickProgressBarSettings.height,
            child: CustomPaint(
              painter: _ProgressBarPainter(
                widget._duration,
                widget._position,
                widget._bufferPosition,
                flickProgressBarSettings: widget._flickProgressBarSettings,
              ),
            ),
          ),
        ),
        onHorizontalDragStart: (DragStartDetails details) {
          widget.onDragStart!();
        },
        onHorizontalDragUpdate: (DragUpdateDetails details) {
          final box = context.findRenderObject() as RenderBox;
          final Offset tapPos = box.globalToLocal(details.localPosition);
          final double relative = tapPos.dx / box.size.width;
          final double position = widget._duration * relative;
          widget.onDragUpdate!(position);
        },
        onHorizontalDragEnd: (DragEndDetails details) {
            widget.onDragEnd!();

        },
        onTapDown: (TapDownDetails details) {
          final box = context.findRenderObject() as RenderBox;
          final Offset tapPos = box.globalToLocal(details.globalPosition);
          final double relative = tapPos.dx / box.size.width;
          final double position = widget._duration * relative;
          widget.onDragUpdate!(position);
        },
      );
    });
  }
}

class _ProgressBarPainter extends CustomPainter {
  double? duration;
  double? position;
  List<double>? bufferPosition;
  FlickProgressBarSettings? flickProgressBarSettings;

  _ProgressBarPainter(this.duration, this.position, this.bufferPosition,
      {this.flickProgressBarSettings});

  @override
  bool shouldRepaint(CustomPainter painter) => true;

  @override
  void paint(Canvas canvas, Size size) {
    double height = flickProgressBarSettings!.height;
    double width = size.width;
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
    //绘制缓存进度
    if (position! > duration!) position = duration;
    final double playedPartPercent = position! / duration!;
    final double playedPart =
        playedPartPercent > 1 ? width : playedPartPercent * width;

    double start = bufferPosition![0] * width;
    double end = bufferPosition![1] * width;

    Paint bufferedPaint = flickProgressBarSettings!.getBufferedPaint != null
        ? flickProgressBarSettings!.getBufferedPaint!(
            width: width,
            height: height,
            playedPart: playedPart,
            handleRadius: handleRadius,
            bufferedStart: start,
            bufferedEnd: end)
        : Paint()
      ..color = flickProgressBarSettings!.bufferedColor;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromPoints(
          Offset(0, 0),
          Offset(end, height),
        ),
        Radius.circular(curveRadius),
      ),
      bufferedPaint,
    );

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
          Offset(0.0, 0.0),
          Offset(playedPart, height),
        ),
        Radius.circular(curveRadius),
      ),
      playedPaint,
    );
    //绘制进度条拖动小球
    Paint handlePaint = flickProgressBarSettings!.getHandlePaint != null
        ? flickProgressBarSettings!.getHandlePaint!(
            width: width,
            height: height,
            playedPart: playedPart,
            handleRadius: handleRadius,
          )
        : Paint()
      ..color = flickProgressBarSettings!.handleColor;

    canvas.drawCircle(
      Offset(playedPart, height / 2),
      handleRadius,
      handlePaint,
    );
  }
}
