//
//  HTSpecialModel.m
//  HTHttpDemo
//
//  Created by Wangliping on 15/12/8.
//  Copyright © 2015年 NetEase. All rights reserved.
//

#import "HTSpecialModel.h"
#import "NSObject+HTModel.h"
#import "HTModelProtocol.h"

@interface HTSpecialModel() <HTModelProtocol>

@end

@implementation HTSpecialModel

//+ (NSDictionary *)collectionCustomObjectTypes {
//    return @{@"addressList": @"HTSimpleAddress"};
//}

- (instancetype)init {
    self = [super init];
    if (self) {
//        _count = 5;
    }
    
    return self;
}

- (void)updateCount {
    _count = 60;
}


#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [self ht_modelEncodeWithCoder:aCoder];
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    return [self ht_modelInitWithCoder:aDecoder];
}

#pragma mark - NSCoping

- (id)copyWithZone:(nullable NSZone *)zone {
    return [self ht_modelCopy];
}

@end
