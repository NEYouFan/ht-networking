//
//  HTTestCustomFreezePolicy.m
//  HTHttp
//
//  Created by Wangliping on 16/1/11.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#import "HTTestCustomFreezePolicy.h"

@implementation HTTestCustomFreezePolicy

+ (BOOL)canSend:(HTFrozenRequest *)frozenRequest {
    return NO;
}

+ (BOOL)canDelete:(HTFrozenRequest *)frozenRequest {
    return NO;
}

@end
