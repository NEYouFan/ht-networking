//
//  HTMockUserInfoRequest.m
//  HTHttpDemo
//
//  Created by Wangliping on 16/1/25.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#import "HTMockUserInfoRequest.h"
#import "HTNetworking.h"
#import "HTMockUserInfo.h"

@implementation HTMockUserInfoRequest

- (void)dealloc {
    NSLog(@"HTMockUserInfoRequest dealloc");
}

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

- (HTMockBlock)mockBlock {
    return ^(NSURLRequest *mockRequest) {
        mockRequest.ht_mockJsonFilePath = [[NSBundle mainBundle] pathForResource:@"HTMockAuthorize" ofType:@"json"];
    };
}

@end
