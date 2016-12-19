//
//  HTCustomFreezePolicy.m
//  HTHttpDemo
//
//  Created by Wangliping on 16/2/15.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#import "HTCustomFreezePolicy.h"
#import "HTNetworking.h"
#import <HTNetworking/Freeze/HTFrozenRequest.h>

@implementation HTCustomFreezePolicy

+ (BOOL)canSend:(HTFrozenRequest *)frozenRequest {
    // 这里可以自行添加各类逻辑判断是否可以发送冻结的请求, 例如，根据host或者Application的状态来判断是否需要自动发送请求.
    NSString *urlString = frozenRequest.request.URL.host;
    return [urlString isEqualToString:@"localhost"];
}

+ (BOOL)canDelete:(HTFrozenRequest *)frozenRequest {
    // 默认策略：不重新发送则删除，不保留.
    return ![self canSend:frozenRequest];
}

@end
