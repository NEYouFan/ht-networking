//
//  HTDemoGetUserInfoRequest.m
//  HTHttpDemo
//
//  Created by Wang Liping on 15/10/8.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import "HTDemoGetUserInfoRequest.h"
#import "RKDemoUserInfo.h"

@implementation HTDemoGetUserInfoRequest

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

@end
