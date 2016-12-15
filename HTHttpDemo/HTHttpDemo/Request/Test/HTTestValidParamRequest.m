//
//  HTTestValidParamRequest.m
//  HTHttpDemo
//
//  Created by Wangliping on 16/2/2.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#import "HTTestValidParamRequest.h"
#import "HTMockUserInfo.h"
#import "HTNetworking.h"

@implementation HTTestValidParamRequest

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
    if (nil != _token) {
        params[@"token"] = _token;
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
