//
//  HTGetUserInfoWithHeaderRequest.m
//  HTHttp
//
//  Created by Wangliping on 16/1/5.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#import "HTGetUserInfoWithHeaderRequest.h"
#import "HTUserInfo.h"

@implementation HTGetUserInfoWithHeaderRequest

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

- (NSDictionary *)requestHeaderFieldValueDictionary {
    return @{@"UnitTestHeader":@"HTGetUserInfoWithHeaderRequest"};
}

- (BOOL)needCustomRequest {
    return YES;
}

+ (NSString *)keyPath {
    return @"data";
}

@end
