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

-(void)handleMethodCall:(FlutterMethodCall*)call
                 result:(FlutterResult)result {
    if ([@"WhiteBalanceController/init" isEqualToString:call.method]) {
        NSDictionary* argsMap = call.arguments;
        NSString* deviceId = (NSString*)argsMap[@"deviceId"];
        
        [self init: deviceId];
        result(@YES);
    } else if ([@"ExposureController/dispose" isEqualToString:call.method]) {
        [self removeObservers];
        result(@YES);
    } else if ([@"WhiteBalanceController/getWhiteBalanceMode" isEqualToString:call.method]) {
        AVCaptureWhiteBalanceMode mode = [self getWhiteBalanceMode];
        result(@(mode));
    } else if ([@"WhiteBalanceController/isWhiteBalanceLockSupported" isEqualToString:call.method]) {
        BOOL value = [self isWhiteBalanceLockSupported];
        
        result([NSNumber numberWithBool:value]);
    } else if ([@"WhiteBalanceController/isWhiteBalanceModeSupported" isEqualToString:call.method]) {
        NSDictionary* argsMap = call.arguments;
        NSNumber *mode = argsMap[@"mode"];
        
        BOOL helpResult = [self isWhiteBalanceModeSupported:[mode intValue]];
        result([NSNumber numberWithBool:helpResult]);
    } else if ([@"WhiteBalanceController/getSupportedWhiteBalanceMode" isEqualToString:call.method]) {
        NSArray *value = [self getSupportedWhiteBalanceMode];
        
        result(value);
    } else if ([@"WhiteBalanceController/setWhiteBalanceMode" isEqualToString:call.method]) {
        NSDictionary* argsMap = call.arguments;
        NSNumber *mode = argsMap[@"mode"];
        
        [self setWhiteBalanceMode:[mode intValue] result:result];
    } else if ([@"WhiteBalanceController/changeWhiteBalanceGains" isEqualToString:call.method]) {
        NSDictionary* argsMap = call.arguments;
        AVCaptureWhiteBalanceGains gains;
        gains.greenGain = [argsMap[@"greenGain"] floatValue];
        gains.redGain = [argsMap[@"redGain"] floatValue];
        gains.blueGain = [argsMap[@"blueGain"] floatValue];
        
        [self setWhiteBalanceGains:gains result:result];
    } else if ([@"WhiteBalanceController/changeWhiteBalanceTemperatureAndTint" isEqualToString:call.method]) {
        NSDictionary* argsMap = call.arguments;
        NSNumber *temperature = argsMap[@"temperature"];
        NSNumber *tint = argsMap[@"tint"];
        
        [self changeWhiteBalanceTemperature:[temperature floatValue] tint:[tint floatValue] result:result];
    } else if ([@"WhiteBalanceController/lockWithGrayWorld" isEqualToString:call.method]) {
        [self lockWithGrayWorld:result];
    } else if ([@"WhiteBalanceController/getMaxBalanceGains" isEqualToString:call.method]) {
        float helpResult = [self getMaxBalanceGains];
        result([NSNumber numberWithFloat: helpResult]);
    } else if ([@"WhiteBalanceController/getCurrentBalanceGains" isEqualToString:call.method]) {
        AVCaptureWhiteBalanceGains gains = [self getCurrentBalanceGains];
        result(@{@"redGain": [NSNumber numberWithFloat: gains.redGain], @"blueGain": [NSNumber numberWithFloat: gains.blueGain], @"greenGain": [NSNumber numberWithFloat: gains.greenGain]});
    } else if ([@"WhiteBalanceController/getCurrentTemperatureBalanceGains" isEqualToString:call.method]) {
        AVCaptureWhiteBalanceTemperatureAndTintValues gains = [self getCurrentTemperatureBalanceGains];
        result(@{@"tint": [NSNumber numberWithFloat: gains.tint], @"temperature": [NSNumber numberWithFloat: gains.temperature]});
    } else if ([@"WhiteBalanceController/convertDeviceGainsToTemperature" isEqualToString:call.method]) {
        NSDictionary* argsMap = call.arguments;
        AVCaptureWhiteBalanceGains deviceGains;
        deviceGains.greenGain = [argsMap[@"greenGain"] floatValue];
        deviceGains.redGain = [argsMap[@"redGain"] floatValue];
        deviceGains.blueGain = [argsMap[@"blueGain"] floatValue];
        
        AVCaptureWhiteBalanceTemperatureAndTintValues gains = [self.device temperatureAndTintValuesForDeviceWhiteBalanceGains:deviceGains];
        result(@{@"tint": [NSNumber numberWithFloat: gains.tint], @"temperature": [NSNumber numberWithFloat: gains.temperature]});
    } else {
        result(nil);
    }
}

-(void)registerAdditionalHandlers:(NSObject<FlutterPluginRegistrar>*)registrar {
    if (self.whiteBalanceModeHandler && self.whiteBalanceGainsHandler) {
        return;
    }
    
    self.whiteBalanceModeHandler = [[FlutterSinkHandler alloc]init];
    self.whiteBalanceGainsHandler = [[FlutterSinkHandler alloc]init];
    
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
    if (@available(iOS 10.0, *)) {
        self.device = [VideoSettingsPlugin deviceByUniqueID: deviceId];
    }
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
    result(@NO);
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
