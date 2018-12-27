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
      return new WxTakeVideoPage(callback: (result) => takeVideo(result));
    }
    return new WxCameraPage(controller: (operate, filePath) {
      debugPrint('operate:' + operate.toString());
      if (operate == "photo") {
        imagePath = filePath;
        changePage(WxCameraPageState.ShowPhotoPage);
      } else if (operate == 'video') {
        changePage(WxCameraPageState.ShowVideoPage);
      }else {
        close();
      }
    });
  }

  void takePhoto(result) {
    debugPrint('拍摄了照片了。。。。' + result.toString());
    if (result) {
      close();
    } else {
      changePage(WxCameraPageState.CameraPage);
    }
  }

  void takeVideo(result) {
    debugPrint('拍摄了视频拉。。。。' + result.toString());
    if (result) {
      close();
    } else {
      changePage(WxCameraPageState.CameraPage);
    }
  }

  void close() {
    Navigator.pop(context);
  }
}

 
 
