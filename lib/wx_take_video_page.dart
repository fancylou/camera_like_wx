import 'package:flutter/material.dart';
import 'dart:io';
import 'package:video_player/video_player.dart';

import 'wx_page_flow_delegate.dart';


class WxTakeVideoPage extends StatelessWidget {
  final callback;
  final String videoPath;
  const WxTakeVideoPage({this.callback, this.videoPath});

  @override
  Widget build(BuildContext context) {
    return new Flow(
      delegate: new CameraFlowDelegate(),
      children: <Widget>[ 
        new Container(
          child: new RecordedVideoWidget(videoPath: videoPath,),
        ),
        new Align(
        alignment: Alignment.bottomCenter,
        child: new Container(
          height: MediaQuery.of(context).size.height / 3,
          child: new Row(
            children: <Widget>[
              new Expanded(
                child: new Align(
                  alignment: Alignment.center,
                  child: new FloatingActionButton(
                      heroTag: 'restoreVideoBtn',
                      backgroundColor: Colors.white70,
                      child: Icon(Icons.undo, color: Colors.black, size: 36),
                      onPressed: _restore),
                ),
                flex: 1,
              ),
              new Expanded(
                child: new Align(
                    alignment: Alignment.center, child: new Container()),
                flex: 1,
              ),
              new Expanded(
                child: new Align(
                  alignment: Alignment.center,
                  child: new FloatingActionButton(
                    heroTag: 'takeVideoBtn',
                    backgroundColor: Colors.white,
                    child: Icon(Icons.check, color: Colors.green, size: 36),
                    onPressed: _takeVideo,
                  ),
                ),
                flex: 1,
              )
            ],
          ),
        ),
      )
    ]);
  }

  void _restore() {
    debugPrint('restore..............');
    callback(false);
  }

  void _takeVideo() {
    debugPrint('takeVideo...........');
    callback(true);
  }
}
 

// 录制好的视频播放用的Widget
class RecordedVideoWidget extends StatefulWidget {
  final String videoPath;

  const RecordedVideoWidget({this.videoPath});

  @override
  State<StatefulWidget> createState() {
    return _RecordedVideoState();
  }
}

class _RecordedVideoState extends State<RecordedVideoWidget> {
  VideoPlayerController _controller;
  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(new File(widget.videoPath))
      ..setLooping(true)
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {
          debugPrint('play..............');
          _controller.play();
        });
      });
    
  }

  @override
  void dispose() {
    debugPrint('Video player dispose................');
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double asr = 0;
    if (_controller.value.initialized) {
      debugPrint('aspectRatio:'+_controller.value.aspectRatio.toString());
      final double height = MediaQuery.of(context).size.height;
      final double width = MediaQuery.of(context).size.width;
      asr = width / height;
      debugPrint('screen: '+asr.toString());
    }
    
    return _controller.value.initialized
              ? AspectRatio(
                  aspectRatio: asr,
                  child: VideoPlayer(_controller),
                )
              : Container();
  }
}