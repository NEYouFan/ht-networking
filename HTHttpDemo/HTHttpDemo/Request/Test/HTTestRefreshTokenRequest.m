//
//  HTTestRefreshTokenRequest.m
//  HTHttpDemo
//
//  Created by Wangliping on 16/2/2.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#import "HTTestRefreshTokenRequest.h"
#import "HTMockUserInfo.h"
#import "NSObject+HTMapping.h"

@implementation HTTestRefreshTokenRequest

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
    return @"/refreshToken";
}

- (NSDictionary *)requestParams {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if ([_refreshToken length] > 0) {
        params[@"refreshToken"] = _refreshToken;
    }
    
    return params;
}

- (BOOL)enableMock {
    return YES;
}

- (HTMockBlock)mockBlock {
    return ^(NSURLRequest *mockRequest) {
        mockRequest.ht_mockJsonFilePath = [[NSBundle mainBundle] pathForResource:@"HTMockAuthorize" ofType:@"json"];
    };
}

@end
