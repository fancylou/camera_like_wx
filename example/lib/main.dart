import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:camera_like_wx/camera_like_wx.dart';

import 'package:camera/camera.dart';

import 'circle_record_button.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await CameraLikeWx.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
          actions: <Widget>[
            new Builder(builder: (BuildContext context){
              return IconButton(
                icon: const Icon(Icons.camera), 
                onPressed: () => this._go2Camera(context)
                );
            })
          ],
        ),
        body: Center(
          child: Text('Running on: $_platformVersion\n'),
        ),
      ),
    );
  }

  void _go2Camera(BuildContext context) {
    debugPrint('跳转。。。。。');
    Navigator.push(context, MaterialPageRoute(
        builder: (context) => WxCameraBaseWidget()
    ));
  }
}


class WxCameraBaseWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _WxCameraBaseState();
  }

}

class _WxCameraBaseState extends State<WxCameraBaseWidget> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal,
      body: new Column(
        children: <Widget>[
          Expanded(child: new Container(
            margin: EdgeInsets.all(10.0),
            padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
            alignment: Alignment.centerRight,
            child:  new Icon(Icons.switch_camera, color: Colors.white, size: 48),

          ),
          flex: 1,),
          Expanded(child: new Container(
            margin: EdgeInsets.all(10.0),
            child: new Container(

            ),
          ),
          flex: 3,),
          Expanded(child: new Row(
            children: <Widget>[
              Expanded(child: new Align(
                alignment: Alignment.center,
                child: new IconButton(icon: Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 48),
                onPressed: _close,),
              ),
              flex: 1,),
              Expanded(child: new Align(
                alignment: Alignment.center,
                child: new CircleRecordButton(
                  radius: 42,   
                ),
              ),
              flex: 1,),
              Expanded(child: new Container(
                color: Colors.transparent,
              ),
              flex: 1,)
            ],
          ),
          flex: 1,)
         
        ],
      ),
    );
  }

  void _close() {
    Navigator.pop(context);
  }



}


// 第二页
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
        aspectRatio:
        controller.value.aspectRatio,
        child: CameraPreview(controller));
  }

  Future<void> initCamera() async {
      cameras = await availableCameras();
      if(cameras !=null && cameras.length > 0) {
        controller = CameraController(cameras[0], ResolutionPreset.medium);
        controller.initialize().then((_) {
          if (!mounted) {
            return;
          }
          setState(() {});
        });
      }else {
        debugPrint("没有摄像头。。。。。。。。");
      }
      
  }

}
