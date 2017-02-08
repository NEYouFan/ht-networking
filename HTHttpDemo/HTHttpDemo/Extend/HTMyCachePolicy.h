//
//  HTMyCachePolicy.h
//  HTHttpDemo
//
//  Created by NetEase on 16/11/16.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#import "HTNetworking.h"
#import "HTDefaultCachePolicy.h"

extern HTCachePolicyId const kMyCachePolicyID;

// Note: 使用自定义的缓存策略前需要注册 `[[HTCachePolicyManager sharedInstance] registeCachePolicyWithPolicyId:kMyCachePolicyID policy:[HTMyCachePolicy class]];`
// 例子参见HTDemoCustomCacheRequest

@interface HTMyCachePolicy : HTDefaultCachePolicy

@end
