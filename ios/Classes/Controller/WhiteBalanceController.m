//
//  WhiteBalanceController.m
//  video_settings
//
//  Created by Denys Dudka on 18.05.2022.
//

#import "WhiteBalanceController.h"
#import "FlutterDataHandler.h"
#import "VideoSettingsPlugin.h"

#if TARGET_OS_IPHONE
#import <Flutter/Flutter.h>
#elif TARGET_OS_MAC
#import <FlutterMacOS/FlutterMacOS.h>
#endif

@implementation WhiteBalanceController

-(void)registerAdditionalHandlers:(NSObject<FlutterPluginRegistrar>*)registrar {
    if (self.whiteBalanceModeHandler && self.whiteBalanceGainsHandler) {
        return;
    }
    
    self.whiteBalanceModeHandler = [[FlutterSinkDataHandler alloc]init];
    self.whiteBalanceGainsHandler = [[FlutterSinkDataHandler alloc]init];
    
    FlutterEventChannel* whiteBalanceModeChannel = [FlutterEventChannel
                                                    eventChannelWithName:@"WhiteBalanceController/modeChannel"
                                                    binaryMessenger: [registrar messenger]];
    FlutterEventChannel* whiteBalanceGainsChannel = [FlutterEventChannel
                                                     eventChannelWithName:@"WhiteBalanceController/gainsChannel"
                                                     binaryMessenger: [registrar messenger]];
    
    [whiteBalanceModeChannel setStreamHandler:self.whiteBalanceModeHandler];
    [whiteBalanceGainsChannel setStreamHandler:self.whiteBalanceGainsHandler];
}

-(void)init:(NSString*)deviceId {
    [self removeObservers];
    self.device = [VideoSettingsPlugin deviceByUniqueID: deviceId];
    [self addObservers];
}


-(void)addObservers {
    [self.device addObserver:self forKeyPath:@"whiteBalanceMode" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    [self.device addObserver:self forKeyPath:@"deviceWhiteBalanceGains" options:NSKeyValueObservingOptionNew context:nil];
}

-(void)removeObservers {
    if (!self.device) return;
    
    [self.device removeObserver:self forKeyPath:@"whiteBalanceMode" context:nil];
    [self.device removeObserver:self forKeyPath:@"deviceWhiteBalanceGains" context:nil];
}

-(AVCaptureWhiteBalanceMode)getWhiteBalanceMode {
    return [self.device whiteBalanceMode];
}

-(BOOL)isWhiteBalanceLockSupported {
    if (@available(iOS 10.0, *)) {
        return [self.device isLockingWhiteBalanceWithCustomDeviceGainsSupported];
    }
    
    return FALSE;
}

-(NSArray*)getSupportedWhiteBalanceMode {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    if ([self.device isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeLocked]) {
        [array addObject:[NSNumber numberWithInteger:AVCaptureWhiteBalanceModeLocked]];
    }
    
    if ([self.device isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeAutoWhiteBalance]) {
        [array addObject:[NSNumber numberWithInteger:AVCaptureWhiteBalanceModeAutoWhiteBalance]];
    }
    
    if ([self.device isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance]) {
        [array addObject:[NSNumber numberWithInteger:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance]];
    }
    
    return array;
}

-(BOOL)isWhiteBalanceModeSupported:(NSInteger)modeNum {
    AVCaptureWhiteBalanceMode mode = (AVCaptureWhiteBalanceMode)modeNum;
    
    return [self.device isWhiteBalanceModeSupported:mode];
}

-(void)setWhiteBalanceMode:(NSInteger)modeNum result:(FlutterResult)result {
    AVCaptureWhiteBalanceMode mode = (AVCaptureWhiteBalanceMode)modeNum;
    
    if (![self.device isWhiteBalanceModeSupported:mode]) {
        result(@NO);
    }
    
    NSError *error;
    if ([self.device lockForConfiguration:&error]) {
        [self.device setWhiteBalanceMode:mode];
        [self.device unlockForConfiguration];
        result(@YES);
    }
    
    if (error) {
        result([FlutterError errorWithCode:@"Set white balance mode excetion"
                            message:[NSString stringWithFormat:@"%@", error]
                            details:nil]);
    }
    
    result(@NO);
}

-(void)setWhiteBalanceGains:(AVCaptureWhiteBalanceGains)gains result:(FlutterResult)result {
    
    if ([self.device isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeLocked]) {
        NSError *error = nil;
        
        if([self.device lockForConfiguration:&error]) {
            AVCaptureWhiteBalanceGains normilizedGains = [self normalizedGains: gains];
            
            [self.device setWhiteBalanceModeLockedWithDeviceWhiteBalanceGains:normilizedGains completionHandler:nil];
            
            [self.device unlockForConfiguration];
            result(@YES);
        }
        if (error) {
            result([FlutterError errorWithCode:@"Set white balance gains excetion"
                                message:[NSString stringWithFormat:@"%@", error]
                                details:nil]);
        }
    }
    return FALSE;
}

-(void)changeWhiteBalanceTemperature:(float)temperature
                                tint:(float)tint
                              result:(FlutterResult)result {
    AVCaptureWhiteBalanceTemperatureAndTintValues gains;
    gains.temperature = temperature;
    gains.tint = tint;
    
    AVCaptureWhiteBalanceGains normalGains = [self.device deviceWhiteBalanceGainsForTemperatureAndTintValues:gains];
    
    [self setWhiteBalanceGains:normalGains result:result];
}


-(float)getMaxBalanceGains {
    return self.device.maxWhiteBalanceGain;
}

-(AVCaptureWhiteBalanceGains)getCurrentBalanceGains {
    AVCaptureWhiteBalanceGains gains = self.device.deviceWhiteBalanceGains;
    AVCaptureWhiteBalanceGains normalizedGains = [self normalizedGains:gains];
    
    return normalizedGains;
}

-(AVCaptureWhiteBalanceTemperatureAndTintValues)getCurrentTemperatureBalanceGains {
    AVCaptureWhiteBalanceGains gains = self.device.deviceWhiteBalanceGains;
    AVCaptureWhiteBalanceGains normalizedGains = [self normalizedGains:gains];
    
    return [self.device temperatureAndTintValuesForDeviceWhiteBalanceGains:normalizedGains];
}

-(AVCaptureWhiteBalanceGains)normalizedGains:(AVCaptureWhiteBalanceGains) gains {
    AVCaptureWhiteBalanceGains g = gains;
    
    g.redGain = MAX(1.0, g.redGain);
    g.greenGain = MAX(1.0, g.greenGain);
    g.blueGain = MAX(1.0, g.blueGain);
    
    g.redGain = MIN(self.device.maxWhiteBalanceGain, g.redGain);
    g.greenGain = MIN(self.device.maxWhiteBalanceGain, g.greenGain);
    g.blueGain = MIN(self.device.maxWhiteBalanceGain, g.blueGain);
    
    return g;
}

-(void)lockWithGrayWorld:(FlutterResult)result {
    AVCaptureWhiteBalanceGains gains = [self.device grayWorldDeviceWhiteBalanceGains];
    [self setWhiteBalanceGains:gains result:result];
}

-(void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    id oldValue = [change valueForKey:NSKeyValueChangeOldKey];
    id newValue = [change valueForKey:NSKeyValueChangeNewKey];

    if (oldValue == newValue) return;
    
    if ([keyPath isEqual:@"whiteBalanceMode"]) {
        if (self.whiteBalanceModeHandler && self.whiteBalanceModeHandler.sink) {
            self.whiteBalanceModeHandler.sink(newValue);
        }
    } else if ([keyPath isEqual:@"deviceWhiteBalanceGains"]) {
        NSValue *value = newValue;
        AVCaptureWhiteBalanceGains gains;
        [value getValue:&gains];

        if (self.whiteBalanceGainsHandler && self.whiteBalanceGainsHandler.sink) {
            self.whiteBalanceGainsHandler.sink(@{@"redGain": [NSNumber numberWithFloat: gains.redGain], @"blueGain": [NSNumber numberWithFloat: gains.blueGain], @"greenGain": [NSNumber numberWithFloat: gains.greenGain]});
        }
    } else {
        NSLog(@"changedDevice");
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end
