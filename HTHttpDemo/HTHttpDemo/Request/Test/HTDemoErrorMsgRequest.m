//
//  HTDemoErrorMsgRequest.m
//  HTHttpDemo
//
//  Created by Wangliping on 15/10/29.
//  Copyright © 2015年 NetEase. All rights reserved.
//

#import "HTDemoErrorMsgRequest.h"
#import "HTDemoSpec.h"
#import "HTDemoSpecValue.h"

@implementation HTDemoErrorMsgRequest

+ (NSString *)requestUrl {
    return @"/specTest";
}

+ (RKResponseDescriptor *)responseDescriptor {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[HTDemoSpec class]];
    // Note: 如果要加RelationshipMapping, 那么就不要把skuSpecValueList这个属性加进去.
    // 如果加了skuSpecValueList属性，但是没有加relationMapping, 那么会得到一个数组，该数组的每一项是未解析的字典.
    //    [mapping addAttributeMappingsFromArray:@[@"name", @"type", @"skuSpecValueList"]];
    [mapping addAttributeMappingsFromArray:@[@"name", @"type"]];
    
    // Note: Model的属性放在后面, JSON Key放在前面
    [mapping addAttributeMappingsFromDictionary:@{@"id":@"listId"}];
    
    RKObjectMapping *valueMapping = [RKObjectMapping mappingForClass:[HTDemoSpecValue class]];
    [valueMapping addAttributeMappingsFromArray:@[@"skuSpecId", @"picUrl", @"value"]];
    [valueMapping addAttributeMappingsFromDictionary:@{@"id":@"valueId"}];
    
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"skuSpecValueList"
                                                                            toKeyPath:@"skuSpecValueList"
                                                                          withMapping:valueMapping]];
    
//    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping method:RKRequestMethodGET pathPattern:@"/specTest" keyPath:@"skuSpecList" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];

    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping method:RKRequestMethodGET pathPattern:@"/specTest" keyPath:@"skuSpecList" statusCodes:nil];
    
    return responseDescriptor;
}

@end
