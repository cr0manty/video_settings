//
//  CameraController.h
//  video_settings
//
//  Created by Denys Dudka on 18.05.2022.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN


@interface CameraController : NSObject

-(AVCaptureDevice*)deviceWithPosition:(AVCaptureDevicePosition)position
                           deviceType: (AVCaptureDeviceType)type API_AVAILABLE(ios(10.0));

-(int)cameraLensAmount;

-(AVCaptureDevice*)getWideAngleCamera;

-(AVCaptureDevice*)getUltraWideCamera;

-(AVCaptureDevice*)getTelephotoCamera;

-(NSArray*)getSupportedCameraLens;

-(AVCaptureDevice*)getCameraByName:(NSString*)name;

-(AVCaptureDevice*)defaultDevice;

-(AVCaptureDevice*)deviceWithUniqueID:(NSString*)uniqueID;

-(NSArray*)enumerateDevices;


@end

NS_ASSUME_NONNULL_END
