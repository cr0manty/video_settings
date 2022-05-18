#import <Flutter/Flutter.h>
#import <AVFoundation/AVFoundation.h>

#import "FlutterDataHandler.h"

@interface VideoSettingsPlugin : NSObject<FlutterPlugin>
@property (nonatomic, strong) NSObject<FlutterPluginRegistrar>* registrar;

+(AVCaptureDevice*)deviceByUniqueID:(NSString*) uniqueID;
@end
