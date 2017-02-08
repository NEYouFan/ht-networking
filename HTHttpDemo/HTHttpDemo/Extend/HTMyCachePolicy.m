//
//  HTMyCachePolicy.m
//  HTHttpDemo
//
//  Created by NetEase on 16/11/16.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#import "HTMyCachePolicy.h"
#import "HTCachePolicyManager.h"

HTCachePolicyId const kMyCachePolicyID = HTCachePolicyUserDefined + 1;

@implementation HTMyCachePolicy

+ (nullable NSCachedURLResponse *)willCacheResponse:(NSCachedURLResponse *)cachedResponse forRequest:(RKHTTPRequestOperation *)requestOperation {
    
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)cachedResponse.response;
    if ([httpResponse isKindOfClass:[NSHTTPURLResponse class]]) {
        NSDictionary *headers = httpResponse.allHeaderFields;
        if ([headers objectForKey:@"cache-control"]) {
            
            // 根据自己的逻辑设置缓存的超时时间，是否需要缓存等等.
            // ....
        } else {
            
        }
        
    }
    
    // 根据自己的逻辑设置缓存的超时时间，是否需要缓存等等.
    // 如果需要缓存，返回cachedResponse; 否则，返回nil.
    requestOperation.request.ht_cacheExpireTimeInterval = 100;
    return cachedResponse;
}

@end
