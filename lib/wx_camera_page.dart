import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'wx_page_flow_delegate.dart';
import 'circle_record_button.dart';




typedef WxCameraController<String> = void Function(String operate, String filePath);

// 拍摄界面
class WxCameraPage extends StatefulWidget {
  final WxCameraController controller;

  const WxCameraPage({this.controller});

  @override
  State<StatefulWidget> createState() {
    return new _WxCameraPageState();
  }
}


class _WxCameraPageState extends State<WxCameraPage> {
  RecordState state = RecordState.Start;
  List<CameraDescription> cameras;
  CameraController controller;
  CameraLensDirection direction;
  String tempVideoPath = "";

  @override
  void initState() {
    super.initState();
    initCamera();
  }

  @override
    void dispose() {
      if(controller!=null) {
        controller.dispose();
      }
      super.dispose();
    }

  @override
  Widget build(BuildContext context) {
    return new Flow(
      children: <Widget>[
        buildCamera(context),
        buildOperationSurface(context)
      ],
      delegate: new CameraFlowDelegate(),
    );
  }

  // 摄像头界面
  Widget buildCamera(BuildContext context) {
    if (controller == null || !controller.value.isInitialized) {
      return Container();
    }
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;
    double asr = width / height;
    return AspectRatio(
        aspectRatio: asr,
        child: CameraPreview(controller));
  }
// 操作界面
  Widget buildOperationSurface(BuildContext context) {
    return new Column(
          children: <Widget>[
            Expanded(
              child: new Container(
                margin: EdgeInsets.all(10.0),
                padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                alignment: Alignment.centerRight,
                child: new IconButton(
                        icon: Icon(Icons.switch_camera,color: Colors.white, size: 48),
                        onPressed: changeCamera,)
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
                                this.onStartRecordPressed();
                                break;
                              }
                            case RecordState.End:
                              {
                                debugPrint('结束。。。。。。。。。。');
                                if (this.state == RecordState.Start) {
                                  this.onTakePhotoPressed();
                                } else if (this.state ==
                                    RecordState.StartRecord) {
                                  this.onEndRecordPressed();
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
        );
  }
 
  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();
  
  void onTakePhotoPressed() {
    takePicture().then( (filePath) {
      debugPrint('拍照。。：'+filePath);
      if(filePath != null && widget.controller != null) {
          widget.controller('photo', filePath);
      }else {
        debugPrint('没有拍摄到照片。。。。。。。。');
      }
    });
  }
  void onStartRecordPressed() {
    startRecord().then((filePath){
      debugPrint('开始拍摄视频。。。。:'+filePath);
    });
  }

  void onEndRecordPressed() {
    endRecord().then( (call) {
      if (widget.controller != null && tempVideoPath != '') {
        widget.controller('video', tempVideoPath);
      }else {
        debugPrint('视频拍摄未完成。。。');
      }
    });
    
  }

  Future<String> startRecord() async {
    if (!controller.value.isInitialized) {
      Fluttertoast.showToast(msg: '摄像头没有准备好！', timeInSecForIos: 1);
      return null;
    }
    final Directory extDir = await getApplicationDocumentsDirectory();
    final String filePath = '${extDir.path}/video_${timestamp()}.mp4';
    if (controller.value.isRecordingVideo) {
      return null;
    }
    try {
      tempVideoPath = filePath;
      await controller.startVideoRecording(filePath);
    } on CameraException catch (e) {
      Fluttertoast.showToast(msg: '拍摄视频异常,' + e.description, timeInSecForIos: 1);
      tempVideoPath = '';
      return null;
    }
    return filePath;
  }

  Future<void> endRecord() async {
    if (!controller.value.isRecordingVideo) {
      return null;
    }
    try {
      await controller.stopVideoRecording();
    } on CameraException catch (e) {
      debugPrint('stopVideoRecording 异常：'+e.description);
      return null;
    }
  }

  // 拍照
  Future<String> takePicture() async {
    if (!controller.value.isInitialized) {
      Fluttertoast.showToast(msg: '摄像头没有准备好！', timeInSecForIos: 1);
      return null;
    }
    final Directory extDir = await getApplicationDocumentsDirectory();
    // final String dirPath = '${extDir.path}/Pictures/flutter_test';
    // await Directory(dirPath).create(recursive: true);
    final String filePath = '${extDir.path}/photo_${timestamp()}.jpg';

    if (controller.value.isTakingPicture) {
      return null;
    }

    try {
      await controller.takePicture(filePath);
    } on CameraException catch (e) {
      Fluttertoast.showToast(msg: '拍摄照片异常,' + e.description, timeInSecForIos: 1);
      return null;
    }
    return filePath;
  }

// 切换摄像头
  void changeCamera() async {
    if (controller != null) {
      await controller.dispose();
    }
    if(direction != null && direction == CameraLensDirection.back) {
      direction = CameraLensDirection.front;
    }else {
      direction = CameraLensDirection.back;
    }
    CameraDescription des;
    for(var i = 0 ; i < cameras.length; i++) {
      if(cameras[i].lensDirection == direction) {
        des = cameras[i];
        break;
      }
    }
    if(des == null) {
      Fluttertoast.showToast(msg: '没有找到摄像头！', timeInSecForIos: 1);
      return;
    }
    controller = CameraController(des, ResolutionPreset.medium);
    try{
      await controller.initialize();
    } on CameraException catch (e) {
      Fluttertoast.showToast(msg: '摄像头初始化异常！'+e.description, timeInSecForIos: 1);
    }
    
    if (mounted) {
      setState(() {});
    }

  }
// 初始化摄像头
  Future<void> initCamera() async {
    cameras = await availableCameras();
    if (cameras != null && cameras.length > 0) {
      changeCamera();
    } else {
      debugPrint("没有摄像头。。。。。。。。");
      Fluttertoast.showToast(msg: '没有找到摄像头！', timeInSecForIos: 1);
    }
  }

  void _close() {
    //Navigator.pop(context);
    if (widget.controller!=null) {
      widget.controller('close', '');
    }
  }
}

