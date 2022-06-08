//
//  PermissionHandler.h
//  video_settings
//
//  Created by Denys Dudka on 19.05.2022.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^FlutterResult)(id _Nullable result);
@class FlutterMethodCall;



@interface PermissionHandler : NSObject

-(void)handleMethodCall:(FlutterMethodCall*)call
                 result:(FlutterResult)result;

-(void)requestAccessToCamera:(FlutterResult)result;

@end

NS_ASSUME_NONNULL_END
