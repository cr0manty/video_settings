//
//  ZoomController.m
//  video_settings
//
//  Created by Denys Dudka on 18.05.2022.
//

#import "ZoomController.h"
#import "VideoSettingsPlugin.h"

#if TARGET_OS_IPHONE
#import <Flutter/Flutter.h>
#elif TARGET_OS_MAC
#import <FlutterMacOS/FlutterMacOS.h>
#endif

@implementation ZoomController

-(void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([@"ZoomController/init" isEqualToString:call.method]) {
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
    AVCaptureDevice *newDevice = [VideoSettingsPlugin deviceByUniqueID: deviceId];
    if (newDevice) {
        self.device = newDevice;
    }
}

-(void)setZoom:(float)zoom
        result:(FlutterResult) result {
    NSError *error;

    float maxZoom = [self getMaxZoomFactor];
    float minZoom = [self getMinZoomFactor];
    
    if (maxZoom < zoom || zoom < minZoom) {
        NSString *message = [NSString stringWithFormat:@"Your zoom is not in available zoom range, %f>%f>%f", minZoom, zoom, maxZoom];
        result([FlutterError errorWithCode:@"Set Zoom exception" message:message details:nil]);
    }

    if([self.device lockForConfiguration:&error]) {
        [self.device setVideoZoomFactor:zoom];
        [self.device unlockForConfiguration];
        result(@YES);
    }

    if (error) {
        result([FlutterError errorWithCode:@"Set Zoom exception"
                            message:[NSString stringWithFormat:@"%@", error]
                            details:nil]);
    }

    return result(@NO);
}

-(float)getMaxZoomFactor {
    return self.device.maxAvailableVideoZoomFactor;
}

-(float)getMinZoomFactor {
        return self.device.minAvailableVideoZoomFactor;
}

-(float)getZoomFactor {
    return self.device.videoZoomFactor;
}

@end
