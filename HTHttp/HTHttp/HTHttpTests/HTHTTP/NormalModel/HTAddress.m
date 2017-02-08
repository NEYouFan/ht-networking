//
//  HTAddress.m
//  HTHttp
//
//  Created by Wangliping on 16/1/5.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#import "HTAddress.h"
#import "RKObjectMapping.h"

@implementation HTAddress

+ (RKMapping *)manuallyMapping {
    RKObjectMapping *manuallyMapping = [RKObjectMapping mappingForClass:[HTAddress class]];
    [manuallyMapping addAttributeMappingsFromArray:@[@"province", @"city"]];
    
    return manuallyMapping;
}

@end
