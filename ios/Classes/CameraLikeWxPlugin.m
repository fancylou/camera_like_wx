#import "CameraLikeWxPlugin.h"
#import <camera_like_wx/camera_like_wx-Swift.h>

@implementation CameraLikeWxPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftCameraLikeWxPlugin registerWithRegistrar:registrar];
}
@end
