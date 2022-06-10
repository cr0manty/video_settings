//
//  ZoomController.h
//  video_settings
//
//  Created by Denys Dudka on 18.05.2022.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^FlutterResult)(id _Nullable result);
@class FlutterMethodCall;

@interface ZoomController : NSObject
@property (nonatomic, strong) AVCaptureDevice *_Nullable device;

-(instancetype)init;

-(void)handleMethodCall:(FlutterMethodCall*)call
                 result:(FlutterResult)result;

-(void)init:(NSString*)deviceId;

-(void)setZoom:(float)zoom
        result:(FlutterResult)result;

-(float)getMaxZoomFactor;

-(float)getMinZoomFactor;

-(float)getZoomFactor;


@end

NS_ASSUME_NONNULL_END
