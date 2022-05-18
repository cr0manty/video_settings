//
//  ExposureController.h
//  Pods-Runner
//
//  Created by Denys Dudka on 18.05.2022.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

#import "FlutterDataHandler.h"

NS_ASSUME_NONNULL_BEGIN


@protocol FlutterPluginRegistrar;

typedef void (^FlutterResult)(id _Nullable result);


@interface ExposureController: NSObject
@property (nonatomic, strong) AVCaptureDevice *device;
@property (nonatomic, strong) FlutterSinkDataHandler* exposureModeHandler;
@property (nonatomic, strong) FlutterSinkDataHandler* exposureDurationHandler;
@property (nonatomic, strong) FlutterSinkDataHandler* ISOHandler;
@property (nonatomic, strong) FlutterSinkDataHandler* exposureTargetBiasHandler;
@property (nonatomic, strong) FlutterSinkDataHandler* exposureTargetOffsetHandler;

-(void)registerAdditionalHandlers:(NSObject<FlutterPluginRegistrar>*)registrar;

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
