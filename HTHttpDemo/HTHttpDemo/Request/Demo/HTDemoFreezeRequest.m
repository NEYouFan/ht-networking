//
//  HTDemoFreezeRequest.m
//  HTHttpDemo
//
//  Created by Wangliping on 16/2/4.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#import "HTDemoFreezeRequest.h"
#import "RKDemoUserInfo.h"

@implementation HTDemoFreezeRequest

+ (NSString *)requestUrl {
    return @"/user";
}

+ (RKMapping *)responseMapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[RKDemoUserInfo class]];
    [mapping addAttributeMappingsFromArray:@[@"userId", @"balance", @"version"]];
    [mapping addAttributeMappingsFromDictionary:@{@"version":@"name", @"status":@"password"}];
    
    return mapping;
}

+ (NSString *)keyPath {
    return @"data";
}

- (HTFreezePolicyId)freezePolicyId {
    return HTFreezePolicySendFreezeAutomatically;
}

- (NSTimeInterval)freezeExpireTimeInterval {
    return 3600;
}

@end
