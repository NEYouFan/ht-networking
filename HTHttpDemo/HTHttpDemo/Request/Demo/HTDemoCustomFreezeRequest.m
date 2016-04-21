//
//  HTDemoCustomFreezeRequest.m
//  HTHttpDemo
//
//  Created by Wangliping on 16/2/15.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#import "HTDemoCustomFreezeRequest.h"
#import "HTDemoPhotoInfo.h"

@implementation HTDemoCustomFreezeRequest

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

@end
