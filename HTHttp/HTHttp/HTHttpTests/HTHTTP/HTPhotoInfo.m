//
//  HTPhotoInfo.m
//  HTHttp
//
//  Created by Wangliping on 16/1/4.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#import "HTPhotoInfo.h"
#import "RKObjectMapping.h"

@implementation HTPhotoInfo

+ (NSArray *)propertyList {
    return @[@"uuid", @"name", @"title", @"imageUrl", @"thumbImageUrl", @"content", @"comment", @"address", @"author"];
}

+ (RKMapping *)manuallyMapping {
    RKObjectMapping *manuallyMapping = [RKObjectMapping mappingForClass:[HTPhotoInfo class]];
    [manuallyMapping addAttributeMappingsFromArray:[HTPhotoInfo propertyList]];
    
    return manuallyMapping;
}

@end
