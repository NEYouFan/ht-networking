//
//  RKObjectRequestOperation+HTDemoRAC.h
//  HTHttpDemo
//
//  Created by Wang Liping on 15/9/18.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import "RKObjectRequestOperation.h"

@class RACSignal;
@class RKObjectManager;

@interface RKObjectRequestOperation (HTDemoRAC)

#pragma mark -- Test

// 这里提供的replaySignalInManager可以实现防止重复调用的功能.
// 从实现来看，如果任务没有做过，那么是没有问题的. 不会执行多次.
// 但是如果Operation已经通过其他渠道完成了，那么有问题会报错 "operation is finished and cannot be enqueued".
// 所以这个方法移到Demo中仅供测试使用.
- (RACSignal *)replaySignalInManager:(RKObjectManager *)manager;

@end
