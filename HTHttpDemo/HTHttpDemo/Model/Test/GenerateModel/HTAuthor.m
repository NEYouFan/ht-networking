//
//  HTAuthor.m
//  HTHttpDemo
//
//  Created by Wangliping on 15/11/13.
//  Copyright © 2015年 NetEase. All rights reserved.
//

#import "HTAuthor.h"

@implementation HTAuthor

+ (NSDictionary *)customTypePropertyDic {
    return @{@"address":@"HTAddress"};
}

+ (NSArray *)baseTypePropertyList {
    return @[@"name", @"email"];
}

@end
