//
//  HTHTTPReader.h
//  HTHttp
//
//  Created by Wangliping on 16/1/7.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#import "HTHTTPModel.h"

@class HTHTTPArticle;
@class HTHTTPAddress;

@interface HTHTTPReader : HTHTTPModel

@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) NSArray<HTHTTPArticle *> *articles;
@property (nonatomic, strong) HTHTTPAddress *address;
@property (nonatomic, strong) NSArray<NSString *> *favoriteList;

+ (RKMapping *)manuallyMapping;

@end
