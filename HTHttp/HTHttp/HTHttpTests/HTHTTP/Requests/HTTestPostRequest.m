//
//  HTTestPostRequest.m
//  HTHttp
//
//  Created by Wangliping on 16/1/5.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#import "HTTestPostRequest.h"
#import "HTPhotoInfo.h"
#import "RestKit.h"

@implementation HTTestPostRequest

+ (RKRequestMethod)requestMethod {
    return RKRequestMethodPOST;
}

+ (NSString *)requestUrl {
    return @"/collection";
}

- (NSDictionary *)requestParams {
    return @{@"name":@"lwang", @"password":@"test", @"type":@"photolist"};
}

+ (RKResponseDescriptor *)responseDescriptor {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[HTPhotoInfo class]];
    [mapping addAttributeMappingsFromArray:[HTPhotoInfo propertyList]];
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping method:RKRequestMethodAny pathPattern:@"/collection" keyPath:@"photolist" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    return responseDescriptor;
}

@end
