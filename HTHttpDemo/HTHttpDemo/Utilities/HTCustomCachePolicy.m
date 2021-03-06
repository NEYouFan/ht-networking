//
//  HTCustomCachePolicy.m
//  HTHttpDemo
//
//  Created by Wangliping on 16/2/15.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#import "HTCustomCachePolicy.h"
#import "HTNetworking.h"
#import <HTNetworking/Cache/HTCachedResponse.h>
#import <HTNetworking/Support/HTHTTPDate.h>

@implementation HTCustomCachePolicy

+ (BOOL)hasCacheForRequest:(RKHTTPRequestOperation *)requestOperation {
    HTCacheManager *cacheManager = [HTCacheManager sharedManager];
    NSURLRequest* request = requestOperation.request;
    return [cacheManager hasCacheForRequest:request];
}

+ (NSCachedURLResponse *)cachedResponseForRequest:(RKHTTPRequestOperation *)requestOperation {
    HTCacheManager *cacheManager = [HTCacheManager sharedManager];
    NSURLRequest* request = requestOperation.request;
    HTCachedResponse *cachedResponse = [cacheManager cachedResponseForRequest:request];
    if ([cachedResponse isExpired] || [cachedResponse isDateInvalid]) {
        [cacheManager removeCachedResponseForRequest:request completion:nil];
        return nil;
    }
    
    NSDate *now = [[HTHTTPDate sharedInstance] now];
    if (NSOrderedAscending == [now compare:cachedResponse.createDate]) {
        // 当前时间早于创建时间, 不取缓存. 否则用户不小心改了系统时间，永远取缓存了.
        return nil;
    }
    
    if (cachedResponse.version != request.ht_responseVersion) {
        // 版本号不匹配, 不取缓存.
        HTLogHTTPDebug(@"Cache version is not match, ignore cache response for request: %@", request);
        return nil;
    }
    
    // 忽略如下Case: 上一次存缓存的时候，设置最大过期时间为一年；下次取的时候，设置最大过期时间为一个月. 此时仍然按照存储的过期时间来判断请求是否过期.
    return cachedResponse.response;
}


@end
