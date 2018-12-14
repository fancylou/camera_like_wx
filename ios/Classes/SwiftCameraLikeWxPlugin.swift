import Flutter
import UIKit

public class SwiftCameraLikeWxPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "camera_like_wx", binaryMessenger: registrar.messenger())
    let instance = SwiftCameraLikeWxPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    if call.method == "getPlatformVersion" {
        result("iOS " + UIDevice.current.systemVersion)
    }else {
        result("没有实现当前方法:\(call.method)")
    }
  }
}
