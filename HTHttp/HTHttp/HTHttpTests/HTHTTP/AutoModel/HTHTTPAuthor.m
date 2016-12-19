//
//  HTHTTPAuthor.m
//  HTHttp
//
//  Created by Wangliping on 16/1/7.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#import "HTHTTPAuthor.h"
#import "HTHTTPArticle.h"
#import "HTHTTPAddress.h"
#import "RKObjectMapping.h"

@implementation HTHTTPAuthor

+ (RKMapping *)manuallyMapping {
    RKObjectMapping *manuallyMapping = [RKObjectMapping mappingForClass:[HTHTTPAuthor class]];
    [manuallyMapping addAttributeMappingsFromArray:@[@"name", @"htVersion"]];
    
    [manuallyMapping addRelationshipMappingWithSourceKeyPath:@"article" mapping:[HTHTTPArticle manuallyMapping]];
    [manuallyMapping addRelationshipMappingWithSourceKeyPath:@"address" mapping:[HTHTTPAddress manuallyMapping]];
    
    return manuallyMapping;
}

@end
