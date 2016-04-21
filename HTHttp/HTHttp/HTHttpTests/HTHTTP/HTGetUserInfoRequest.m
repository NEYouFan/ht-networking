//
//  HTGetUserInfoRequest.m
//  HTHttp
//
//  Created by Wang Liping on 15/9/8.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import "HTGetUserInfoRequest.h"
#import "RKResponseDescriptor.h"
#import "HTUserInfo.h"

@implementation HTGetUserInfoRequest

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
