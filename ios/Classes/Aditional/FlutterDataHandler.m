//
//  FlutterDataHandler.m
//  Pods-Runner
//
//  Created by Denys Dudka on 18.05.2022.
//


#import "FlutterDataHandler.h"

@interface FlutterSinkDataHandler()

@end

@implementation FlutterSinkDataHandler

- (FlutterError * _Nullable)onCancelWithArguments:(id _Nullable)arguments {
    self.sink = nil;
    return nil;
}

- (FlutterError * _Nullable)onListenWithArguments:(id _Nullable)arguments eventSink:(nonnull FlutterEventSink)events {
    self.sink = events;
    return nil;
}

@end
