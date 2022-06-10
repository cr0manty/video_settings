//
//  CallBackModel.m
//  Branch
//
//  Created by Denys Dudka on 10.06.2022.
//

#import "CallBackModel.h"

@implementation CallBackModel

-(instancetype)init:(FlutterMethodCall*)call
             result:(FlutterResult)result {
    self = [super init];
    
    if (self) {
        self.call = call;
        self.result = result;
    }
    
    return self;
}

@end
