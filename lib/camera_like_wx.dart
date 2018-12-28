import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';

import 'wx_camera_page.dart';
import 'wx_take_photo_page.dart';
import 'wx_take_video_page.dart';

class CameraLikeWx {
  static const MethodChannel _channel = const MethodChannel('camera_like_wx');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<String> open(BuildContext context) async {
    final String filePath = await Navigator.push(context,
     MaterialPageRoute(builder: (context) => WxCameraBaseWidget()
    ));
    return filePath;
  }

}


// 拍摄页面 拍照结果页面 摄像结果页面
enum WxCameraPageState { CameraPage, ShowPhotoPage, ShowVideoPage }



class WxCameraBaseWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _WxCameraBaseState();
  }
}

class _WxCameraBaseState extends State<WxCameraBaseWidget> {
  WxCameraPageState page = WxCameraPageState.CameraPage;
  String imagePath;
  String videoPath;


  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: _body(),
    );
  }

  void changePage(WxCameraPageState page) {
    this.page = page;
    setState(() {});
  }

  Widget _body() {
    if (page == WxCameraPageState.ShowPhotoPage) {
      return new WxTakePhotoPage(callback: (result) => takePhoto(result), photoPath:imagePath);
    } else if (page == WxCameraPageState.ShowVideoPage) {
      return new WxTakeVideoPage(callback: (result) => takeVideo(result), videoPath: videoPath);
    }
    return new WxCameraPage(controller: (operate, filePath) {
      if (operate == "photo") {
        imagePath = filePath;
        changePage(WxCameraPageState.ShowPhotoPage);
      } else if (operate == 'video') {
        videoPath = filePath;
        changePage(WxCameraPageState.ShowVideoPage);
      }else {
        close('');
      }
    });
  }

  void takePhoto(result) {
    if (result) {
      close(imagePath);
    } else {
      changePage(WxCameraPageState.CameraPage);
      imagePath = '';
    }
  }

  void takeVideo(result) {
    if (result) {
      close(videoPath);
    } else {
      changePage(WxCameraPageState.CameraPage);
      videoPath = '';
    }
  }

  void close(String filePath) {
    Navigator.pop(context, filePath);
  }
}

 
 
