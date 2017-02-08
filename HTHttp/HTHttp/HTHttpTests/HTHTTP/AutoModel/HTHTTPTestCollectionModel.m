//
//  HTHTTPTestCollectionModel.m
//  HTHttp
//
//  Created by Wangliping on 16/1/7.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#import "HTHTTPTestCollectionModel.h"
#import "RKObjectMapping.h"
#import "HTHTTPArticle.h"
#import "HTHTTPAddress.h"

@implementation HTHTTPTestCollectionModel

+ (NSDictionary *)collectionCustomObjectTypes {
    return @{@"articles": @"HTHTTPArticle"};
}

+ (RKMapping *)manuallyMapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[HTHTTPTestCollectionModel class]];
    [mapping addAttributeMappingsFromArray:@[@"name", @"count", @"isSpecial", @"comments", @"htVersion"]];
    
    RKMapping *addressMapping = [HTHTTPAddress manuallyMapping];
    [mapping addRelationshipMappingWithSourceKeyPath:@"simpleAddress" mapping:addressMapping];

    RKMapping *articleMapping = [HTHTTPArticle manuallyMapping];
    [mapping addRelationshipMappingWithSourceKeyPath:@"articles" mapping:articleMapping];
    
    return mapping;
}

@end
