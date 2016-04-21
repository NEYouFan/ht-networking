//
//  HTArticle.m
//  HTHttpDemo
//
//  Created by Wangliping on 15/11/13.
//  Copyright © 2015年 NetEase. All rights reserved.
//

#import "HTArticle.h"

@implementation HTArticle

+ (NSDictionary *)customTypePropertyDic {
    return @{@"author" : @"HTAuthor", @"comments" : @"HTComment"};
}

+ (NSArray *)baseTypePropertyList {
    return @[@"title", @"body"];
}

@end
