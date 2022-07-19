//
//  FocusController.m
//  video_settings
//
//  Created by Denys Dudka on 18.05.2022.
//

#import "FocusController.h"
#import "FlutterDataHandler.h"
#import "VideoSettingsPlugin.h"

#if TARGET_OS_IPHONE
#import <Flutter/Flutter.h>
#elif TARGET_OS_MAC
#import <FlutterMacOS/FlutterMacOS.h>
#endif


@implementation FocusController

-(void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([@"FocusController/init" isEqualToString:call.method]) {
        NSDictionary* argsMap = call.arguments;
        NSString* deviceId = (NSString*)argsMap[@"deviceId"];
        
        [self init: deviceId];
        result(@YES);
    } else if ([@"ExposureController/dispose" isEqualToString:call.method]) {
        [self removeObservers];
        result(@YES);
    } else if ([@"FocusController/getFocusMode" isEqualToString:call.method]) {
        AVCaptureFocusMode value = [self getFocusMode];
        result(@(value));
    } else if ([@"FocusController/isFocusModeSupported" isEqualToString:call.method]) {
        NSDictionary* argsMap = call.arguments;
        NSNumber *mode = argsMap[@"mode"];
        
        BOOL helpResult = [self isFocusModeSupported:[mode intValue]];
        result([NSNumber numberWithBool:helpResult]);
    } else if ([@"FocusController/isFocusPointOfInterestSupported" isEqualToString:call.method]) {
        BOOL value = [self isFocusPointOfInterestSupported];
        
        result([NSNumber numberWithBool:value]);
    } else if ([@"FocusController/isLockingFocusWithCustomLensPositionSupported" isEqualToString:call.method]) {
        BOOL value = [self isLockingFocusWithCustomLensPositionSupported];
        
        result([NSNumber numberWithBool:value]);
    } else if ([@"FocusController/setFocusMode" isEqualToString:call.method]) {
        NSDictionary* argsMap = call.arguments;
        NSNumber *mode = argsMap[@"mode"];
        
        [self setFocusMode:[mode intValue] result:result];
    } else if ([@"FocusController/setFocusPoint" isEqualToString:call.method]) {
        NSDictionary* argsMap = call.arguments;
        CGPoint point;
        point.x = [argsMap[@"x"] floatValue];
        point.y = [argsMap[@"y"] floatValue];
        
        [self setFocusPoint:point result:result];
    } else if ([@"FocusController/getFocusPointLockedWithLensPosition" isEqualToString:call.method]) {
        float value = [self getFocusPointLocked];
        result([NSNumber numberWithFloat:value]);
    } else if ([@"FocusController/setFocusPointLockedWithLensPosition" isEqualToString:call.method]) {
        NSDictionary* argsMap = call.arguments;
        NSNumber *position = argsMap[@"position"];
        
        [self setFocusPointLocked:[position floatValue] result:result];
    } else if ([@"FocusController/getSupportedFocusMode" isEqualToString:call.method]) {
        NSArray *value = [self getSupportedFocusMode];
        
        result(value);
    } else {
        result(nil);
    }
}

-(void)registerAdditionalHandlers:(NSObject<FlutterPluginRegistrar>*)registrar {
    if (self.focusModeHandler && self.focusLensPositionHandler) return;
    
    self.focusModeHandler = [[FlutterSinkHandler alloc] init];
    self.focusLensPositionHandler = [[FlutterSinkHandler alloc] init];

    FlutterEventChannel* focusModeDataChannel = [FlutterEventChannel
                                                 eventChannelWithName:@"FocusController/modeChannel"
                                                 binaryMessenger: [registrar messenger]];
    FlutterEventChannel* focusLensPositionChannel = [FlutterEventChannel
                                                     eventChannelWithName:@"FocusController/lensDistanceChannel"
                                                     binaryMessenger: [registrar messenger]];

    [focusModeDataChannel setStreamHandler:self.focusModeHandler];
    [focusLensPositionChannel setStreamHandler:self.focusLensPositionHandler];
}

-(void)init:(NSString*)deviceId {
    [self removeObservers];
    self.device = [VideoSettingsPlugin deviceByUniqueID: deviceId];
    [self addObservers];
}

-(void)addObservers {
    [self.device addObserver:self forKeyPath:@"focusMode" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    [self.device addObserver:self forKeyPath:@"lensPosition" options:NSKeyValueObservingOptionNew context:nil];
}

-(void)removeObservers{
    [self.device removeObserver:self forKeyPath:@"focusMode" context:nil];
    [self.device removeObserver:self forKeyPath:@"lensPosition" context:nil];
}

-(BOOL)isFocusModeSupported:(NSInteger)modeNum {
    AVCaptureFocusMode mode = (AVCaptureFocusMode)modeNum;

    return [self.device isFocusModeSupported:mode];
}

-(BOOL)isLockingFocusWithCustomLensPositionSupported {
    return self.device.isLockingFocusWithCustomLensPositionSupported;
}

-(NSArray*)getSupportedFocusMode {
    NSMutableArray *array = [[NSMutableArray alloc] init];

    if ([self.device isFocusModeSupported:AVCaptureFocusModeLocked]) {
        [array addObject:[NSNumber numberWithInteger:AVCaptureFocusModeLocked]];
    }

    if ([self.device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        [array addObject:[NSNumber numberWithInteger:AVCaptureFocusModeAutoFocus]];
    }

    if ([self.device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
        [array addObject:[NSNumber numberWithInteger:AVCaptureFocusModeContinuousAutoFocus]];
    }

    return array;
}

-(AVCaptureFocusMode)getFocusMode {
    return self.device.focusMode;
}

-(void)setFocusMode:(NSInteger)modeNum result:(FlutterResult)result {
    AVCaptureFocusMode mode = (AVCaptureFocusMode)modeNum;

    if (![self.device isFocusModeSupported:mode]) {
        return result(@NO);
    }

    NSError *error;
    if ([self.device lockForConfiguration:&error]) {
        [self.device setFocusMode:mode];
        [self.device unlockForConfiguration];
        result(@YES);
    }

    if (error) {
        return result([FlutterError errorWithCode:@"Set focus mode exception"
                                          message:[NSString stringWithFormat:@"%@", error]
                                          details:nil]);
    }

    result(@NO);
}

-(BOOL)isFocusPointOfInterestSupported {
    return self.device.isFocusPointOfInterestSupported;
}

-(void)setFocusPoint:(CGPoint)point result:(FlutterResult)result {
    if (!self.device.isFocusPointOfInterestSupported || !self.device.isExposurePointOfInterestSupported) {
        return result([FlutterError errorWithCode:@"Set focus point failed"
                                          message:@"Device does not have focus point capabilities"
                                          details:nil]);
    }

    if (![self.device isFocusModeSupported:AVCaptureFocusModeAutoFocus] || ![self.device isExposureModeSupported:self.device.exposureMode]) {
        return result([FlutterError errorWithCode:@"Set focus point failed"
                                          message:@"Focus mode or exposure mode not supported"
                                          details:nil]);
    }

    NSError *error = nil;

    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    if ([self.device lockForConfiguration:&error]) {
        CGPoint truePoint = [self getCGPointForCoordWithOrientation:orientation
                                                                   x:point.x
                                                                   y:point.y];
        [self.device setFocusPointOfInterest:truePoint];
        [self.device setExposurePointOfInterest:truePoint];

        // apply point of interest
        [self.device setFocusMode:AVCaptureFocusModeAutoFocus];
        [self.device setExposureMode:self.device.exposureMode];
        [self.device unlockForConfiguration];

        [self applyExposureMode];
        result(@YES);
    }

    if (error) {
        result([FlutterError errorWithCode:@"Set focus point exception"
                                   message:[NSString stringWithFormat:@"%@", error]
                                   details:nil]);
    }

    result(@NO);
}

-(void)applyExposureMode {
    if ([self.device lockForConfiguration:nil]) {
        AVCaptureExposureMode mode = self.device.exposureMode;

        switch (mode) {
            case AVCaptureExposureModeLocked:
            case AVCaptureExposureModeCustom:
                [self.device setExposureMode:AVCaptureExposureModeAutoExpose];
                break;
            case AVCaptureExposureModeAutoExpose:
            case AVCaptureExposureModeContinuousAutoExposure:
                if ([self.device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
                    [self.device setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
                } else {
                    [self.device setExposureMode:AVCaptureExposureModeAutoExpose];
                }
                break;
        }

        [self.device unlockForConfiguration];
    }
}

-(CGPoint)getCGPointForCoordWithOrientation:(UIDeviceOrientation)orientation
                                           x:(double)x
                                           y:(double)y {
    double oldX = x;
    double oldY = y;

    switch (orientation) {
        case UIDeviceOrientationPortrait:  // 90 ccw
            y = 1 - oldX;
            x = oldY;
            break;
        case UIDeviceOrientationPortraitUpsideDown:  // 90 cw
            x = 1 - oldY;
            y = oldX;
            break;
        case UIDeviceOrientationLandscapeRight:  // 180
            x = 1 - x;
            y = 1 - y;
            break;
        case UIDeviceOrientationLandscapeLeft:
        default:
            // No rotation required
            break;
    }
    return CGPointMake(x, y);
}

-(float)getFocusPointLocked {
    return self.device.lensPosition;
}

-(void)setFocusPointLocked:(float)lensPosition result:(FlutterResult)result {
    if (![self.device isFocusModeSupported:AVCaptureFocusModeLocked] || !self.device.isLockingFocusWithCustomLensPositionSupported) {
        return result(@NO);
    }


    NSError *error;
    if ([self.device lockForConfiguration:&error]) {
        [self.device setFocusModeLockedWithLensPosition:lensPosition completionHandler: nil];
        [self.device unlockForConfiguration];
        return result(@YES);
    }

    if (error) {
        return result([FlutterError errorWithCode:@"Set focus point locked exception"
                                          message:[NSString stringWithFormat:@"%@", error]
                                          details:nil]);
    }

    return result(@NO);
}

-(void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    id oldValue = [change valueForKey:NSKeyValueChangeOldKey];
    id newValue = [change valueForKey:NSKeyValueChangeNewKey];

    if (oldValue == newValue) return;

    if ([keyPath isEqual:@"focusMode"]) {
        if (self.focusModeHandler && self.focusModeHandler.sink) {
            self.focusModeHandler.sink(newValue);
        }
    } else if ([keyPath isEqual:@"lensPosition"]) {
        if (self.focusLensPositionHandler && self.focusLensPositionHandler.sink) {
            self.focusLensPositionHandler.sink(newValue);
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}


@end
