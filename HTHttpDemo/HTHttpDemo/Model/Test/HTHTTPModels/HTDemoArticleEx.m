//
//  HTDemoArticleEx.m
//  HTHttpDemo
//
//  Created by Wangliping on 15/11/18.
//  Copyright © 2015年 NetEase. All rights reserved.
//

#import "HTDemoArticleEx.h"

@implementation HTDemoArticleEx

+ (NSDictionary *)customTypePropertyDic {
    return @{@"subscribers" : @"HTDemoSubscriber", @"author" : @"HTDemoAuthor", @"authorList" : @"HTDemoAuthor"};
}

+ (NSArray *)baseTypePropertyList {
    return @[@"title", @"body", @"publicationDate", @"comments"];
}

@end
