//
//  FlutterDataHandler.m
//  Pods-Runner
//
//  Created by Denys Dudka on 18.05.2022.
//


#import "FlutterSinkHandler.h"

@interface FlutterSinkHandler()

@end

@implementation FlutterSinkHandler

- (FlutterError * _Nullable)onCancelWithArguments:(id _Nullable)arguments {
    self.sink = nil;
    return nil;
}

- (FlutterError * _Nullable)onListenWithArguments:(id _Nullable)arguments eventSink:(nonnull FlutterEventSink)events {
    self.sink = events;
    return nil;
}

@end
