//
//  HTGetCompanyRequest.m
//  HTHttpDemo
//
//  Created by Wangliping on 15/11/16.
//  Copyright © 2015年 NetEase. All rights reserved.
//

#import "HTGetCompanyRequest.h"
#import "HTDemoHelper.h"
#import "HTCampany.h"

@implementation HTGetCompanyRequest

+ (RKResponseDescriptor *)responseDescriptor {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[HTCampany1 class]];
    [mapping addAttributeMappingsFromArray:[HTDemoHelper getPropertyList:[HTCampany1 class]]];
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping method:RKRequestMethodAny pathPattern:@"/photolist" keyPath:@"photolist" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    return responseDescriptor;
}

@end
