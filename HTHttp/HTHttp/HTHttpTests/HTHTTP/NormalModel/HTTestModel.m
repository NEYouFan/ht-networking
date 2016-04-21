//
//  HTTestModel.m
//  HTHttp
//
//  Created by Wangliping on 16/1/5.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#import "HTTestModel.h"
#import "NSObject+HTModel.h"

@implementation HTTestModel

- (NSUInteger)hash {
    return [self ht_modelHash];
}

- (BOOL)isEqual:(id)object {
    return [self ht_modelIsEqual:object];
}

@end
