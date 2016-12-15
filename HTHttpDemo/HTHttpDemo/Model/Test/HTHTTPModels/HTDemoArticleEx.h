//
//  HTDemoArticleEx.h
//  HTHttpDemo
//
//  Created by Wangliping on 15/11/18.
//  Copyright © 2015年 NetEase. All rights reserved.
//

#import "HTNetworking.h"

@class HTDemoAuthor;
@class HTDemoSubscriber;

@interface HTDemoArticleEx : HTHTTPModel


/**
 *  标题
 */
@property (nonatomic, copy) NSString *title;

/**
 *  正文
 */
@property (nonatomic, copy) NSString *body;

/**
 *  作者
 */
@property (nonatomic, strong) HTDemoAuthor *author;

/**
 *  发表日期
 */
@property (nonatomic, strong) NSDate *publicationDate;

// 测试一个HTDemoAuthor对应两个Key的情况.
@property (nonatomic, strong) NSArray<HTDemoAuthor *> *authorList;

/**
 *  评论
 */
@property (nonatomic, strong) NSArray<NSString *> *comments;

/**
 *  订阅者
 */
@property (nonatomic, strong) NSArray<HTDemoSubscriber *> *subscribers;

@end
