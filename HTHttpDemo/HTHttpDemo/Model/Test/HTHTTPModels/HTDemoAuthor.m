//
//  HTDemoAuthor.m
//  HTHttpDemo
//
//  Created by Wangliping on 15/11/17.
//  Copyright © 2015年 NetEase. All rights reserved.
//

#import "HTDemoAuthor.h"

@implementation HTDemoAuthor

+ (NSDictionary *)customTypePropertyDic {
    return @{@"address":@"HTDemoAddress"};
}

+ (NSArray *)baseTypePropertyList {
    return @[@"name", @"email"];
}

@end
