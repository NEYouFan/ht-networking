//
//  HTPostArticleRequest.h
//  HTHttpDemo
//
//  Created by Wangliping on 15/11/25.
//  Copyright © 2015年 NetEase. All rights reserved.
//

#import "HTBaseRequest.h"
#import "HTModelProtocol.h"

@class HTArticle;
@class HTAuthor;

@interface HTPostArticleRequest : HTBaseRequest <HTModelProtocol>

@property (nonatomic, strong) HTArticle *article;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) double length;
@property (nonatomic, assign) BOOL allowComment;
@property (nonatomic, strong) NSDictionary *testDic;
@property (nonatomic, strong) NSArray<HTAuthor *> *authors;

@end
