import 'dart:math';

import 'package:flutter/material.dart';

enum RecordState { Start, StartRecord, End }

typedef CircleRecordButtonController<RecordState> = void Function(
    RecordState state);

///
///圆形按钮 仿微信拍照按钮 点击是拍照 按住是录视频（有进度条）
///
class CircleRecordButton extends StatefulWidget {
  final double radius;
  final int maxDuration;
  final double progressWidth;
  final Color buttonColor;
  final Color progressColor;
  final CircleRecordButtonController controller;

  const CircleRecordButton(
      {Key key,
      @required this.radius,
      this.buttonColor = Colors.white,
      this.maxDuration = 15,
      this.progressWidth = 5,
      this.progressColor = Colors.green,
      this.controller})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _CircleRecordButtonState();
  }
}

class _CircleRecordButtonState extends State<CircleRecordButton>
    with TickerProviderStateMixin {
  AnimationController ac; // 进度条动画控制器
  AnimationController transAc; // 按钮过渡动画控制器
  final GlobalKey paintKey = GlobalKey();

  void listener() {
    debugPrint('trans......');
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    debugPrint('duration:' + widget.maxDuration.toString());
    transAc =
        AnimationController(duration: Duration(microseconds: 500), vsync: this);
    transAc.addListener(listener);
    transAc.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // 按钮过渡动画完成后启动录制视频的进度条动画
        ac.forward();
        transAc.removeListener(listener);
      }
    });
    ac = AnimationController(
        duration: Duration(seconds: widget.maxDuration), vsync: this);
    ac.addListener(() {
      debugPrint('pro lis..............');
      setState(() {});
    });
    ac.addStatusListener((status) {
      if (status == AnimationStatus.forward) {
        if (widget.controller != null) {
          widget.controller(RecordState.StartRecord);
        }
      }
    });
  }

  @override
  void dispose() {
    ac.dispose();
    transAc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double width = widget.radius * 2.0;
    final size = new Size(width, width);
    return GestureDetector(
      onTapDown: _tapDown,
      onTapUp: _tapUp,
      onTapCancel: _tapCancel,
      child: CustomPaint(
        key: paintKey,
        size: size,
        painter: CircleRecordPainter(
            buttonColor: widget.buttonColor,
            progressWidth: widget.progressWidth,
            progressColor: widget.progressColor,
            progress: ac.value,
            transProgress: transAc.value),
      ),
    );
  }

  void _tapDown(TapDownDetails down) {
    debugPrint('tapDown.................');
    transAc.forward();
    if (widget.controller != null) {
      widget.controller(RecordState.Start);
    }
  }

  void _tapUp(TapUpDetails up) {
    debugPrint('_tapUp.................');
    transAc.stop();
    ac.stop();
  }

  void _tapCancel() {
    debugPrint('_tapCancel.................');
    if (widget.controller != null) {
      widget.controller(RecordState.End);
    }
  }
}

class CircleRecordPainter extends CustomPainter {
  final Color buttonColor;
  final double progressWidth;
  final Color progressColor;
  final double progress; //
  final double transProgress; //过渡动画进度

  const CircleRecordPainter(
      {this.buttonColor,
      this.progressWidth,
      this.progressColor,
      this.progress,
      this.transProgress});

  @override
  void paint(Canvas canvas, Size size) {
    debugPrint('progress:' +
        progress.toString() +
        ' , trans:' +
        transProgress.toString());
    final double drawRadius = size.width * 0.5;
    final double center = size.width * 0.5;
    final Offset offsetCenter = Offset(center, center);
    final Color progressBackgroundColor = buttonColor.withOpacity(0.7);

    final double bottomCircleRadius = drawRadius * (1 + transProgress);
    final bottomPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = progressBackgroundColor;
    canvas.drawCircle(offsetCenter, bottomCircleRadius, bottomPaint);

    final double circleRadius = drawRadius - progressWidth;
    final double circleRadiusTrans = circleRadius * (1 / (1 + transProgress));
    final circlePaint = Paint()
      ..style = PaintingStyle.fill
      ..color = buttonColor;
    canvas.drawCircle(offsetCenter, circleRadiusTrans, circlePaint);

    if (progress > 0) {
      final bottomPaint = Paint()
        ..style = PaintingStyle.stroke
        ..color = progressColor
        ..strokeWidth = progressWidth;
      canvas.drawCircle(
          offsetCenter, bottomCircleRadius - progressWidth, bottomPaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
