//
//  HTCachePolicy.h
//  HTHttp
//
//  Created by NetEase on 15/8/13.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTCachePolicyProtocol.h"

@interface HTCachePolicy : NSObject <HTCachePolicyProtocol>

/**
 *  是否cache Response.
 *  该方法允许使用者在自己的缓存策略类中判断是否需要缓存, 以及返回缓存前是否需要对数据进行修改.
 *  默认情况下，不作任何处理并直接返回cachedResponse.
 *  如果返回nil, 则不缓存. 否则缓存的实际数据来源于cachedResponse.
 *
 *  @param cachedResponse   待缓存的response.
 *  @param requestOperation 待缓存的operation.
 *
 *  @return 返回允许缓存的operation.
 */
+ (NSCachedURLResponse *)willCacheResponse:(NSCachedURLResponse *)cachedResponse forRequest:(RKHTTPRequestOperation *)requestOperation;

/**
 *  是否存在requestOperation对应的缓存结果.
 *
 *  @param requestOperation 网络请求Operation对象.
 *
 *  @return 有对应缓存结果，返回YES, 否则, 返回NO.
 */
+ (BOOL)hasCacheForRequest:(RKHTTPRequestOperation *)requestOperation;

/**
 *  获取requestOperation对应的缓存结果.
 *
 *  @param requestOperation 网络请求Operation对象.
 *
 *  @return 返回缓存的结果，如果没有，返回nil.
 */
+ (NSCachedURLResponse *)cachedResponseForRequest:(RKHTTPRequestOperation *)requestOperation;

@end
