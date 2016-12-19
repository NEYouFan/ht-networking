//
//  HTGetUserInfoWithConfig.h
//  HTHttp
//
//  Created by Wangliping on 16/1/5.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#import "HTBaseRequest.h"

@interface HTGetUserInfoWithConfig : HTBaseRequest

@property (nonatomic, assign) NSTimeInterval customTimeInterval;
@property (nonatomic, assign) NSTimeInterval customCacheExpireInteval;
@property (nonatomic, assign) NSTimeInterval customFreezeInteval;

@end
