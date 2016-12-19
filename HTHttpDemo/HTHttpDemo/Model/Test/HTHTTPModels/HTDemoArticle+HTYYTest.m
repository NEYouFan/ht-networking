//
//  HTDemoArticle+HTYYTest.m
//  HTHttpDemo
//
//  Created by Wangliping on 15/11/20.
//  Copyright © 2015年 NetEase. All rights reserved.
//

#import "HTDemoArticle+HTYYTest.h"
#import <objc/runtime.h>

const void *kHTYYTestVersion = &kHTYYTestVersion;

@implementation HTDemoArticle (HTYYTest)

- (NSString *)ht_version {
    return objc_getAssociatedObject(self, kHTYYTestVersion);
}

- (void)setHt_version:(NSString *)version {
    objc_setAssociatedObject(self, kHTYYTestVersion, version, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

@end
