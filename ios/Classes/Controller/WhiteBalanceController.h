//
//  WhiteBalanceController.h
//  video_settings
//
//  Created by Denys Dudka on 18.05.2022.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

#import "FlutterSinkHandler.h"

NS_ASSUME_NONNULL_BEGIN

@protocol FlutterPluginRegistrar;
typedef void (^FlutterResult)(id _Nullable result);

@interface WhiteBalanceController : NSObject
@property (nonatomic, strong) AVCaptureDevice *device;
@property (nonatomic, strong) FlutterSinkHandler* whiteBalanceModeHandler;
@property (nonatomic, strong) FlutterSinkHandler* whiteBalanceGainsHandler;

-(void)registerAdditionalHandlers:(NSObject<FlutterPluginRegistrar>*)registrar;

-(void)handleMethodCall:(FlutterMethodCall*)call
                 result:(FlutterResult)result;

-(void)init:(NSString*)deviceId;

-(void)addObservers;

-(void)removeObservers;

-(AVCaptureWhiteBalanceMode)getWhiteBalanceMode;

-(NSArray*)getSupportedWhiteBalanceMode;

-(BOOL)isWhiteBalanceModeSupported:(NSInteger)modeNum;

-(BOOL)isWhiteBalanceLockSupported;

-(void)setWhiteBalanceMode:(NSInteger)modeNum
                    result:(FlutterResult)result;

-(void)setWhiteBalanceGains:(AVCaptureWhiteBalanceGains)gains
                     result:(FlutterResult)result;

-(void)changeWhiteBalanceTemperature:(float)temperature
                                tint:(float)tint
                              result:(FlutterResult)result;

-(AVCaptureWhiteBalanceGains)normalizedGains:(AVCaptureWhiteBalanceGains)gains;

-(void)lockWithGrayWorld:(FlutterResult)result;

-(float)getMaxBalanceGains;

-(AVCaptureWhiteBalanceGains)getCurrentBalanceGains;

-(AVCaptureWhiteBalanceTemperatureAndTintValues)getCurrentTemperatureBalanceGains;

@end

NS_ASSUME_NONNULL_END
