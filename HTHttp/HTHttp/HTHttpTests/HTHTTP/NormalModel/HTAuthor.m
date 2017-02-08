//
//  HTAuthor.m
//  HTHttp
//
//  Created by Wangliping on 16/1/5.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#import "HTAuthor.h"
#import "RKObjectMapping.h"
#import "HTArticle.h"
#import "HTAddress.h"

@implementation HTAuthor

+ (RKMapping *)manuallyMapping {
    RKObjectMapping *manuallyMapping = [RKObjectMapping mappingForClass:[HTAuthor class]];
    [manuallyMapping addAttributeMappingsFromArray:@[@"name"]];
    
    [manuallyMapping addRelationshipMappingWithSourceKeyPath:@"article" mapping:[HTArticle manuallyMapping]];
    [manuallyMapping addRelationshipMappingWithSourceKeyPath:@"address" mapping:[HTAddress manuallyMapping]];
    
    return manuallyMapping;
}

@end
