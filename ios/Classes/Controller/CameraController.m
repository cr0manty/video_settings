//
//  CameraController.m
//  video_settings
//
//  Created by Denys Dudka on 18.05.2022.
//

#import "CameraController.h"

#if TARGET_OS_IPHONE
#import <Flutter/Flutter.h>
#elif TARGET_OS_MAC
#import <FlutterMacOS/FlutterMacOS.h>
#endif

@implementation CameraController

-(void)handleMethodCall:(FlutterMethodCall*)call
                 result:(FlutterResult)result {
    if ([@"CameraController/defaultDevice" isEqualToString:call.method]) {
        AVCaptureDevice *device = [self defaultDevice];
        if (!device) {
            result([FlutterError errorWithCode:@"Camera device not found"
                                message:@""
                                details:nil]);
        }
        NSDictionary *data = [self parseDevice:device];
        result(data);
    } else if ([@"CameraController/deviceWithPosition" isEqualToString:call.method]) {
        NSDictionary* argsMap = call.arguments;
        NSNumber *position = argsMap[@"position"];
        NSString *typeName = (NSString*)argsMap[@"type"];
        
        if (@available(iOS 10.0, *)) {
            AVCaptureDeviceType type = [self typeByName:typeName];
            
            AVCaptureDevice *device = [self deviceWithPosition:(AVCaptureDevicePosition)position deviceType:type];
            if (!device) {
                result([FlutterError errorWithCode:@"Camera device not found"
                                    message:@""
                                    details:nil]);
            }
            NSDictionary *data = [self parseDevice:device];
            result(data);
        } else {
            result(nil);
        }
    } else if ([@"CameraController/enumerateDevices" isEqualToString:call.method]) {
        NSArray *array = [self enumerateDevices];
        
        result(array);
    } else if ([@"CameraController/deviceWithUniqueId" isEqualToString:call.method]) {
        NSDictionary* argsMap = call.arguments;
        NSString *uniqueID = argsMap[@"id"];
        
        AVCaptureDevice *device = [self deviceWithUniqueID:uniqueID];
        if (!device) {
            result([FlutterError errorWithCode:@"Camera device not found"
                                message:@""
                                details:nil]);
        }
        NSDictionary *data = [self parseDevice:device];
        result(data);
    } else if ([@"CameraController/getCameraByType" isEqualToString:call.method]) {
        NSDictionary* argsMap = call.arguments;
        NSString *nativeName = argsMap[@"nativeName"];
        
        if (@available(iOS 10.0, *)) {
            AVCaptureDeviceType type = [self typeByName:nativeName];
            if (!type) {
                result([FlutterError errorWithCode:@"Invalid AVCaptureDeviceType not found"
                                    message:@""
                                    details:nil]);
            }
            AVCaptureDevice *device = [self deviceWithPosition:AVCaptureDevicePositionBack deviceType:type];
            if (!device) {
                result([FlutterError errorWithCode:@"Camera device not found"
                                    message:@""
                                    details:nil]);
            }
            
            NSDictionary *data = [self parseDevice:device];
            result(data);
        } else {
            result(nil);
        }
    } else if ([@"CameraController/getCameraLensAmount" isEqualToString:call.method]) {
        int lensAmount = [self cameraLensAmount];
        
        result([NSNumber numberWithInt:lensAmount]);
    } else if ([@"CameraController/getSupportedCameraLens" isEqualToString:call.method]) {
        NSArray *array = [self getSupportedCameraLens];
        
        result(array);
    } else if ([@"CameraController/getExtendedCameraDevice" isEqualToString:call.method]) {
        NSDictionary* argsMap = call.arguments;
        NSString *nativeName = argsMap[@"nativeName"];
        
        if (@available(iOS 10.0, *)) {
            AVCaptureDeviceType type = [self typeByName:nativeName];
            
            AVCaptureDevice *device = [self deviceWithPosition:AVCaptureDevicePositionBack deviceType:type];
            if (!device) {
                result([FlutterError errorWithCode:@"Camera device not found"
                                    message:@""
                                    details:nil]);
            }
            
            NSDictionary *data = [self parseDevice:device];
            result(data);
        } else {
            result(nil);
        }
    } else {
        result(nil);
    }
}

-(AVCaptureDeviceType)typeByName:(NSString*)name API_AVAILABLE(ios(10.0)) {
    if ([@"WideAngleCamera" isEqualToString:name]) {
        return AVCaptureDeviceTypeBuiltInWideAngleCamera;
    } else if ([@"TelephotoCamera" isEqualToString:name]) {
        return AVCaptureDeviceTypeBuiltInTelephotoCamera;
    } else if ([@"UltraWideCamera" isEqualToString:name]) {
        if (@available(iOS 13.0, *)) {
            return AVCaptureDeviceTypeBuiltInUltraWideCamera;
        }
    } else if ([@"InDualCamera" isEqualToString:name]) {
        if (@available(iOS 10.2, *)) {
            return AVCaptureDeviceTypeBuiltInDualCamera;
        }
    } else if ([@"DualWideCamera" isEqualToString:name]) {
        if (@available(iOS 13.0, *)) {
            return AVCaptureDeviceTypeBuiltInDualWideCamera;
        }
    } else if ([@"TripleCamera" isEqualToString:name]) {
        if (@available(iOS 13.0, *)) {
            return AVCaptureDeviceTypeBuiltInTripleCamera;
        }
    } else if ([@"TrueDepthCamera" isEqualToString:name]) {
        if (@available(iOS 11.1, *)) {
            return AVCaptureDeviceTypeBuiltInTrueDepthCamera;
        }
    } else if ([@"LiDARDepthCamera" isEqualToString:name]) {
        if (@available(iOS 15.4, *)) {
            return AVCaptureDeviceTypeBuiltInLiDARDepthCamera;
        }
    }
    
    return nil;
}

-(NSDictionary*)parseDevice:(AVCaptureDevice*)device {
    NSString *type;
    
    if (@available(iOS 10.0, *)) {
        type = device.deviceType;
    }
    
    return @{
        @"uniqueID": device.uniqueID,
        @"deviceType": type,
        @"localizedName": device.localizedName,
    };
}

-(int)cameraLensAmount {
    if (@available(iOS 13.0, *)) {
        if ([AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInTripleCamera mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionBack]) {
            return 3;
        }
    } else if (@available(iOS 10.2, *)) {
        if ([AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInDualCamera mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionBack]) {
            return 2;
        }
    }
    return 1;
}

+(AVCaptureDevice *)getCameraWithPosition:(AVCaptureDevicePosition)position {
    if (position == AVCaptureDevicePositionUnspecified) {
        return [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    }
    
    NSArray<AVCaptureDevice*> *devices = [AVCaptureDevice devices];
    
    for(AVCaptureDevice *device in devices) {
        if (device.position == position) {
            return device;
        }
    }
    return devices[0];
}

-(AVCaptureDevice*)getWideAngleCamera {
    if (@available(iOS 10.0, *)) {
        return [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInWideAngleCamera mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionBack];
    }
    
    return nil;
}

-(AVCaptureDevice*)getUltraWideCamera {
    if (@available(iOS 13.0, *)) {
        return [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInUltraWideCamera mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionBack];
    }
    
    return nil;
}

-(AVCaptureDevice*)getTelephotoCamera {
    if (@available(iOS 10.0, *)) {
        return [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInTelephotoCamera mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionBack];
    }
    
    return nil;
}

-(NSArray*)getSupportedCameraLens {
    NSMutableArray *data = [[NSMutableArray alloc] init];
    
    if (@available(iOS 10.0, *)) {
        if ([AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInWideAngleCamera mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionBack]) {
            [data addObject:AVCaptureDeviceTypeBuiltInWideAngleCamera];
        }
    }

    if (@available(iOS 10.0, *)) {
        if ([AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInTelephotoCamera mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionBack]) {
            [data addObject:AVCaptureDeviceTypeBuiltInTelephotoCamera];
        }
    }
    
    if (@available(iOS 13.0, *)) {
        if ([AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInUltraWideCamera mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionBack]) {
            
            [data addObject:AVCaptureDeviceTypeBuiltInUltraWideCamera];
        }
    }
    
    return data;
}

-(AVCaptureDevice*)getCameraByName:(NSString*)name {
    if ([name isEqual:@"WideAngleCamera"]) {
        if (@available(iOS 10.0, *)) {
            return [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInWideAngleCamera mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionBack];
        }
    }
    if (@available(iOS 13.0, *)) {
        if ([name isEqual:@"UltraWideCamera"]) {
            
            return [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInUltraWideCamera mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionBack];
        }
    }
    if ([name isEqual:@"TelephotoCamera"]) {
        if (@available(iOS 10.0, *)) {
            return [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInTelephotoCamera mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionBack];
        }
    }
    return nil;
}

-(AVCaptureDevice*)defaultDevice {
    return [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
}

-(AVCaptureDevice*)deviceWithPosition:(AVCaptureDevicePosition)position
                           deviceType: (AVCaptureDeviceType)type  API_AVAILABLE(ios(10.0)) {
    return [AVCaptureDevice defaultDeviceWithDeviceType:type mediaType:AVMediaTypeVideo position:position];
}

-(AVCaptureDevice*)deviceWithUniqueID:(NSString*)uniqueID {
    return [AVCaptureDevice deviceWithUniqueID: uniqueID];
}

-(NSArray*)enumerateDevices {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    for (AVCaptureDevice *device in [AVCaptureDevice devices]) {
        NSDictionary *data = [self parseDevice:device];
        [array addObject:data];
    }
    return array;
}


@end
