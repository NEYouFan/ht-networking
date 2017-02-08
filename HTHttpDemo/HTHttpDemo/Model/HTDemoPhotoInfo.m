//
//  HTDemoPhotoInfo.m
//  HTHttpDemo
//
//  Created by Wang Liping on 15/9/18.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import "HTDemoPhotoInfo.h"
#import "HTDemoHelper.h"

@implementation HTDemoPhotoInfo

- (NSString *)description {
    NSMutableString *description = [NSMutableString stringWithString:@"HTDemoPhotoInfo"];
    
    NSArray *propertyList = [HTDemoHelper getPropertyList:[HTDemoPhotoInfo class]];
    for (NSString *propertyName in propertyList) {
        id value = [self valueForKey:propertyName];
        [description appendFormat:@"%@ : %@", propertyName, value];
    }

    return description;
}

@end
