//
//  HTDemoValidResultBlockRequest.m
//  HTHttpDemo
//
//  Created by Wangliping on 16/2/2.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#import "HTDemoValidResultBlockRequest.h"
#import "RKDemoUserInfo.h"

@implementation HTDemoValidResultBlockRequest

+ (NSString *)requestUrl {
    return @"/user";
}

+ (RKMapping *)responseMapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[RKDemoUserInfo class]];
    [mapping addAttributeMappingsFromArray:@[@"userId", @"balance", @"version"]];
    [mapping addAttributeMappingsFromDictionary:@{@"version":@"name", @"status":@"password"}];
    
    return mapping;
}

+ (NSString *)keyPath {
    return @"data";
}

- (HTValidResultBlock)validResultBlock {
    return ^(RKObjectRequestOperation *operation) {
        RKMappingResult *result = operation.mappingResult;
        if (0 == [result count]) {
            return NO;
        }

        return YES;
    };
}

@end
