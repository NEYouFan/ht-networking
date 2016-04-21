//
//  HTDemoBaseURLRequest.m
//  HTHttpDemo
//
//  Created by Wang Liping on 15/10/8.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import "HTDemoBaseURLRequest.h"

@implementation HTDemoBaseURLRequest

+ (NSString *)requestUrl {
    return @"user";
}

+ (RKResponseDescriptor *)responseDescriptor {
    RKResponseDescriptor *responseDescriptor = [[RKResponseDescriptor alloc] init];
    responseDescriptor.baseURL = [NSURL URLWithString:@"http://myTest"];
    return responseDescriptor;
}

@end
