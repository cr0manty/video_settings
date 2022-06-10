//
//  CallBackModel.h
//  Branch
//
//  Created by Denys Dudka on 10.06.2022.
//

#import <Foundation/Foundation.h>

typedef void (^FlutterResult)(id _Nullable result);
@class FlutterMethodCall;

NS_ASSUME_NONNULL_BEGIN

@interface CallBackModel : NSObject
@property (nonatomic, strong) FlutterMethodCall *call;
@property (nonatomic, strong) FlutterResult result;


-(instancetype)init:(FlutterMethodCall*)call
             result:(FlutterResult)result;

@end

NS_ASSUME_NONNULL_END
