//
//  HTDemoGetPhotoListRequest.h
//  HTHttpDemo
//
//  Created by Wang Liping on 15/10/10.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import "HTNetworking.h"

@interface HTDemoGetPhotoListRequest : HTBaseRequest

@property (nonatomic, assign) NSInteger limit;
@property (nonatomic, assign) NSInteger offset;

@end
