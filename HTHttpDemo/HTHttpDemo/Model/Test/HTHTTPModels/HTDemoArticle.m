//
//  HTDemoArticle.m
//  HTHttpDemo
//
//  Created by Wangliping on 15/11/17.
//  Copyright © 2015年 NetEase. All rights reserved.
//

#import "HTDemoArticle.h"

@implementation HTDemoArticle

+ (NSDictionary *)collectionCustomObjectTypes {
    return @{@"subscribers" : @"HTDemoSubscriber"};
}

+ (NSDictionary *)customTypePropertyDic {
    return @{@"subscribers" : @"HTDemoSubscriber", @"author" : @"HTDemoAuthor"};
}

+ (NSArray *)baseTypePropertyList {
    return @[@"title", @"body", @"publicationDate", @"comments"];
}

@end



