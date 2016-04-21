//
//  HTDemoCycleB.m
//  HTHttpDemo
//
//  Created by Wangliping on 15/11/18.
//  Copyright © 2015年 NetEase. All rights reserved.
//

#import "HTDemoCycleB.h"

@implementation HTDemoCycleB

+ (NSDictionary *)customTypePropertyDic {
    return @{@"cycle":@"HTDemoCycleC"};
}

+ (NSArray *)baseTypePropertyList {
    return @[@"name"];
}

@end
