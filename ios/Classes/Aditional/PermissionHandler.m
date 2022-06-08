//
//  PermissionHandler.m
//  video_settings
//
//  Created by Denys Dudka on 19.05.2022.
//

#import "PermissionHandler.h"

#if TARGET_OS_IPHONE
#import <Flutter/Flutter.h>
#elif TARGET_OS_MAC
#import <FlutterMacOS/FlutterMacOS.h>
#endif

@implementation PermissionHandler

-(void)handleMethodCall:(FlutterMethodCall*)call
                 result:(FlutterResult)result {
    if ([@"PermissionHandler/requestAccessToCamera" isEqualToString:call.method]) {
        [self requestAccessToCamera: result];
    }
}

-(void)requestAccessToCamera:(FlutterResult)result {
    [AVCaptureDevice
     requestAccessForMediaType:AVMediaTypeVideo
     completionHandler:^ (BOOL granted) {
        dispatch_async(dispatch_get_main_queue(), ^ {
            result([NSNumber numberWithBool:granted]);
        });
    }];
}

@end
