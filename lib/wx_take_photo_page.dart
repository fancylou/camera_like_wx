import 'package:flutter/material.dart';
import 'wx_page_flow_delegate.dart';
import 'dart:io';


// 拍摄好的照片显示Widget
class WxTakePhotoPage extends StatefulWidget {
  final callback;
  final String photoPath;

  const WxTakePhotoPage({this.callback, this.photoPath});

  @override
  State<StatefulWidget> createState() {
    return new _WxTakePhotoPageState();
  }

}

class _WxTakePhotoPageState extends State<WxTakePhotoPage> {
  
  @override
  Widget build(BuildContext context) {
    return new Flow(
      delegate: new CameraFlowDelegate(),
      children: <Widget>[
        new Container(
          child: new Image.file(new File(widget.photoPath),
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
                      heroTag: 'restoreBtn',
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
                      heroTag: 'takePhotoBtn',
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
    widget.callback(false);
  }

  void _takePhoto() {
    debugPrint('takePhoto...........');
    widget.callback(true);
  }
}