//
//  HTArticle.h
//  HTHttpDemo
//
//  Created by Wangliping on 15/11/13.
//  Copyright © 2015年 NetEase. All rights reserved.
//

#import "HTHTTPModel.h"

@class HTAuthor;
@class HTComment;

@interface HTArticle : HTHTTPModel

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
@property (nonatomic, strong) HTAuthor *author;

/**
 *  评论
 */
@property (nonatomic, strong) NSArray<HTComment *> *comments;

@end
