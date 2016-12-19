//
//  HTSecurityUserInfoRequest.m
//  HTHttp
//
//  Created by Wangliping on 16/1/26.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#import "HTSecurityUserInfoRequest.h"
#import "NSObject+HTMapping.h"
#import "HTMockUserInfo.h"

@implementation HTSecurityUserInfoRequest

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

- (NSDictionary *)requestParams {
    return @{@"clientId" : @(1), @"clientSecret" : @"secret1", @"account" : @"实际账号", @"password" : @"实际密码"};
}

@end
