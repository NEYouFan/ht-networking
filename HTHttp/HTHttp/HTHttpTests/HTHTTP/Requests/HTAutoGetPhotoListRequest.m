//
//  HTAutoGetPhotoListRequest.m
//  HTHttp
//
//  Created by Wangliping on 16/1/7.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#import "HTAutoGetPhotoListRequest.h"
#import "NSObject+HTModel.h"
#import "NSObject+HTMapping.h"
#import "HTPhotoInfo.h"

@implementation HTAutoGetPhotoListRequest

+ (NSString *)requestUrl {
    return @"/photolist";
}

+ (NSString *)keyPath {
    return @"photolist";
}

- (NSDictionary *)requestParams {
    NSDictionary *dic = [self ht_modelToJSONObject];
    if ([dic isKindOfClass:[NSDictionary class]] && [dic count] > 0) {
        return dic;
    }
    
    return nil;
}

+ (RKMapping *)responseMapping {
    return [HTPhotoInfo ht_modelMapping];
}

@end
