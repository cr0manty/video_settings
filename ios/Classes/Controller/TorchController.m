//
//  CameraHelper.m
//  Pods-Runner
//
//  Created by Denys Dudka on 19.05.2022.
//

#import "TorchController.h"
#import "VideoSettingsPlugin.h"

#if TARGET_OS_IPHONE
#import <Flutter/Flutter.h>
#elif TARGET_OS_MAC
#import <FlutterMacOS/FlutterMacOS.h>
#endif


@implementation TorchController

-(void)handleMethodCall:(FlutterMethodCall*)call
                 result:(FlutterResult)result {
    if ([@"TorchController/init" isEqualToString:call.method]) {
        NSDictionary* argsMap = call.arguments;
        NSString* deviceId = (NSString*)argsMap[@"deviceId"];
        
        [self init: deviceId];
        result(@YES);
    } else if ([@"TorchController/switchTorch" isEqualToString:call.method]) {
        NSDictionary* argsMap = call.arguments;
        NSNumber *mode = argsMap[@"mode"];
        
        [self switchTorch:mode result:result];
    } else if ([@"TorchController/isTorchSupported" isEqualToString:call.method]) {
        BOOL supported = [self isTorchSupported];
        result([NSNumber numberWithBool:supported]);
    } else if ([@"TorchController/isTorchEnabled" isEqualToString:call.method]) {
        BOOL enabled = [self isTorchEnabled];
        result([NSNumber numberWithBool:enabled]);
    } else if ([@"TorchController/isTorchModeSupported" isEqualToString:call.method]) {
        NSDictionary* argsMap = call.arguments;
        NSNumber *mode = argsMap[@"mode"];
        
        BOOL value = [self isTorchModeSupported:mode];
        result([NSNumber numberWithBool:value]);
    } else if ([@"TorchController/torchMode" isEqualToString:call.method]) {
        AVCaptureTorchMode mode = [self torchMode];
        result(@(mode));
    } else {
        result(nil);
    }
}

-(void)init:(NSString*)deviceId {
    if (@available(iOS 10.0, *)) {
        self.device = [VideoSettingsPlugin deviceByUniqueID: deviceId];
    }
}

-(BOOL)isTorchSupported {
    return self.device.isTorchAvailable && self.isTorchSupported;
}

-(void)switchTorch:(NSNumber*)modeNum
            result:(FlutterResult)result {
    AVCaptureTorchMode mode = (AVCaptureTorchMode)modeNum;
    
    if (![self isTorchModeSupported:modeNum]) {
        result([FlutterError errorWithCode:@"Switch torch mode exception"
                            message:@"Torch mode not supported"
                            details:nil]);
    }
    
    NSError *error;
    if([self.device lockForConfiguration:&error]) {
        [self.device setTorchMode:mode];
        [self.device unlockForConfiguration];
        result(@YES);
    }
    
    if (error) {
        result([FlutterError errorWithCode:@"Switch torch mode exception"
                            message:[NSString stringWithFormat:@"%@", error]
                            details:nil]);
    }
    
    result(@NO);
}

-(BOOL)isTorchEnabled {
    return [self.device isTorchActive];
}

-(BOOL)isTorchModeSupported:(NSNumber*)modeNum {
    AVCaptureTorchMode mode = (AVCaptureTorchMode)modeNum;
    
    return [self.device isTorchModeSupported:mode];
}

-(AVCaptureTorchMode)torchMode {
    return self.device.torchMode;
}

@end
