//
//  HTTestModelArchive.m
//  HTHttp
//
//  Created by Wangliping on 16/1/7.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#import "HTTestModelArchive.h"
#import "NSObject+HTModel.h"

@implementation HTTestModelArchive

- (void)encodeWithCoder:(NSCoder *)aCoder {
    return [self ht_modelEncodeWithCoder:aCoder];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    return [self ht_modelInitWithCoder:aDecoder];
}

- (NSUInteger)hash {
    return [self ht_modelHash];
}

- (BOOL)isEqual:(id)object {
    return [self ht_modelIsEqual:object];
}

@end
