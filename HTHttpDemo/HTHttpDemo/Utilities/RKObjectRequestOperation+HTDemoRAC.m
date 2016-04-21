//
//  RKObjectRequestOperation+HTDemoRAC.m
//  HTHttpDemo
//
//  Created by Wang Liping on 15/9/18.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import "RKObjectRequestOperation+HTDemoRAC.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "RestKit.h"

@implementation RKObjectRequestOperation (HTDemoRAC)

#pragma mark - Test

- (RACSignal *)replaySignalInManager:(RKObjectManager *)manager {
    return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        void (^oldCompBlock)() = self.completionBlock;
        [self setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            // sendNext本身是同步的. next消息的接收和sendNext在同一线程中.
            [subscriber sendNext:operation];
            [subscriber sendCompleted];
            
            if (oldCompBlock) {
                oldCompBlock();
            }
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            [subscriber sendError:error];
            
            if (oldCompBlock) {
                oldCompBlock();
            }
        }];
        
        RKObjectManager *defaultManager = [RKObjectManager sharedManager];
        RKObjectManager *validManager = (nil == manager) ? defaultManager : manager;
        [validManager enqueueObjectRequestOperation:self];
        return [RACDisposable disposableWithBlock:^{
            [self cancel];
        }];
        
    }] replay];
}


@end
