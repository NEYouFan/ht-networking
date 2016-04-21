//
//  HTDemoCycleB.h
//  HTHttpDemo
//
//  Created by Wangliping on 15/11/18.
//  Copyright © 2015年 NetEase. All rights reserved.
//

#import "HTHTTPModel.h"

@class HTDemoCycleC;

@interface HTDemoCycleB : HTHTTPModel

/**
 *  姓名
 */
@property (nonatomic, copy) NSString *name;

/**
 *  测试嵌套.
 */
@property (nonatomic, strong) HTDemoCycleC *cycle;

@end
