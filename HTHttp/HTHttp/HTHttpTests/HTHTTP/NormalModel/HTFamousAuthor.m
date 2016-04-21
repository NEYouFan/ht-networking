//
//  HTFamousAuthor.m
//  HTHttp
//
//  Created by Wangliping on 16/1/5.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#import "HTFamousAuthor.h"
#import "RKObjectMapping.h"
#import "HTArticle.h"
#import "HTAddress.h"

@implementation HTFamousAuthor

+ (RKMapping *)manuallyMapping {
    RKObjectMapping *manuallyMapping = [RKObjectMapping mappingForClass:[HTFamousAuthor class]];
    [manuallyMapping addAttributeMappingsFromArray:@[@"name", @"fans"]];
    
    [manuallyMapping addRelationshipMappingWithSourceKeyPath:@"article" mapping:[HTArticle manuallyMapping]];
    [manuallyMapping addRelationshipMappingWithSourceKeyPath:@"address" mapping:[HTAddress manuallyMapping]];
    
    return manuallyMapping;
}


// 手写的当前类的属性.
+ (NSArray *)manualPropertyList {
    return @[@"fans"];
}

+ (NSDictionary *)manualPropertyDic {
    return @{@"fans": @"NSArray"};
}

// 手写的包含父类(除NSObject外)的属性.
+ (NSArray *)manualAllPropertyList {
    return @[@"name", @"article", @"address", @"fans"];
}

+ (NSDictionary *)manualAllPropertyDic {
    return @{@"name": @"NSString", @"article":@"HTArticle", @"address":@"HTAddress", @"fans": @"NSArray"};
}

@end
