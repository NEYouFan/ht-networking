//
//  HTArticleRequest.m
//  HTHttpDemo
//
//  Created by Wangliping on 15/11/13.
//  Copyright © 2015年 NetEase. All rights reserved.
//

#import "HTArticleRequest.h"
#import "HTArticle.h"

@implementation HTArticleRequest

+ (RKRequestMethod)requestMethod {
    return RKRequestMethodGET;
}

+ (NSString *)requestUrl {
    return @"/article";
}

+ (RKMapping *)responseMapping {
    return [HTArticle defaultResponseMapping];
}

+ (NSString *)keyPath {
    return @"data";
}

@end
