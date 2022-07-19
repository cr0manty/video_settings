#import "VideoSettingsPlugin.h"

@implementation VideoSettingsPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:@"video_settings"
                                     binaryMessenger:[registrar messenger]];
    VideoSettingsPlugin* instance = [[VideoSettingsPlugin alloc] init:registrar
                                                            messenger:[registrar messenger]
                                                         withTextures:[registrar textures]];
    [registrar addMethodCallDelegate:instance channel:channel];
}

-(instancetype)init:(NSObject<FlutterPluginRegistrar>*)registrar
          messenger:(NSObject<FlutterBinaryMessenger>*)messenger
       withTextures:(NSObject<FlutterTextureRegistry> *)textures {
    self = [super init];
    self.registrar = registrar;
    
    // init Controllers
    self.cameraController = [CameraController new];
    self.exposureController = [ExposureController new];
    self.focusController = [FocusController new];
    self.whiteBalanceController = [WhiteBalanceController new];
    self.zoomController = [ZoomController new];
    self.torchController = [TorchController new];
    self.permissionHandler = [PermissionHandler new];

    self.renderer = [[VideoRenderer alloc] init:textures
                                    messenger:messenger];
//        long long textureId = [[registrar textures] registerTexture:self.renderer];
//        self.renderer.textureId = textureId;




    // register controllers
    [self.exposureController registerAdditionalHandlers:registrar];
    [self.whiteBalanceController registerAdditionalHandlers:registrar];
    [self.focusController registerAdditionalHandlers:registrar];

    return self;
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([call.method containsString: @"CameraController"]) {
        return [self.cameraController handleMethodCall:call result:result];
    } else if ([call.method containsString: @"ExposureController"]) {
        return [self.exposureController handleMethodCall:call result:result];
    } else if ([call.method containsString: @"FocusController"]) {
        return [self.focusController handleMethodCall:call result:result];
    } else if ([call.method containsString: @"WhiteBalanceController"]) {
        return [self.whiteBalanceController handleMethodCall:call result:result];
    } else if ([call.method containsString: @"ZoomController"]) {
        return [self.zoomController handleMethodCall:call result:result];
    } else if ([call.method containsString: @"TorchController"]) {
        return [self.torchController handleMethodCall:call result:result];
    } else if ([call.method containsString: @"PermissionHandler"]) {
        return [self.permissionHandler handleMethodCall:call result:result];
    }  else if ([call.method containsString: @"VideoRenderer"]) {
        return [self.renderer handleMethodCall:call result:result];
    } else {
        result(FlutterMethodNotImplemented);
    }
}

+(AVCaptureDevice*)deviceByUniqueID:(NSString*) uniqueID {
    return [AVCaptureDevice deviceWithUniqueID:uniqueID];
}

@end
