//
//  HTDemoCycleC.h
//  HTHttpDemo
//
//  Created by Wangliping on 15/11/18.
//  Copyright © 2015年 NetEase. All rights reserved.
//

#import "HTHTTPModel.h"

@class HTDemoCycleA;

@interface HTDemoCycleC : HTHTTPModel

/**
 *  姓名
 */
@property (nonatomic, copy) NSString *name;

/**
 *  测试嵌套.
 */
@property (nonatomic, strong) HTDemoCycleA *cycle;

@end
