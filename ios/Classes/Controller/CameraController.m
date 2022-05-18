//
//  CameraController.m
//  video_settings
//
//  Created by Denys Dudka on 18.05.2022.
//

#import "CameraController.h"

@implementation CameraController

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
    if ([name isEqual:@"AVCaptureDeviceTypeBuiltInWideAngleCamera"]) {
        if (@available(iOS 10.0, *)) {
            return [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInWideAngleCamera mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionBack];
        }
    }
    if (@available(iOS 13.0, *)) {
        if ([name isEqual:@"AVCaptureDeviceTypeBuiltInUltraWideCamera"]) {
            
            return [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInUltraWideCamera mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionBack];
        }
    }
    if ([name isEqual:@"AVCaptureDeviceTypeBuiltInTelephotoCamera"]) {
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
        [array addObject:device];
    }
    return array;
}


@end
