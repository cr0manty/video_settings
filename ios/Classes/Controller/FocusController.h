//
//  FocusController.h
//  video_settings
//
//  Created by Denys Dudka on 18.05.2022.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

#import "FlutterDataHandler.h"

NS_ASSUME_NONNULL_BEGIN

@protocol FlutterPluginRegistrar;
typedef void (^FlutterResult)(id _Nullable result);


@interface FocusController : NSObject
@property (nonatomic, strong) AVCaptureDevice *device;
@property (nonatomic, strong) FlutterSinkDataHandler* focusModeHandler;
@property (nonatomic, strong) FlutterSinkDataHandler* focusLensPositionHandler;

-(void)registerAdditionalHandlers:(NSObject<FlutterPluginRegistrar>*)registrar;

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

-(CGPoint)getCGPointForCoordsWithOrientation:(UIDeviceOrientation)orientation
                                            x:(double)x
                                            y:(double)y;

-(void)applyExposureMode;

@end

NS_ASSUME_NONNULL_END
