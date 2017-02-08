//
//  HTHTTPArticle.m
//  HTHttp
//
//  Created by Wangliping on 16/1/7.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#import "HTHTTPArticle.h"
#import "RKObjectMapping.h"

@implementation HTHTTPArticle

+ (RKMapping *)manuallyMapping {
    RKObjectMapping *manuallyMapping = [RKObjectMapping mappingForClass:[HTHTTPArticle class]];
    [manuallyMapping addAttributeMappingsFromArray:@[@"title", @"content", @"chapters", @"isNovel", @"htVersion"]];
    
    return manuallyMapping;
}

@end
