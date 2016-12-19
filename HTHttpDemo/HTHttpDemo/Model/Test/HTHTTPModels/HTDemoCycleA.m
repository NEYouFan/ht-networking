//
//  HTDemoCycleA.m
//  HTHttpDemo
//
//  Created by Wangliping on 15/11/18.
//  Copyright © 2015年 NetEase. All rights reserved.
//

#import "HTDemoCycleA.h"

@implementation HTDemoCycleA

+ (NSDictionary *)customTypePropertyDic {
    return @{@"cycle":@"HTDemoCycleB"};
}

+ (NSArray *)baseTypePropertyList {
    return @[@"name"];
}

@end
