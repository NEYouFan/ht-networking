//
//  HTDemoGetPhotoListRequest.m
//  HTHttpDemo
//
//  Created by Wang Liping on 15/10/10.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import "HTDemoGetPhotoListRequest.h"
#import "HTDemoPhotoInfo.h"
#import "HTDemoHelper.h"

@implementation HTDemoGetPhotoListRequest

- (instancetype)init {
    self = [super init];
    if (self) {
        // 默认的分页个数为20.
        _limit = 20;
    }
    
    return self;
}

+ (NSString *)requestUrl {
    return @"/photolist";
}

- (NSDictionary *)requestParams {
    return @{@"limit":@(_limit), @"offset":@(_offset)};
}

+ (RKResponseDescriptor *)responseDescriptor {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[HTDemoPhotoInfo class]];
    [mapping addAttributeMappingsFromArray:[HTDemoHelper getPropertyList:[HTDemoPhotoInfo class]]];
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping method:RKRequestMethodAny pathPattern:@"/photolist" keyPath:@"photolist" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    return responseDescriptor;
}

@end
