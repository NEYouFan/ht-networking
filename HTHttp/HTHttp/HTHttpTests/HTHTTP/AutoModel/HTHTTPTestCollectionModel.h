//
//  HTHTTPTestCollectionModel.h
//  HTHttp
//
//  Created by Wangliping on 16/1/7.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#import "HTHTTPModel.h"

@class HTHTTPAddress;
@class HTHTTPArticle;
@class RKMapping;

@interface HTHTTPTestCollectionModel : HTHTTPModel

@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) NSInteger count;
@property (nonatomic, assign) BOOL isSpecial;
@property (nonatomic, strong) HTHTTPAddress *simpleAddress;
@property (nonatomic, strong) NSArray<NSString *> *comments;
@property (nonatomic, strong) NSArray<HTHTTPArticle *> *articles;

+ (RKMapping *)manuallyMapping;

@end
