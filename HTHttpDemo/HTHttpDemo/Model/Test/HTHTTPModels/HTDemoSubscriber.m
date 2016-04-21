//
//  HTDemoSubscriber.m
//  HTHttpDemo
//
//  Created by Wangliping on 15/11/17.
//  Copyright © 2015年 NetEase. All rights reserved.
//

#import "HTDemoSubscriber.h"

@implementation HTDemoSubscriber

+ (NSDictionary *)customTypePropertyDic {
    return @{@"address" : @"HTDemoAddress", @"favoriteAuthors" : @"HTDemoAuthor"};
}

+ (NSArray *)baseTypePropertyList {
    return @[@"name", @"email"];
}

@end
