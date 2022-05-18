//
//  ExposureController.m
//  Pods-Runner
//
//  Created by Denys Dudka on 18.05.2022.
//

#import "ExposureController.h"
#import "FlutterDataHandler.h"
#import "VideoSettingsPlugin.h"

#if TARGET_OS_IPHONE
#import <Flutter/Flutter.h>
#elif TARGET_OS_MAC
#import <FlutterMacOS/FlutterMacOS.h>
#endif

@implementation ExposureController


__const float kExposureDurationPower = 5.0;
__const float kExposureMinimumDuration = 1.0/1000;


-(void)registerAdditionalHandlers:(NSObject<FlutterPluginRegistrar>*)registrar {
    if (self.exposureModeHandler && self.exposureDurationHandler &&
        self.ISOHandler && self.exposureTargetBiasHandler &&
        self.exposureTargetOffsetHandler) return;
    
    self.exposureModeHandler = [[FlutterSinkDataHandler alloc]init];
    self.exposureDurationHandler = [[FlutterSinkDataHandler alloc]init];
    self.ISOHandler = [[FlutterSinkDataHandler alloc]init];
    self.exposureTargetBiasHandler = [[FlutterSinkDataHandler alloc]init];
    self.exposureTargetOffsetHandler = [[FlutterSinkDataHandler alloc]init];
    
    FlutterEventChannel* exposureModeChannel = [FlutterEventChannel
                                                     eventChannelWithName:@"ExposureController/modeChannel"
                                                     binaryMessenger: [registrar messenger]];
    FlutterEventChannel* exposureDurationChannel = [FlutterEventChannel
                                                     eventChannelWithName:@"ExposureController/durationChannel"
                                                     binaryMessenger: [registrar messenger]];
    FlutterEventChannel* ISOChannel = [FlutterEventChannel
                                        eventChannelWithName:@"ExposureController/isoChannel"
                                        binaryMessenger: [registrar messenger]];
    FlutterEventChannel* exposureTargetBiasChannel = [FlutterEventChannel
                                                     eventChannelWithName:@"ExposureController/targetBiasChannel"
                                                     binaryMessenger: [registrar messenger]];
    FlutterEventChannel* exposureTargetOffsetChannel = [FlutterEventChannel
                                                     eventChannelWithName:@"ExposureController/offsetChannel"
                                                     binaryMessenger: [registrar messenger]];
    
    [exposureModeChannel setStreamHandler: self.exposureModeHandler];
    [exposureDurationChannel setStreamHandler: self.exposureDurationHandler];
    [ISOChannel setStreamHandler:self.ISOHandler];
    [exposureTargetBiasChannel setStreamHandler: self.exposureTargetBiasHandler];
    [exposureTargetOffsetChannel setStreamHandler: self.exposureTargetOffsetHandler];
}

-(void)init:(NSString*)deviceId {
    [self removeObservers];
    self.device = [VideoSettingsPlugin deviceByUniqueID: deviceId];
    [self addObservers];
}

-(void)addObservers {
    [self.device addObserver:self forKeyPath:@"exposureMode" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    [self.device addObserver:self forKeyPath:@"exposureDuration" options:NSKeyValueObservingOptionNew context:nil];
    [self.device addObserver:self forKeyPath:@"ISO" options:NSKeyValueObservingOptionNew context:nil];
    [self.device addObserver:self forKeyPath:@"exposureTargetBias" options:NSKeyValueObservingOptionNew context:nil];
    [self.device addObserver:self forKeyPath:@"exposureTargetOffset" options:NSKeyValueObservingOptionNew context:nil];
}

-(void)removeObservers {
    if (!self.device) return;
    
    [self.device removeObserver:self forKeyPath:@"exposureMode" context:nil];
    [self.device removeObserver:self forKeyPath:@"exposureDuration" context:nil];
    [self.device removeObserver:self forKeyPath:@"ISO" context:nil];
    [self.device removeObserver:self forKeyPath:@"exposureTargetBias" context:nil];
    [self.device removeObserver:self forKeyPath:@"exposureTargetOffset" context:nil];
}

-(NSArray*)getSupportedExposureMode {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    if ([self.device isExposureModeSupported:AVCaptureExposureModeLocked]) {
        [array addObject:[NSNumber numberWithInteger:AVCaptureExposureModeLocked]];
    }
    
    if ([self.device isExposureModeSupported:AVCaptureExposureModeAutoExpose]) {
        [array addObject:[NSNumber numberWithInteger:AVCaptureExposureModeAutoExpose]];
    }
    
    if ([self.device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
        [array addObject:[NSNumber numberWithInteger:AVCaptureExposureModeContinuousAutoExposure]];
    }
    
    if ([self.device isExposureModeSupported:AVCaptureExposureModeCustom]) {
        [array addObject:[NSNumber numberWithInteger:AVCaptureExposureModeCustom]];
    }
    
    return array;
}

-(void)setExposureMode:(NSInteger)modeNum result:(FlutterResult)result {
    AVCaptureExposureMode mode = (AVCaptureExposureMode)modeNum;
    
    if (![self isExposureModeSupported: modeNum]) {
        result(@NO);
    }
    
    NSError *error;
    if ([self.device lockForConfiguration:&error]) {
        [self.device setExposureMode:mode];
        [self.device unlockForConfiguration];
        result(@YES);
    }
    
    if (error) {
        result([FlutterError errorWithCode:@"Set exposure mode excetion"
                            message:[NSString stringWithFormat:@"%@", error]
                            details:nil]);
    }
    
    result(@NO);
}

-(BOOL)isExposureModeSupported:(NSInteger)modeNum {
    AVCaptureExposureMode mode = (AVCaptureExposureMode)modeNum;
    
    return [self.device isExposureModeSupported:mode];
}


-(void)changeISO:(float)value result:(FlutterResult)result  {
    NSError *error;
    
    if (value < [self.device activeFormat].minISO || value > [self.device activeFormat].maxISO) {
        result([FlutterError errorWithCode:@"ChangeISO excetion"
                            message:@"value is not in minISO and maxISO range"
                            details:nil]);
    }
    
    if([self.device lockForConfiguration:&error]) {
        [self.device setExposureModeCustomWithDuration:self.device.exposureDuration ISO:value completionHandler:nil];
        [self.device setWhiteBalanceMode:AVCaptureWhiteBalanceModeLocked];
        
        [self.device unlockForConfiguration];
        result(@YES);
    }
    if (error) {
        result([FlutterError errorWithCode:@"Change ISO excetion"
                            message:[NSString stringWithFormat:@"%@", error]
                            details:nil]);

    }
    result(@NO);
}

-(void)changeBias:(float)value result:(FlutterResult)result  {
    NSError *error;
    
    if (value < [self.device minExposureTargetBias] || value > [self.device maxExposureTargetBias]) {
        result([FlutterError errorWithCode:@"Change bias exception"
                            message:@"value is not in minExposureTargetBias and maxExposureTargetBias range"
                            details:nil]);
    }
    
    if([self.device lockForConfiguration:&error]) {
        [self.device setExposureTargetBias:value completionHandler:nil];
        [self.device setWhiteBalanceMode:AVCaptureWhiteBalanceModeLocked];
        
        [self.device unlockForConfiguration];
        result(@YES);
    }
    if (error) {
        result([FlutterError errorWithCode:@"Change bias exception"
                            message:[NSString stringWithFormat:@"%@", error]
                            details:nil]);

    }
    result(@NO);
}

-(float)getMinISO {
    return [self.device activeFormat].minISO;
}

-(float)getMaxISO {
    return [self.device activeFormat].maxISO;
}

-(void)changeExposureDuration:(float)value result:(FlutterResult)result  {
    
    if (@available(iOS 10.0, *)) {
        if (self.device.deviceType == AVCaptureDeviceTypeBuiltInTelephotoCamera) {
            result(@NO);
        }
    }
    
    NSError *error;
    
    if([self.device lockForConfiguration:&error]) {
        float iso = [self normalizeISO: self.device.ISO];
        float p = pow(value, kExposureDurationPower); // Apply power function to expand slider's low-end range
        float minDurationSeconds = MAX(CMTimeGetSeconds(self.device.activeFormat.minExposureDuration), kExposureMinimumDuration);
        float maxDurationSeconds = CMTimeGetSeconds(self.device.activeFormat.maxExposureDuration);
        float newDurationSeconds = p * ( maxDurationSeconds - minDurationSeconds ) + minDurationSeconds;
        
        [self.device setExposureModeCustomWithDuration:CMTimeMakeWithSeconds(newDurationSeconds, 1000*1000*1000) ISO:iso completionHandler:nil];
        [self.device setWhiteBalanceMode:AVCaptureWhiteBalanceModeLocked];
        
        [self.device unlockForConfiguration];
        result(@YES);
    }
    if (error) {
        result([FlutterError errorWithCode:@"Change exposure dureation exception"
                            message:[NSString stringWithFormat:@"%@", error]
                            details:nil]);
    }
    result(@NO);
}

-(float)normalizeISO:(float)iso {
    float newISO = MAX(self.device.activeFormat.minISO, iso);
    newISO = MIN(iso, self.device.activeFormat.maxISO);
    
    return newISO;
}

-(CMTime)minExposureDuration{
    return [self.device activeFormat].minExposureDuration;
}

-(CMTime)maxExposureDuration {
    return [self.device activeFormat].maxExposureDuration;
}

-(AVCaptureExposureMode)getExposureMode {
    return [self.device exposureMode];
}

-(float)getExposureTargetOffset {
    return [self.device exposureTargetOffset];
}

-(float)getExposureTargetBias {
    return [self.device exposureTargetBias];
}

-(float)getMaxExposureTargetBias {
    return [self.device maxExposureTargetBias];
}

-(float)getMinExposureTargetBias{
    return [self.device minExposureTargetBias];
}


-(float)getISO {
    return self.device.ISO;
}


-(CMTime)getExposureDuration {
    return [self.device exposureDuration];
}

-(NSDictionary*)getExposureDurationSeconds {
    CMTime duration = [self getExposureDuration];
    
    return [self getExposureDurationSeconds:duration];
}

-(NSDictionary*)getExposureDurationSeconds:(CMTime) duration {
    CMTime min = [self.device activeFormat].minExposureDuration;
    CMTime max = [self.device activeFormat].maxExposureDuration;
    
    NSUInteger exposureDurationSeconds = CMTimeGetSeconds(duration);
    NSUInteger minExposureDurationSeconds = MAX(CMTimeGetSeconds(min), kExposureMinimumDuration);
    NSUInteger maxExposureDurationSeconds = CMTimeGetSeconds(max);
    // Map from duration to non-linear UI range 0-1
    float p = (exposureDurationSeconds - minExposureDurationSeconds) / (maxExposureDurationSeconds - minExposureDurationSeconds); // Scale to 0-1
    float value = pow(p, 1 / kExposureDurationPower);

    return @{@"duration": [NSNumber numberWithFloat:value],@"value": [NSNumber numberWithInteger:duration.value], @"timescale": [NSNumber numberWithInteger:duration.timescale], @"seconds": [NSNumber numberWithFloat:exposureDurationSeconds]};
}

-(void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    id oldValue = [change valueForKey:NSKeyValueChangeOldKey];
    id newValue = [change valueForKey:NSKeyValueChangeNewKey];

    if (oldValue == newValue) return;
    
    if ([keyPath isEqual:@"exposureMode"]) {
        if (self.exposureModeHandler && self.exposureModeHandler.sink) {
            self.exposureModeHandler.sink(newValue);
        }
    } else if ([keyPath isEqual:@"exposureDuration"]) {
        if (self.exposureDurationHandler && self.exposureDurationHandler.sink) {
            NSValue *value = newValue;
            CMTime time;
            [value getValue:&time];
            NSDictionary *data = [self getExposureDurationSeconds:time];
            self.exposureDurationHandler.sink(data);
        }
    } else if ([keyPath isEqual:@"ISO"]) {
        if (self.ISOHandler && self.ISOHandler.sink) {
            self.ISOHandler.sink(newValue);
        }
    } else if ([keyPath isEqual:@"exposureTargetBias"]) {
        if (self.exposureTargetBiasHandler && self.exposureTargetBiasHandler.sink) {
            self.exposureTargetBiasHandler.sink(newValue);
        }
    } else if ([keyPath isEqual:@"exposureTargetOffset"]) {
        if (self.exposureTargetOffsetHandler && self.exposureTargetOffsetHandler.sink) {
            self.exposureTargetOffsetHandler.sink(newValue);
        }
    } else {
        NSLog(@"changedDevice");
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end
