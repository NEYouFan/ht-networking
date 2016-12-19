//
//  HTComment.m
//  HTHttpDemo
//
//  Created by Wangliping on 15/11/13.
//  Copyright © 2015年 NetEase. All rights reserved.
//

#import "HTComment.h"

@implementation HTComment

+ (NSDictionary *)customTypePropertyDic {
    return @{};
}

+ (NSArray *)baseTypePropertyList {
    return @[@"skuInfo", @"content", @"userName", @"count"];
}

@end
