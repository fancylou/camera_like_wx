import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';

import 'package:camera/camera.dart';

import 'package:video_player/video_player.dart';

import 'circle_record_button.dart';


class CameraLikeWx {
  static const MethodChannel _channel = const MethodChannel('camera_like_wx');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}

// 拍摄页面 拍照结果页面 摄像结果页面
enum WxCameraPage { CameraPage, ShowPhotoPage, ShowVideoPage }

class WxCameraBaseWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _WxCameraBaseState();
  }
}

class _WxCameraBaseState extends State<WxCameraBaseWidget> {
  WxCameraPage page = WxCameraPage.CameraPage;
  void changePage(WxCameraPage page) {
    this.page = page;
    setState(() {});
  }

  Widget _body() {
    if (page == WxCameraPage.ShowPhotoPage) {
      return new WxShowPhotoPage(callback: (result) => takePhoto(result));
    } else if (page == WxCameraPage.ShowVideoPage) {
      return new WxShowVideoPage(callback: (result) => takeVideo(result));
    }
    return new WxCameraSurface(controller: (operate) {
      debugPrint('operate:' + operate.toString());
      if (operate == "photo") {
        changePage(WxCameraPage.ShowPhotoPage);
      } else {
        changePage(WxCameraPage.ShowVideoPage);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: _body(),
    );
  }

  void takePhoto(result) {
    debugPrint('拍摄了照片了。。。。' + result.toString());
    if (result) {
      Navigator.pop(context);
    } else {
      changePage(WxCameraPage.CameraPage);
    }
  }

  void takeVideo(result) {
    debugPrint('拍摄了视频拉。。。。' + result.toString());
    if (result) {
      Navigator.pop(context);
    } else {
      changePage(WxCameraPage.CameraPage);
    }
  }
}

typedef WxCameraController<String> = void Function(String operate);

// 控件表面层 操作按钮
class WxCameraSurface extends StatefulWidget {
  final WxCameraController controller;

  const WxCameraSurface({this.controller});

  @override
  State<StatefulWidget> createState() {
    return new _WxCameraSurfaceState();
  }
}

// Flow 的布局delegate 上下叠加
class CameraFlowDelegate extends FlowDelegate {
  @override
  void paintChildren(FlowPaintingContext context) {
    for (var i = 0; i < context.childCount; i++) {
      context.paintChild(i, transform: new Matrix4.translationValues(0, 0, 0));
    }
  }

  @override
  bool shouldRepaint(FlowDelegate oldDelegate) {
    return oldDelegate != this;
  }
}

class _WxCameraSurfaceState extends State<WxCameraSurface> {
  RecordState state = RecordState.Start;
  @override
  Widget build(BuildContext context) {
    return new Flow(
      children: <Widget>[
        new Container(
          color: Colors.teal,
        ),
        new Column(
          children: <Widget>[
            Expanded(
              child: new Container(
                margin: EdgeInsets.all(10.0),
                padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                alignment: Alignment.centerRight,
                child: new Icon(Icons.switch_camera,
                    color: Colors.white, size: 48),
              ),
              flex: 1,
            ),
            Expanded(
              child: new Container(
                margin: EdgeInsets.all(10.0),
                child: new Container(),
              ),
              flex: 3,
            ),
            Expanded(
              child: new Row(
                children: <Widget>[
                  Expanded(
                    child: new Align(
                      alignment: Alignment.center,
                      child: new IconButton(
                        icon: Icon(Icons.keyboard_arrow_down,
                            color: Colors.white, size: 48),
                        onPressed: _close,
                      ),
                    ),
                    flex: 1,
                  ),
                  Expanded(
                    child: new Align(
                      alignment: Alignment.center,
                      child: new CircleRecordButton(
                        radius: 42,
                        controller: (state) {
                          switch (state) {
                            case RecordState.Start:
                              {
                                debugPrint('开始..........');
                                break;
                              }
                            case RecordState.StartRecord:
                              {
                                debugPrint('开始录视频。。。。。');
                                break;
                              }
                            case RecordState.End:
                              {
                                debugPrint('结束。。。。。。。。。。');
                                if (this.state == RecordState.Start) {
                                  if (widget.controller != null) {
                                    widget.controller('photo');
                                  }
                                } else if (this.state ==
                                    RecordState.StartRecord) {
                                  if (widget.controller != null) {
                                    widget.controller('video');
                                  }
                                }
                                break;
                              }
                          }
                          this.state = state;
                        },
                      ),
                    ),
                    flex: 1,
                  ),
                  Expanded(
                    child: new Container(
                      color: Colors.transparent,
                    ),
                    flex: 1,
                  )
                ],
              ),
              flex: 1,
            )
          ],
        )
      ],
      delegate: new CameraFlowDelegate(),
    );
  }

  void _close() {
    Navigator.pop(context);
  }
}

// 拍摄好的照片显示Widget
class WxShowPhotoPage extends StatelessWidget {
  final callback;

  const WxShowPhotoPage({this.callback});

  @override
  Widget build(BuildContext context) {
    return new Flow(
      delegate: new CameraFlowDelegate(),
      children: <Widget>[
        new Container(
          child: new Image.network('http://img.muliba.net/post/Screen%20Shot%202018-11-23%20at%2014.45.57.png',
          fit: BoxFit.fill),
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
                      backgroundColor: Colors.white70,
                      child: Icon(Icons.undo, color: Colors.black, size: 36),
                      onPressed: _restore,
                    ),
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
                      backgroundColor: Colors.white,
                      child: Icon(Icons.check, color: Colors.green, size: 36),
                      onPressed: _takePhoto,
                    ),
                  ),
                  flex: 1,
                )
              ],
            ),
          ),
        )
      ],
    );
  }

  void _restore() {
    debugPrint('restore..............');
    callback(false);
  }

  void _takePhoto() {
    debugPrint('takePhoto...........');
    callback(true);
  }
}

class WxShowVideoPage extends StatelessWidget {
  final callback;
  const WxShowVideoPage({this.callback});

  @override
  Widget build(BuildContext context) {
    return new Flow(
      delegate: new CameraFlowDelegate(),
      children: <Widget>[ 
        new Container(
          child: new RecordedVideoWidget(videoPath: 'http://img.muliba.net/VID_20180520_173444.mp4',),
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
      _controller = VideoPlayerController.network(widget.videoPath)
        ..initialize().then((_) {
          // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
          setState(() {
            //_controller.play();
          });
        });
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

// 摄像头Widget
class CameraWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _CameraState();
  }
}

class _CameraState extends State<CameraWidget> {
  List<CameraDescription> cameras;
  CameraController controller;

  @override
  void initState() {
    super.initState();
    initCamera();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (controller == null || !controller.value.isInitialized) {
      return Container();
    }
    return AspectRatio(
        aspectRatio: controller.value.aspectRatio,
        child: CameraPreview(controller));
  }

  Future<void> initCamera() async {
    cameras = await availableCameras();
    if (cameras != null && cameras.length > 0) {
      controller = CameraController(cameras[0], ResolutionPreset.medium);
      controller.initialize().then((_) {
        if (!mounted) {
          return;
        }
        setState(() {});
      });
    } else {
      debugPrint("没有摄像头。。。。。。。。");
    }
  }
}
