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

@interface ZoomController : NSObject
@property (nonatomic, strong) AVCaptureDevice *device;

-(void)init:(NSString*)deviceId;

-(void)setZoom:(NSInteger)zoom
        result:(FlutterResult) result;

-(float)getMaxZoomFactor;

-(float)getMinZoomFactor;

-(float)getZoomFactor;


@end

NS_ASSUME_NONNULL_END
