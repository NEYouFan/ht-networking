//
//  HTGetPhotoListRequest.m
//  HTHttp
//
//  Created by Wangliping on 16/1/4.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#import "HTGetPhotoListRequest.h"
#import "RKObjectMapping.h"
#import "RKResponseDescriptor.h"
#import "HTPhotoInfo.h"

@implementation HTGetPhotoListRequest

+ (NSString *)requestUrl {
    return @"/photolist";
}

- (NSDictionary *)requestParams {
    return @{@"limit":@(20), @"offset":@(0)};
}

+ (RKResponseDescriptor *)responseDescriptor {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[HTPhotoInfo class]];
    [mapping addAttributeMappingsFromArray:[HTPhotoInfo propertyList]];
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping method:RKRequestMethodAny pathPattern:@"/photolist" keyPath:@"photolist" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    return responseDescriptor;
}

@end
