//
//  HTGetUserInfoWithConfig.m
//  HTHttp
//
//  Created by Wangliping on 16/1/5.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#import "HTGetUserInfoWithConfig.h"
#import "HTUserInfo.h"

@implementation HTGetUserInfoWithConfig

+ (NSString *)requestUrl {
    return @"/user";
}

+ (RKMapping *)responseMapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[HTUserInfo class]];
    [mapping addAttributeMappingsFromArray:@[@"userId", @"balance", @"version"]];
    
    // 类型不匹配也可以正确解析.
    [mapping addAttributeMappingsFromDictionary:@{@"version":@"name", @"status":@"password"}];
    
    return mapping;
}

+ (NSString *)keyPath {
    return @"data";
}

- (NSTimeInterval)requestTimeoutInterval {
    return _customTimeInterval;
}

- (NSTimeInterval)cacheExpireTimeInterval {
    return _customCacheExpireInteval;
}

- (BOOL)canFreeze {
    return YES;
}

- (NSTimeInterval)freezeExpireTimeInterval {
    return _customFreezeInteval;
}

- (BOOL)needCustomRequest {
    return YES;
}

@end
