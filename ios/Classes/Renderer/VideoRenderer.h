//
//  VideoRenderer.h
//  Pods-Runner
//
//  Created by Denys Dudka on 19.05.2022.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <Flutter/Flutter.h>


NS_ASSUME_NONNULL_BEGIN

API_AVAILABLE(ios(10.0))
@interface VideoRenderer : NSObject<FlutterTexture, FlutterStreamHandler>
/// The queue on which `latestPixelBuffer` property is accessed.
/// To avoid unnecessary contention, do not access `latestPixelBuffer` on the `captureSessionQueue`.
@property(readwrite, nonatomic) CVPixelBufferRef latestPixelBuffer;
@property (nonatomic, weak) id<FlutterTextureRegistry> registry;
@property (nonatomic, copy) FlutterEventSink _Nullable sink;
@property (nonatomic) int64_t textureId;
@property (nonatomic, strong) AVCaptureSession *capturesSession;



-(void)handleMethodCall:(FlutterMethodCall*)call
                 result:(FlutterResult)result;

-(instancetype)init:(id<FlutterTextureRegistry>)registrar
          messenger:(NSObject<FlutterBinaryMessenger>*)messenger;

-(void)updateDeviceWIthDeviceID:(NSString*)deviceID
             result:(FlutterResult)result;


-(void)dispose;

@end

NS_ASSUME_NONNULL_END
