//
//  HTComment.h
//  HTHttpDemo
//
//  Created by Wangliping on 15/11/13.
//  Copyright © 2015年 NetEase. All rights reserved.
//

#import "HTHTTPModel.h"

@interface HTComment : HTHTTPModel

/**
 *  商品规格描述列表，比如 颜色:白色
 */
@property (nonatomic, strong) NSArray<NSString *> *skuInfo;

/**
 *  用户评论内容
 */
@property (nonatomic, copy) NSString *content;

/**
 *  评论用户名
 */
@property (nonatomic, copy) NSString *userName;

/**
 *  评论条数
 */
@property (nonatomic, assign) CGFloat count;

@end
