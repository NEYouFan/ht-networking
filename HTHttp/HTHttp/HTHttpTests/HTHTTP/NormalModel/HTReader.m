//
//  HTReader.m
//  HTHttp
//
//  Created by Wangliping on 16/1/5.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#import "HTReader.h"
#import "RKObjectMapping.h"
#import "HTArticle.h"
#import "HTAddress.h"

@implementation HTReader

+ (RKMapping *)manuallyMapping {
    RKObjectMapping *manuallyMapping = [RKObjectMapping mappingForClass:[HTReader class]];
    [manuallyMapping addAttributeMappingsFromArray:@[@"name", @"favoriteList"]];
    
    [manuallyMapping addRelationshipMappingWithSourceKeyPath:@"articles" mapping:[HTArticle manuallyMapping]];
    [manuallyMapping addRelationshipMappingWithSourceKeyPath:@"address" mapping:[HTAddress manuallyMapping]];
    
    return manuallyMapping;
}

+ (RKMapping *)manuallyMappingWithBlackPropertyList:(NSArray *)blackPropertyList {
    RKObjectMapping *manuallyMapping = [RKObjectMapping mappingForClass:[HTReader class]];
    
    NSMutableArray *propertyList = [NSMutableArray array];
    if (![blackPropertyList containsObject:@"name"]) {
        [propertyList addObject:@"name"];
    }

    if (![blackPropertyList containsObject:@"favoriteList"]) {
        [propertyList addObject:@"favoriteList"];
    }

    [manuallyMapping addAttributeMappingsFromArray:propertyList];
    if (![blackPropertyList containsObject:@"articles"]) {
        [manuallyMapping addRelationshipMappingWithSourceKeyPath:@"articles" mapping:[HTArticle manuallyMapping]];
    }

    if (![blackPropertyList containsObject:@"address"]) {
        [manuallyMapping addRelationshipMappingWithSourceKeyPath:@"address" mapping:[HTAddress manuallyMapping]];
    }
    
    return manuallyMapping;
}

#pragma mark - HTModelProtocol

+ (NSDictionary *)collectionCustomObjectTypes {
    return @{@"articles":@"HTArticle"};
}

@end
