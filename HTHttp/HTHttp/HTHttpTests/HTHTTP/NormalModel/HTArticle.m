//
//  HTArticle.m
//  HTHttp
//
//  Created by Wangliping on 16/1/5.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#import "HTArticle.h"
#import "RKObjectMapping.h"

@implementation HTArticle

+ (RKMapping *)manuallyMapping {
    RKObjectMapping *manuallyMapping = [RKObjectMapping mappingForClass:[HTArticle class]];
    [manuallyMapping addAttributeMappingsFromArray:@[@"title", @"content", @"chapters", @"isNovel"]];
    
    return manuallyMapping;
}

@end
