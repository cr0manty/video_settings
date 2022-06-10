//
//  ZoomController.m
//  video_settings
//
//  Created by Denys Dudka on 18.05.2022.
//

#import "ZoomController.h"
#import "VideoSettingsPlugin.h"
#import "CallBackModel.h"

#if TARGET_OS_IPHONE
#import <Flutter/Flutter.h>
#elif TARGET_OS_MAC
#import <FlutterMacOS/FlutterMacOS.h>
#endif

@implementation ZoomController {
    NSMutableArray *_callArray;
}

-(instancetype)init {
    self = [super init];
    
    if (self) {
        _callArray = [[NSMutableArray alloc] init];
    }
    
    return self;
}

-(void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if (!self.device && ![@"ZoomController/init" isEqualToString:call.method]) {
        CallBackModel *model = [[CallBackModel alloc] init:call result:result];
        [_callArray addObject:model];
        return;
    }
    
    if ([@"ZoomController/deinit" isEqualToString:call.method]) {
        self.device = nil;
        result(@YES);
    } else if ([@"ZoomController/init" isEqualToString:call.method]) {
        NSDictionary* argsMap = call.arguments;
        NSString* deviceId = (NSString*)argsMap[@"deviceId"];
        
        [self init: deviceId];
        result(@YES);
    } else if ([@"ZoomController/changeZoom" isEqualToString:call.method]) {
        NSDictionary* argsMap = call.arguments;
        NSNumber *zoom = argsMap[@"zoom"];
        
        [self setZoom:[zoom floatValue] result:result];
    } else if ([@"ZoomController/getMaxZoomFactor" isEqualToString:call.method]) {
        float zoom = [self getMaxZoomFactor];
        
        result([NSNumber numberWithFloat:zoom]);
    } else if ([@"ZoomController/getMinZoomFactor" isEqualToString:call.method]) {
        float zoom = [self getMinZoomFactor];
        
        result([NSNumber numberWithFloat:zoom]);
    } else if ([@"ZoomController/getZoomFactor" isEqualToString:call.method]) {
        float zoom = [self getZoomFactor];
        
        result([NSNumber numberWithFloat:zoom]);
    } else {
        result(nil);
    }
}

-(void)init:(NSString*)deviceId {
    if (@available(iOS 10.0, *)) {
        AVCaptureDevice *newDevice = [VideoSettingsPlugin deviceByUniqueID: deviceId];
        if (newDevice) {
            self.device = newDevice;
            NSLog(@"Array Lens %lu", (unsigned long)_callArray.count);
            for (CallBackModel *model in _callArray) {
                [self handleMethodCall:model.call result:model.result];
                [_callArray removeObject:model];
            }
        }
    }
}

-(void)setZoom:(float)zoom
        result:(FlutterResult) result {
    NSError *error;
    
    if([self.device lockForConfiguration:&error]) {
        [self.device setVideoZoomFactor:zoom];
        [self.device unlockForConfiguration];
        result(@YES);
    }
    
    if (error) {
        result([FlutterError errorWithCode:@"Set Zoom excetion"
                            message:[NSString stringWithFormat:@"%@", error]
                            details:nil]);
    }
    
    return result(@NO);
}

-(float)getMaxZoomFactor {
    if (@available(iOS 11.0, *)) {
        return [self.device maxAvailableVideoZoomFactor];
    }
    return 2;
}

-(float)getMinZoomFactor {
    if (@available(iOS 11.0, *)) {
        return [self.device minAvailableVideoZoomFactor];
    }
    
    return 1;
}

-(float)getZoomFactor {
    return [self.device videoZoomFactor];
}

@end
