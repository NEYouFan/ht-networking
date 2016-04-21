//
//  HTMockUserInfoRequest.m
//  HTHttp
//
//  Created by Wangliping on 16/1/26.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#import "HTMockUserInfoRequest.h"
#import "NSObject+HTMapping.h"
#import "HTMockUserInfo.h"

@implementation HTMockUserInfoRequest

+ (RKRequestMethod)requestMethod {
    return RKRequestMethodPOST;
}

+ (RKMapping *)responseMapping {
    return [HTMockUserInfo ht_modelMapping];
}

+ (NSString *)keyPath {
    return @"data";
}

+ (NSString *)requestUrl {
    return @"/authorize";
}

- (BOOL)enableMock {
    return YES;
}

@end
