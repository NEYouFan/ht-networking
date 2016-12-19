//
//  HTDemoGetPhotoListInfo.m
//  HTHttpDemo
//
//  Created by Wang Liping on 15/10/10.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import "HTDemoGetUserPhotoListRequest.h"
#import "HTDemoPhotoInfo.h"
#import "HTDemoHelper.h"

@implementation HTDemoGetUserPhotoListRequest

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

- (NSTimeInterval)cacheExpireTimeInterval {
    return 120;
}

@end
