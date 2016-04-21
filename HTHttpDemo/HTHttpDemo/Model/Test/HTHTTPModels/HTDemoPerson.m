//
//  HTDemoPerson.m
//  HTHttpDemo
//
//  Created by Wangliping on 15/11/17.
//  Copyright © 2015年 NetEase. All rights reserved.
//

#import "HTDemoPerson.h"

@implementation HTDemoPerson

+ (NSDictionary *)customTypePropertyDic {
    return @{@"son":@"HTDemoPerson"};
}

+ (NSArray *)baseTypePropertyList {
    return @[@"name"];
}

@end
