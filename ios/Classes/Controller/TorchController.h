//
//  CameraHelper.h
//  Pods-Runner
//
//  Created by Denys Dudka on 19.05.2022.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^FlutterResult)(id _Nullable result);
@class FlutterMethodCall;

@interface TorchController : NSObject
@property (nonatomic, strong) AVCaptureDevice *device;

-(void)handleMethodCall:(FlutterMethodCall*)call
                 result:(FlutterResult)result;

-(void)init:(NSString*)deviceId;

-(bool)isTorchSupported;

-(void)switchTorch:(NSNumber*)modeNum
            result:(FlutterResult)result;

-(BOOL)isTorchEnabled;

-(BOOL)isTorchModeSupported:(NSNumber*)modeNum;

-(AVCaptureTorchMode)torchMode;

@end

NS_ASSUME_NONNULL_END
