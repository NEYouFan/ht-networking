//
//  HTCommentRequest.m
//  HTHttpDemo
//
//  Created by Wangliping on 15/11/13.
//  Copyright © 2015年 NetEase. All rights reserved.
//

#import "HTCommentRequest.h"
#import "NSObject+HTModel.h"
#import "HTComment.h"

@implementation HTCommentRequest

+ (RKRequestMethod)requestMethod {
    return RKRequestMethodPOST;
}

+ (NSString *)requestUrl {
    return @"/comment";
}

+ (RKMapping *)responseMapping {
    return [HTComment defaultResponseMapping];
}

+ (NSString *)keyPath {
    return @"data";
}

- (NSDictionary *)requestParams {
    NSDictionary *dic = [self ht_modelToJSONObject:[self headerPropertyList]];
    if ([dic isKindOfClass:[NSDictionary class]] && [dic count] > 0) {
        return dic;
    }
    
    return nil;
}

- (NSArray *)headerPropertyList {
    return @[@"cookie", @"userInfo"];
}

- (NSDictionary *)requestHeaderFieldValueDictionary {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:@"application/json" forKey:@"Content-Type"];
    if (nil != _cookie) {
        [dic setObject:_cookie forKey:@"Cookie"];
    }
    
    if (nil != _userInfo) {
        [dic setObject:_userInfo forKey:@"UserInfo"];
    }
    
    return dic;
}

@end
