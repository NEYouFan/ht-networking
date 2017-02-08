//
//  HTConfigDelegateObject.m
//  HTHttp
//
//  Created by NetEase on 15/8/7.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import "HTConfigDelegateObject.h"
#import "NSURLRequest+HTCache.h"

@implementation HTConfigDelegateObject

- (NSURLRequest *)customRequest:(NSURLRequest *)request {
    NSMutableURLRequest *customRequest = [request mutableCopy];
    customRequest.timeoutInterval = 120;
    
    // 测试缓存策略
    customRequest.cachePolicy = 2;
    
    return customRequest;
}

@end
