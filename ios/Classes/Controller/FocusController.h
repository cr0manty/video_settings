//
//  FocusController.h
//  video_settings
//
//  Created by Denys Dudka on 18.05.2022.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

#import "FlutterSinkHandler.h"

NS_ASSUME_NONNULL_BEGIN


@interface FocusController : NSObject
@property (nonatomic, strong) AVCaptureDevice *device;
@property (nonatomic, strong) FlutterSinkHandler* focusModeHandler;
@property (nonatomic, strong) FlutterSinkHandler* focusLensPositionHandler;

-(void)registerAdditionalHandlers:(NSObject<FlutterPluginRegistrar>*)registrar;

-(void)handleMethodCall:(FlutterMethodCall*)call
                 result:(FlutterResult)result;

-(void)init:(NSString*)deviceId;

-(void)addObservers;

-(void)removeObservers;

-(BOOL)isFocusModeSupported:(NSInteger)modeNum;

-(BOOL)isLockingFocusWithCustomLensPositionSupported;

-(AVCaptureFocusMode)getFocusMode;

-(NSArray*)getSupportedFocusMode;

-(BOOL)isFocusPointOfInterestSupported;

-(void)setFocusMode:(NSInteger)modeNum
             result:(FlutterResult)result;

-(void)setFocusPoint:(CGPoint)point
              result:(FlutterResult)result;

-(void)setFocusPointLocked:(float)lensPosition
                    result:(FlutterResult)result;

-(float)getFocusPointLocked;

-(CGPoint)getCGPointForCoordWithOrientation:(UIDeviceOrientation)orientation
                                            x:(double)x
                                            y:(double)y;

-(void)applyExposureMode;

@end

NS_ASSUME_NONNULL_END
