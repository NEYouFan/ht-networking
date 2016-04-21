//
//  HTHTTPArticle.h
//  HTHttp
//
//  Created by Wangliping on 16/1/7.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#import "HTHTTPModel.h"

@class RKMapping;

@interface HTHTTPArticle : HTHTTPModel

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, strong) NSArray<NSString *> *chapters;
@property (nonatomic, assign) BOOL isNovel;

+ (RKMapping *)manuallyMapping;

@end
