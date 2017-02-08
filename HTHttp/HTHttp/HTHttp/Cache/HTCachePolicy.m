//
//  HTCachePolicy.m
//  HTHttp
//
//  Created by NetEase on 15/8/13.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import "HTCachePolicy.h"
#import "RKHTTPRequestOperation.h"

@implementation HTCachePolicy

+ (nullable NSCachedURLResponse *)willCacheResponse:(NSCachedURLResponse *)cachedResponse forRequest:(RKHTTPRequestOperation *)requestOperation {
    return cachedResponse;
}

+ (BOOL)hasCacheForRequest:(RKHTTPRequestOperation *)requestOperation {
    return NO;
}

+ (NSCachedURLResponse *)cachedResponseForRequest:(RKHTTPRequestOperation *)requestOperation {
    return nil;
}

@end
