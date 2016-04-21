//
//  HTHTTPAuthor.h
//  HTHttp
//
//  Created by Wangliping on 16/1/7.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#import "HTHTTPModel.h"

@class HTHTTPArticle;
@class HTHTTPAddress;
@class RKMapping;

@interface HTHTTPAuthor : HTHTTPModel

@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) HTHTTPArticle *article;
@property (nonatomic, strong) HTHTTPAddress *address;

+ (RKMapping *)manuallyMapping;

@end
