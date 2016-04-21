//
//  HTPostArticleRequest.m
//  HTHttpDemo
//
//  Created by Wangliping on 15/11/25.
//  Copyright © 2015年 NetEase. All rights reserved.
//

#import "HTPostArticleRequest.h"
#import "HTArticle.h"
#import "NSObject+HTModel.h"

@implementation HTPostArticleRequest

+ (RKRequestMethod)requestMethod {
    return RKRequestMethodPOST;
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

- (NSDictionary *)requestParams {
    NSDictionary *dic = [self ht_modelToJSONObject];
    if ([dic isKindOfClass:[NSDictionary class]] && [dic count] > 0) {
        return dic;
    }
    
    return nil;
}

+ (NSDictionary *)collectionCustomObjectTypes {
    return @{@"authors":@"HTAuthor"};
}

@end
