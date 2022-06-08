//
//  VideoRenderer.m
//  Pods-Runner
//
//  Created by Denys Dudka on 19.05.2022.
//

#import <stdatomic.h>
#import "VideoRenderer.h"
#import "VideoSettingsPlugin.h"



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
        
        [self updateDeviceWIthDeviceID:deviceId result:result];
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
              dispatch_queue_create("com.cr0manty.videoSetiings.pixelBufferSynchronizationQueue", NULL);
        self.registry = registrar;
        self.capturesSession = [AVCaptureSession new];
        
        _eventChannel = [FlutterEventChannel
                             eventChannelWithName:[NSString stringWithFormat:@"VideoSettingsPlugin/Texture%lld", self.textureId]
                                       binaryMessenger:messenger];
        [_eventChannel setStreamHandler:self];
    }
    return self;
}

-(void)updateDeviceWIthDeviceID:(NSString*)deviceID result:(FlutterResult)result {
    AVCaptureDevice *device = [VideoSettingsPlugin deviceByUniqueID:deviceID];
    NSError *error;
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device
                                                                        error:&error];
    if (error) {
        result([FlutterError errorWithCode:@"Error update camera device"
                            message:[NSString stringWithFormat:@"%@", error]
                            details:nil]);
    }
    
    if (@available(iOS 10.0, *)) {
        _stillImageOutput = [AVCapturePhotoOutput new];
    } else {
        result([FlutterError errorWithCode:@"only available for ios 10 and higher"
                            message:[NSString stringWithFormat:@"%@", error]
                            details:nil]);
    }
    if ([self.capturesSession canAddInput:input] && [self.capturesSession canAddOutput:_stillImageOutput]) {
        [self.capturesSession addInput:input];
        [self.capturesSession addOutput:_stillImageOutput];
        
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
    }
    
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


- (void)setPixelBufferNoCopy:(CVPixelBufferRef)pixelBuffer {
  CVPixelBufferRef old = atomic_exchange(&_pixelBuffer, pixelBuffer);
  [_registry textureFrameAvailable:_textureId];
  if (old != nil) {
    CFRelease(old);
  }
}

- (void)storePixelBufferNoCopy:(CVPixelBufferRef)pixelBuffer {
  dispatch_barrier_sync(_dispatch_queue, ^{
    if (self->_pixelBufferSource) {
      CFRelease(self->_pixelBufferSource);
    }
    CFRetain(pixelBuffer);
    self->_pixelBufferSource = pixelBuffer;
  });

  CVPixelBufferRef old = atomic_exchange(&self->_pixelBuffer, _pixelBufferSource);
  [_registry textureFrameAvailable:_textureId];
  if (old != nil) {
    CFRelease(old);
  }
}

- (void)storePixelBuffer:(CVPixelBufferRef)pixelBuffer {
//  CVPixelBufferRef newPixelBuffer = _copyPixelBuffer(pixelBuffer);
  dispatch_barrier_sync(_dispatch_queue, ^{
    if (self->_pixelBufferSource) {
      CFRelease(self->_pixelBufferSource);
    }
    CFRetain(pixelBuffer);
    self->_pixelBufferSource = pixelBuffer;
  });

  CVPixelBufferRef old = atomic_exchange(&_pixelBuffer, _pixelBufferSource);
  [_registry textureFrameAvailable:_textureId];
  if (old != nil) {
    CFRelease(old);
  }
}

- (void)renderStoredPixelBuffer {
  if (!_active) return;

  dispatch_sync(_dispatch_queue, ^{
    if (self->_pixelBufferSource) {
      CFRetain(self->_pixelBufferSource);
      atomic_store(&self->_pixelBuffer, self->_pixelBufferSource);
      [self->_registry textureFrameAvailable:self->_textureId];
    }
  });
}

- (CVPixelBufferRef)getStoredPixelBuffer {
  __block CVPixelBufferRef pixelBuffer;
  dispatch_sync(_dispatch_queue, ^{
    pixelBuffer = self->_pixelBufferSource;
  });
  return pixelBuffer;
}

- (CGSize)getStoredImageSize {
  __block CGSize size;
  dispatch_sync(_dispatch_queue, ^{
    if (self->_pixelBufferSource) {
      size_t width = CVPixelBufferGetWidth(self->_pixelBufferSource);
      size_t height = CVPixelBufferGetHeight(self->_pixelBufferSource);
      size = CGSizeMake(width, height);
    } else {
      size = CGSizeZero;
    }
  });
  return size;
}

#pragma mark FlutterTexture

- (CVPixelBufferRef)copyPixelBuffer {
  CVPixelBufferRef pixelBuffer = _pixelBuffer;
  atomic_exchange(&_pixelBuffer, nil);
  return pixelBuffer;
}


@end
