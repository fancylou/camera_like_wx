import 'dart:math';

import 'package:flutter/material.dart';

enum RecordState {
  Start,
  StartRecord,
  End
}


typedef CircleRecordButtonController<RecordState> = void Function(RecordState state);

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
  
  const CircleRecordButton({
    Key key,
    @required this.radius,
    this.buttonColor = Colors.white70,
    this.maxDuration = 15,
    this.progressWidth = 5,
    this.progressColor = Colors.greenAccent,
    this.controller
  }): super(key : key);


  @override
  State<StatefulWidget> createState() {
    return _CircleRecordButtonState();
  }

}

class _CircleRecordButtonState extends State<CircleRecordButton> with SingleTickerProviderStateMixin {
  AnimationController ac ;
 final GlobalKey paintKey = GlobalKey();
@override
  void initState() {
    super.initState();
    ac = AnimationController(duration: Duration(seconds: widget.maxDuration), vsync: this);
    ac.addListener( () {

        setState(() {});
    });
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
              progress: ac.value),
        ),
    );
  }

  void _tapDown(TapDownDetails down) {

  }
  void _tapUp(TapUpDetails up) {

  }
  void _tapCancel() {

  }

}

class CircleRecordPainter extends CustomPainter {
  final Color buttonColor;
  final double progressWidth;
  final Color progressColor;
  final double progress;

  const CircleRecordPainter({
    this.buttonColor,
    this.progressWidth,
    this.progressColor,
    this.progress
  });

  @override
  void paint(Canvas canvas, Size size) {

  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return null;
  }

}