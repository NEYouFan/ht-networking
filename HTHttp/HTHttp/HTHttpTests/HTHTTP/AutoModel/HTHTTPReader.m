//
//  HTHTTPReader.m
//  HTHttp
//
//  Created by Wangliping on 16/1/7.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#import "HTHTTPReader.h"
#import "RKObjectMapping.h"
#import "HTHTTPArticle.h"
#import "HTHTTPAddress.h"

@implementation HTHTTPReader

+ (RKMapping *)manuallyMapping {
    RKObjectMapping *manuallyMapping = [RKObjectMapping mappingForClass:[HTHTTPReader class]];
    [manuallyMapping addAttributeMappingsFromArray:@[@"name", @"favoriteList", @"htVersion"]];
    
    [manuallyMapping addRelationshipMappingWithSourceKeyPath:@"articles" mapping:[HTHTTPArticle manuallyMapping]];
    [manuallyMapping addRelationshipMappingWithSourceKeyPath:@"address" mapping:[HTHTTPAddress manuallyMapping]];
    
    return manuallyMapping;
}

#pragma mark - HTModelProtocol

+ (NSDictionary *)collectionCustomObjectTypes {
    return @{@"articles":@"HTHTTPArticle"};
}

@end
