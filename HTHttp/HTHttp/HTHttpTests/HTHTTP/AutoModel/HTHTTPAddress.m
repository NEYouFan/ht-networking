//
//  HTHTTPAddress.m
//  HTHttp
//
//  Created by Wangliping on 16/1/7.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#import "HTHTTPAddress.h"
#import "RKObjectMapping.h"

@implementation HTHTTPAddress

+ (RKMapping *)manuallyMapping {
    RKObjectMapping *manuallyMapping = [RKObjectMapping mappingForClass:[HTHTTPAddress class]];
    // This mapping is used for testing so all manually mapping will include "htVersion" as it is defined in base class and it is harmless.
    [manuallyMapping addAttributeMappingsFromArray:@[@"province", @"city", @"htVersion"]];
    
    return manuallyMapping;
}

@end
