//
//  HTDemoArticle.h
//  HTHttpDemo
//
//  Created by Wangliping on 15/11/17.
//  Copyright © 2015年 NetEase. All rights reserved.
//

#import "HTHTTPModel.h"

@class HTDemoAuthor;
@class HTDemoSubscriber;

@interface HTDemoArticle : HTHTTPModel

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

/**
 *  评论
 */
@property (nonatomic, strong) NSArray<NSString *> *comments;

/**
 *  订阅者
 */
@property (nonatomic, strong) NSArray<HTDemoSubscriber *> *subscribers;

@end
