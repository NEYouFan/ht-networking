//
//  HTHTTPPhotoInfo.m
//  HTHttp
//
//  Created by Wangliping on 16/1/7.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#import "HTHTTPPhotoInfo.h"
#import "RKObjectMapping.h"

@implementation HTHTTPPhotoInfo

+ (NSArray *)propertyList {
    return @[@"uuid", @"name", @"title", @"imageUrl", @"thumbImageUrl", @"content", @"comment", @"address", @"author", @"htVersion"];
}

+ (RKMapping *)manuallyMapping {
    RKObjectMapping *manuallyMapping = [RKObjectMapping mappingForClass:[HTHTTPPhotoInfo class]];
    [manuallyMapping addAttributeMappingsFromArray:[HTHTTPPhotoInfo propertyList]];
    
    return manuallyMapping;
}

@end
