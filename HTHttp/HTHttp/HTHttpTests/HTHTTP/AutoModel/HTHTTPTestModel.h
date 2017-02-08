//
//  HTHTTPTestModel.h
//  HTHttp
//
//  Created by Wangliping on 16/1/7.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#import "HTHTTPModel.h"

@class HTHTTPAddress;

// HTHTTPModel默认仅包含NSString, BOOL, HTHTTPModel子类，NSArray等类型，不需要测试NSData等.

@interface HTHTTPTestModel : HTHTTPModel

@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) NSInteger count;
@property (nonatomic, assign) BOOL isSpecial;
@property (nonatomic, strong) HTHTTPAddress *simpleAddress;
@property (nonatomic, strong) NSArray<NSString *> *comments;

+ (RKMapping *)manuallyMapping;

@end
