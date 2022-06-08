//
//  ExposureController.h
//  Pods-Runner
//
//  Created by Denys Dudka on 18.05.2022.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

#import "FlutterSinkHandler.h"

NS_ASSUME_NONNULL_BEGIN


@protocol FlutterPluginRegistrar;


@interface ExposureController: NSObject
@property (nonatomic, strong) AVCaptureDevice *device;
@property (nonatomic, strong) FlutterSinkHandler* exposureModeHandler;
@property (nonatomic, strong) FlutterSinkHandler* exposureDurationHandler;
@property (nonatomic, strong) FlutterSinkHandler* ISOHandler;
@property (nonatomic, strong) FlutterSinkHandler* exposureTargetBiasHandler;
@property (nonatomic, strong) FlutterSinkHandler* exposureTargetOffsetHandler;

-(void)registerAdditionalHandlers:(NSObject<FlutterPluginRegistrar>*)registrar;

-(void)handleMethodCall:(FlutterMethodCall*)call
                 result:(FlutterResult)result;

-(void)init:(NSString*)deviceId;

-(NSDictionary*)getExposureDurationSeconds;

-(void)addObservers;

-(void)removeObservers;

-(BOOL)isExposureModeSupported:(NSInteger)modeNum;

-(NSArray*)getSupportedExposureMode;

-(void)setExposureMode:(NSInteger)modeNum
                   result:(FlutterResult)result;

-(AVCaptureExposureMode)getExposureMode;

-(void)changeISO:(float)value
          result:(FlutterResult)result;

-(float)getISO;

-(float)getMinISO;

-(float)getMaxISO;

-(float)getExposureTargetOffset;

-(void)changeBias:(float)value
           result:(FlutterResult)result;

-(float)getExposureTargetBias;

-(float)getMaxExposureTargetBias;

-(float)getMinExposureTargetBias;

-(CMTime)minExposureDuration;

-(CMTime)maxExposureDuration;

-(void)changeExposureDuration:(float)value
                       result:(FlutterResult)result;

-(float)normalizeISO:(float)iso;

-(CMTime)getExposureDuration;


@end

NS_ASSUME_NONNULL_END
