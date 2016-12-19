//
//  HTDemoCacheIgnoreParamsRequest.m
//  HTHttpDemo
//
//  Created by Wangliping on 16/2/15.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#import "HTDemoCacheIgnoreParamsRequest.h"
#import "HTDemoPhotoInfo.h"

@implementation HTDemoCacheIgnoreParamsRequest

+ (RKRequestMethod)requestMethod {
    return RKRequestMethodPOST;
}

+ (NSString *)requestUrl {
    return @"/collection";
}

- (NSDictionary *)requestParams {
    return @{@"name":@"lwang", @"password":@"test", @"type":@"photolist"};
}

+ (RKMapping *)responseMapping {
    return [HTDemoPhotoInfo defaultResponseMapping];
}

+ (NSString *)keyPath {
    return @"photolist";
}

- (HTCachePolicyId)cacheId {
    return HTCachePolicyCacheFirst;
}

- (NSTimeInterval)cacheExpireTimeInterval {
    return 3600;
}

- (NSDictionary *)cacheKeyFilteredRequestParams:(NSDictionary *)params {
    NSMutableDictionary *cacheFilterParams = [NSMutableDictionary dictionaryWithDictionary:params];
    // Demo: Password不参与cacheKey的计算, 则密码更改后cache仍有效. 实际使用中更多用来过滤时间戳等.
    [cacheFilterParams removeObjectForKey:@"password"];
    
    return cacheFilterParams;
}

@end
