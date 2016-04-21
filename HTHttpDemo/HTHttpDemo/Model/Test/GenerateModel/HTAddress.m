//
//  HTAddress.m
//  HTHttpDemo
//
//  Created by Wangliping on 15/11/20.
//  Copyright © 2015年 NetEase. All rights reserved.
//

#import "HTAddress.h"

@implementation HTAddress

+ (NSDictionary *)customTypePropertyDic {
    return @{};
}

+ (NSArray *)baseTypePropertyList {
    return @[@"province", @"city"];
}

@end
