import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:camera_like_wx/camera_like_wx.dart';



void main() {
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
    .then((_) {
      runApp(MaterialApp(home: MyApp()));
    });
} 

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _returnFilePath = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Container(
            height: 200,
            child: Column(
              children: <Widget>[
                Text('返回结果: $_returnFilePath\n'), 
                RaisedButton(
                  color: Colors.blue,
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Icon(Icons.camera, color: Colors.white, size: 36),
                  ),
                  onPressed: () => this._openCamera(context))
              ],
            ),
          )
        ),
    );
  }

  void _openCamera(BuildContext context) {
    CameraLikeWx.open(context).then((filePath){
      debugPrint(filePath);
      _returnFilePath = filePath;
      setState(() {});
    });
  }
}


