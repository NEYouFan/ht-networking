//
//  HTUserInfo.m
//  HTHttp
//
//  Created by Wangliping on 16/1/4.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#import "HTUserInfo.h"
#import "RKObjectMapping.h"

@implementation HTUserInfo

+ (RKMapping *)manuallyMapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[HTUserInfo class]];
    [mapping addAttributeMappingsFromArray:@[@"userId", @"balance", @"version", @"name", @"password"]];
    return mapping;
}

@end
