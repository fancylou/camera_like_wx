import 'dart:math';

import 'package:flutter/material.dart';

enum RecordState { Start, StartRecord, End }

typedef CircleRecordButtonController<RecordState> = void Function(
    RecordState state);

num degToRad(num deg) => deg * (pi / 180.0);

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

  @override
  void initState() {
    super.initState();
    transAc =
        AnimationController(duration: Duration(milliseconds: 500), vsync: this);
    transAc.addListener(() {
        setState(() {});
    });
    transAc.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // 按钮过渡动画完成后启动录制视频的进度条动画
        ac.forward();
      }
    });
    ac = AnimationController(
        duration: Duration(seconds: widget.maxDuration), vsync: this);
    ac.addListener(() {
      setState(() {});
    });
    ac.addStatusListener((status) {
      if (status == AnimationStatus.forward) {
        if (widget.controller != null) {
          widget.controller(RecordState.StartRecord);
        }
      }
      if (status == AnimationStatus.completed) {
        if (widget.controller != null) {
          widget.controller(RecordState.End);
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
      onTap: _tap,
      child: CustomPaint(
        key: paintKey,
        size: size,
        painter: CircleRecordPainter(
          widget.buttonColor, 
          widget.progressWidth,  
          widget.progressColor, 
          ac.value,
          transAc.value),
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
    //重置按钮 会同时执行stop
    transAc.value = 0;
    ac.value = 0;
    if (widget.controller != null) {
      widget.controller(RecordState.End);
    }
  }

  void _tap() {
    debugPrint('_tap.................');
  }

  void _tapCancel() {
    debugPrint('_tapCancel.................');
  }
}

class CircleRecordPainter extends CustomPainter {
  final Color buttonColor;
  final double progressWidth;
  final Color progressColor;
  final double progress; //
  final double transProgress; //过渡动画进度
  Color progressBackgroundColor;
  Paint bottomPaint;
  Paint circlePaint;
  Paint progressPaint;
  final back90 = degToRad(-90.0);

  CircleRecordPainter(this.buttonColor,
      this.progressWidth,
      this.progressColor,
      this.progress,
      this.transProgress)
      {
        progressBackgroundColor = buttonColor.withOpacity(0.7);
        bottomPaint  = Paint()
          ..style = PaintingStyle.fill
          ..color = progressBackgroundColor;
        circlePaint  = Paint()
          ..style = PaintingStyle.fill
          ..color = buttonColor;
        progressPaint  = Paint()
          ..style = PaintingStyle.stroke
          ..color = progressColor
          ..strokeWidth = progressWidth;
      }

  @override
  void paint(Canvas canvas, Size size) {
    // 底部最大的圆
    final double drawRadius = size.width * 0.5;
    final double center = size.width * 0.5;
    final Offset offsetCenter = Offset(center, center);
    final double bottomCircleRadius = drawRadius * (1 + (transProgress / 2));
    canvas.drawCircle(offsetCenter, bottomCircleRadius, bottomPaint);
    // 中间小圆
    final double circleRadius = drawRadius - progressWidth;
    final double circleRadiusTrans = circleRadius * (1 / (1 + transProgress));
    canvas.drawCircle(offsetCenter, circleRadiusTrans, circlePaint);
    // 进度条
    if (progress > 0) {
      final double angle = 360.0 * progress;
      final double radians = degToRad(angle);
      final double progressCircleRadius = bottomCircleRadius - progressWidth;
      final double offset = asin(progressWidth * 0.5 / progressCircleRadius);
      if (radians > offset) {
        canvas.save();
        canvas.translate(0.0, size.width);
        canvas.rotate(degToRad(-90.0));//画布旋转90度
        final Rect arcRect = Rect.fromCircle(center: offsetCenter, radius: progressCircleRadius);
        canvas.drawArc(
          arcRect, offset, radians - offset, false, progressPaint);
        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
