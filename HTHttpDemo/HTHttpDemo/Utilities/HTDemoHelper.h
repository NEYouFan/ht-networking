//
//  HTDemoHelper.h
//  HTHttpDemo
//
//  Created by Wang Liping on 15/9/18.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RKResponseDescriptor;

@interface HTDemoHelper : NSObject

+ (NSArray *)getPropertyList:(Class)theClass;

+ (NSDictionary *)propertiesOf:(NSURLRequest *)object;

@end
