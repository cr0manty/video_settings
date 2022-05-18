//
//  ZoomController.m
//  video_settings
//
//  Created by Denys Dudka on 18.05.2022.
//

#import "ZoomController.h"
#import "VideoSettingsPlugin.h"

#if TARGET_OS_IPHONE
#import <Flutter/Flutter.h>
#elif TARGET_OS_MAC
#import <FlutterMacOS/FlutterMacOS.h>
#endif

@implementation ZoomController

-(void)init:(NSString*)deviceId {
    self.device = [VideoSettingsPlugin deviceByUniqueID: deviceId];
}

-(void)setZoom:(NSInteger)zoom
        result:(FlutterResult) result {
    NSError *error;
    
    if([self.device lockForConfiguration:&error]) {
        [self.device setVideoZoomFactor:zoom];
        [self.device unlockForConfiguration];
        result(@YES);
    }
    
    if (error) {
        result([FlutterError errorWithCode:@"Set Zoom excetion"
                            message:[NSString stringWithFormat:@"%@", error]
                            details:nil]);
    }
    
    return result(@NO);
}

-(float)getMaxZoomFactor {
    if (@available(iOS 11.0, *)) {
        return [self.device maxAvailableVideoZoomFactor];
    }
    return 2;
}

-(float)getMinZoomFactor {
    if (@available(iOS 11.0, *)) {
        return [self.device minAvailableVideoZoomFactor];
    }
    
    return 1;
}

-(float)getZoomFactor {
    return [self.device videoZoomFactor];
}

@end
