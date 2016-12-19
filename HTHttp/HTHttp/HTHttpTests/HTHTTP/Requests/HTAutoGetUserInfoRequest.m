//
//  HTAutoGetUserInfoRequest.m
//  HTHttp
//
//  Created by Wangliping on 16/1/11.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#import "HTAutoGetUserInfoRequest.h"
#import "HTUserInfo.h"

@implementation HTAutoGetUserInfoRequest

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

@end
