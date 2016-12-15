//
//  HTDemoCacheRequest.m
//  HTHttpDemo
//
//  Created by Wangliping on 16/2/2.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#import "HTDemoCacheRequest.h"
#import "RKDemoUserInfo.h"
#import "HTNetworking.h"

@implementation HTDemoCacheRequest

+ (NSString *)requestUrl {
    return @"/user";
}

+ (RKMapping *)responseMapping {
    return [RKDemoUserInfo ht_modelMapping];
}

- (HTCachePolicyId)cacheId {
    return HTCachePolicyCacheFirst;
}

- (NSTimeInterval)cacheExpireTimeInterval {
    return 3600;
}

+ (NSString *)keyPath {
    return @"data";
}

@end


