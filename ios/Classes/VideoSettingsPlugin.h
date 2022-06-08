#import <Flutter/Flutter.h>
#import <AVFoundation/AVFoundation.h>

#import "FlutterDataHandler.h"
#import "CameraController.h"
#import "ExposureController.h"
#import "FocusController.h"
#import "WhiteBalanceController.h"
#import "ZoomController.h"
#import "TorchController.h"
#import "VideoRenderer.h"
#import "PermissionHandler.h"


API_AVAILABLE(ios(10.0))
@interface VideoSettingsPlugin : NSObject<FlutterPlugin>
@property (nonatomic, weak) NSObject<FlutterPluginRegistrar>* registrar;
@property (nonatomic, strong) CameraController *cameraController;
@property (nonatomic, strong) ExposureController *exposureController;
@property (nonatomic, strong) FocusController *focusController;
@property (nonatomic, strong) WhiteBalanceController *whiteBalanceController;
@property (nonatomic, strong) ZoomController *zoomController;
@property (nonatomic, strong) TorchController *torchController;
@property (nonatomic, strong) VideoRenderer *renderer;
@property (nonatomic, strong) PermissionHandler *permissionHandler;


+(AVCaptureDevice*)deviceByUniqueID:(NSString*) uniqueID;

-(instancetype)init:(NSObject<FlutterPluginRegistrar>*)registrar
          messenger:(NSObject<FlutterBinaryMessenger>*)messenger
       withTextures:(NSObject<FlutterTextureRegistry> *)textures;

@end
