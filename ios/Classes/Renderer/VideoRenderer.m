//
//  VideoRenderer.m
//  Pods-Runner
//
//  Created by Denys Dudka on 19.05.2022.
//

#import <stdatomic.h>
#import "VideoRenderer.h"
#import "VideoSettingsPlugin.h"

#define kOrientation AVCaptureVideoOrientationPortrait

@interface VideoRenderer() <AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate> {
    AVCaptureConnection *audioConnection;
    AVCaptureConnection *videoConnection;
    
    AVCaptureDeviceInput *videoInput;
}
@end


@implementation VideoRenderer{
    BOOL _active;
    dispatch_queue_t _dispatch_queue;
    CVPixelBufferRef _Atomic _pixelBuffer;
    CVPixelBufferRef _pixelBufferSource;
    FlutterEventChannel* _eventChannel;
    AVCapturePhotoOutput* _stillImageOutput;
  }

-(void)handleMethodCall:(FlutterMethodCall*)call
                 result:(FlutterResult)result {
    if ([@"VideoRenderer/init" isEqualToString:call.method]) {
        NSDictionary* argsMap = call.arguments;
        NSString* deviceId = (NSString*)argsMap[@"deviceId"];
        _active = TRUE;
        
        [self setupVideo:deviceId];
        [self setupAudio];
        dispatch_queue_t globalQueue =  dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
        dispatch_async(globalQueue, ^{
            [self.capturesSession startRunning];
        });
        if (!self.textureId) {
            self.textureId = [self.registry registerTexture:self];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.registry textureFrameAvailable:self.textureId];
        });
        result([NSNumber numberWithLong: self.textureId]);
    } else if ([@"VideoRenderer/updateDevice" isEqualToString:call.method]) {
        NSDictionary* argsMap = call.arguments;
        NSString* deviceId = (NSString*)argsMap[@"deviceId"];
        
        [self updateDeviceWIthDeviceID:deviceId result:result];
    } else if ([@"VideoRenderer/dispose" isEqualToString:call.method]) {
        [self dispose];
        result(nil);
    }
}

-(instancetype)init:(id<FlutterTextureRegistry>)registrar
          messenger:(NSObject<FlutterBinaryMessenger>*)messenger {
    self = [super init];
    
    if (self) {
        _dispatch_queue =
              dispatch_queue_create("com.cr0manty.videoSettings.pixelBufferSynchronizationQueue", NULL);
        self.registry = registrar;
        self.capturesSession = [AVCaptureSession new];
        
        _eventChannel = [FlutterEventChannel
                             eventChannelWithName:[NSString stringWithFormat:@"VideoSettingsPlugin/Texture%lld", self.textureId]
                                       binaryMessenger:messenger];
        [_eventChannel setStreamHandler:self];
    }
    return self;
}

- (void)setupVideo:(NSString*)deviceID {
#if TARGET_IPHONE_SIMULATOR
    return;
#endif
    int fps = 60;
    AVCaptureDevice *device = [VideoSettingsPlugin deviceByUniqueID:deviceID];
    videoInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    if ([self.capturesSession canAddInput:videoInput]) {
        [self.capturesSession addInput:videoInput];
    }
    
    AVCaptureVideoDataOutput *videoOut = [[AVCaptureVideoDataOutput alloc] init];
    videoOut.alwaysDiscardsLateVideoFrames = YES;
    [videoOut setSampleBufferDelegate:self queue:_dispatch_queue];
    
    // Set the video output to store frame in BGRA (It is supposed to be faster)
//    videoOut.videoSettings = @{(id)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_32BGRA)};
    videoOut.videoSettings = @{(id)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)};

    if ([self.capturesSession canAddOutput:videoOut]) {
        [self.capturesSession addOutput:videoOut];
    }
    [self.capturesSession setSessionPreset:AVCaptureSessionPreset1280x720];
    videoConnection = [videoOut connectionWithMediaType:AVMediaTypeVideo];
    videoConnection.videoOrientation = kOrientation;
    videoConnection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeOff;
    
    // Setup camera capture mode
    for(AVCaptureDeviceFormat *vFormat in [device formats] ) {
        CMFormatDescriptionRef description= vFormat.formatDescription;
        CMVideoDimensions dim = CMVideoFormatDescriptionGetDimensions(description);
        float maxRate = ((AVFrameRateRange*) [vFormat.videoSupportedFrameRateRanges objectAtIndex:0]).maxFrameRate;
        if (maxRate >= fps && dim.width == 1280 && CMFormatDescriptionGetMediaSubType(description)==kCVPixelFormatType_420YpCbCr8BiPlanarFullRange) {
            if ([device lockForConfiguration:nil]) {
                NSLog(@"Set camera capture mode %@", vFormat);
                device.activeFormat = vFormat;
                device.activeVideoMinFrameDuration = CMTimeMake(100,100 * fps);
                device.activeVideoMaxFrameDuration = CMTimeMake(100,100 * fps);
                [device unlockForConfiguration];
                break;
            }
        }
    }
}

- (void)setupAudio {
    AVCaptureDevice *audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    AVCaptureDeviceInput *audioIn = [[AVCaptureDeviceInput alloc] initWithDevice:audioDevice error:nil];
    if ( [self.capturesSession canAddInput:audioIn] ) {
        [self.capturesSession addInput:audioIn];
    }
    
    AVCaptureAudioDataOutput *audioOut = [[AVCaptureAudioDataOutput alloc] init];
    [audioOut setSampleBufferDelegate:self queue:_dispatch_queue];
    
    if ( [self.capturesSession canAddOutput:audioOut] ) {
        [self.capturesSession addOutput:audioOut];
    }
    audioConnection = [audioOut connectionWithMediaType:AVMediaTypeAudio];
}


-(void)updateDeviceWIthDeviceID:(NSString*)deviceID result:(FlutterResult)result {
    AVCaptureDevice *device = [VideoSettingsPlugin deviceByUniqueID:deviceID];
    NSError *error;
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device
                                                                        error:&error];
    dispatch_queue_t globalQueue =  dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    dispatch_async(globalQueue, ^{
        [self.capturesSession beginConfiguration];
    });
    
    if (error) {
        result([FlutterError errorWithCode:@"Error update camera device"
                            message:[NSString stringWithFormat:@"%@", error]
                            details:nil]);
    }
    
    for (AVCaptureDeviceInput *inputElement in self.capturesSession.inputs) {
        if (inputElement == videoInput) {
            [self.capturesSession removeInput:inputElement];
        }
    }
    
    if ([self.capturesSession canAddInput:input]) {
        [self.capturesSession addInput:input];
        
    }
    dispatch_async(globalQueue, ^{
        [self.capturesSession commitConfiguration];
    });
    
    result(nil);
}

-(void)dispose {
    
    if (_active) {
      _active = NO;
      [self.registry unregisterTexture:_textureId];
      [self.capturesSession stopRunning];
        
      dispatch_barrier_sync(_dispatch_queue, ^{
        if (self->_pixelBufferSource) {
          CFRelease(self->_pixelBufferSource);
          self->_pixelBufferSource = nil;
        }
      });
      CVPixelBufferRef old = nil;
      atomic_exchange(&_pixelBuffer, old);
      if (old != nil) {
        CFRelease(old);
      }
    }
}

-(FlutterError * _Nullable)onCancelWithArguments:(id _Nullable)arguments {
    self.sink = nil;
    return nil;
}

-(FlutterError * _Nullable)onListenWithArguments:(id _Nullable)arguments eventSink:(nonnull FlutterEventSink)events {
    self.sink = events;
    return nil;
}




#pragma mark FlutterTexture

- (CVPixelBufferRef)copyPixelBuffer {
  CVPixelBufferRef pixelBuffer = _pixelBuffer;
  atomic_exchange(&_pixelBuffer, nil);
  return pixelBuffer;
}


#pragma mark - AVCaptureSession delegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection {
    _pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    [self.registry textureFrameAvailable:self.textureId];
}

@end
