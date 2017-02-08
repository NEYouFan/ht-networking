//
//  HTDemoCacheRequest.m
//  HTHttpDemo
//
//  Created by Wangliping on 16/2/2.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#import "HTDemoCustomCacheRequest.h"
#import "RKDemoUserInfo.h"
#import "HTNetworking.h"

#import "HTMyCachePolicy.h"

@implementation HTDemoCustomCacheRequest

+ (void)initialize {
    // Note: 必须注册缓存策略类，可以在任意需要的地方注册，且只需要注册一次.
    // 此处演示方便，放在这个request的initialize方法中.
    [super initialize];
    [[HTCachePolicyManager sharedInstance] registeCachePolicyWithPolicyId:kMyCachePolicyID policy:[HTMyCachePolicy class]];
}

+ (NSString *)requestUrl {
    return @"/user";
}

+ (RKMapping *)responseMapping {
    return [RKDemoUserInfo ht_modelMapping];
}

- (HTCachePolicyId)cacheId {
    return kMyCachePolicyID;
}
//
//- (NSTimeInterval)cacheExpireTimeInterval {
//    return 3600;
//}

+ (NSString *)keyPath {
    return @"data";
}

@end


