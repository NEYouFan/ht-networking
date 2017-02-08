//
//  HTHTTPFamousAuthor.m
//  HTHttp
//
//  Created by Wangliping on 16/1/7.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#import "HTHTTPFamousAuthor.h"
#import "HTHTTPArticle.h"
#import "HTHTTPAddress.h"
#import "RKObjectMapping.h"

@implementation HTHTTPFamousAuthor

+ (RKMapping *)manuallyMapping {
    RKObjectMapping *manuallyMapping = [RKObjectMapping mappingForClass:[HTHTTPFamousAuthor class]];
    [manuallyMapping addAttributeMappingsFromArray:@[@"name", @"fans", @"htVersion"]];
    
    [manuallyMapping addRelationshipMappingWithSourceKeyPath:@"article" mapping:[HTHTTPArticle manuallyMapping]];
    [manuallyMapping addRelationshipMappingWithSourceKeyPath:@"address" mapping:[HTHTTPAddress manuallyMapping]];
    
    return manuallyMapping;
}

@end
