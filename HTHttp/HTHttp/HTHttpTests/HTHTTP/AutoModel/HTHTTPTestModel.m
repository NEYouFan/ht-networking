//
//  HTHTTPTestModel.m
//  HTHttp
//
//  Created by Wangliping on 16/1/7.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#import "HTHTTPTestModel.h"
#import "HTHTTPAddress.h"
#import "RKObjectMapping.h"

@implementation HTHTTPTestModel

+ (RKMapping *)manuallyMapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[HTHTTPTestModel class]];
    [mapping addAttributeMappingsFromArray:@[@"name", @"count", @"isSpecial", @"comments", @"htVersion"]];
    
    RKMapping *addressMapping = [HTHTTPAddress manuallyMapping];
    [mapping addRelationshipMappingWithSourceKeyPath:@"simpleAddress" mapping:addressMapping];
    
    return mapping;
}

@end
