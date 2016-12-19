//
//  HTDemoCycleC.m
//  HTHttpDemo
//
//  Created by Wangliping on 15/11/18.
//  Copyright © 2015年 NetEase. All rights reserved.
//

#import "HTDemoCycleC.h"

@implementation HTDemoCycleC

+ (NSDictionary *)customTypePropertyDic {
    return @{@"cycle":@"HTDemoCycleA"};
}

+ (NSArray *)baseTypePropertyList {
    return @[@"name"];
}

@end
