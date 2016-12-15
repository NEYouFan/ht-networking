//
//  HTAuthorRequest.m
//  HTHttpDemo
//
//  Created by Wangliping on 15/11/13.
//  Copyright © 2015年 NetEase. All rights reserved.
//

#import "HTAuthorRequest.h"
#import "HTAuthor.h"
#import "HTNetworking.h"
#import "HTAddress.h"

@implementation HTAuthorRequest

+ (RKRequestMethod)requestMethod {
    return RKRequestMethodGET;
}

+ (NSString *)requestUrl {
    return @"/author";
}

//+ (RKMapping *)responseMapping {
//    return [HTAuthor defaultResponseMapping];
//}

+ (NSString *)keyPath {
    return @"data";
}

// TODO LWANG: 两种Case需要说明在文档中.

/**
 *  以address为key得到的JSON.
 *
 *  @return {@"address":{}}
 */
//- (NSDictionary *)requestParams {
//    NSDictionary *dic = [self ht_modelToJSONObject];
//    if ([dic isKindOfClass:[NSDictionary class]] && [dic count] > 0) {
//        return dic;
//    }
//    
//    return nil;
//}

/**
 *  rootkey为nil得到的 JSON
 *
 *  @return {}. JSON直接对应Address.
 */
- (NSDictionary *)requestParams {
    NSDictionary *dic = [self.address ht_modelToJSONObject];
    if ([dic isKindOfClass:[NSDictionary class]] && [dic count] > 0) {
        return dic;
    }
    
    return nil;
}

@end
