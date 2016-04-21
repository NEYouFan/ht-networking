//
//  HTTestModel.h
//  HTHttp
//
//  Created by Wangliping on 16/1/5.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HTAddress;

// 普通的TestModel.
// 1 不包含特殊类型的属性例如CFRef, SEL, IMP, NSURLRequest等.
// 2 不包含readonly或者dynamic的属性
// 3 不包含NSDate, 主要是为了方便测试
// 4 不包含NSArray<HTAddress *>等特殊类型.
// 5 直接从NSObject 派生, 不从HTHTTPModel派生，不遵循HTModelDelegate协议.
// Note: NSData无法直接转换, 需要额外处理.
@interface HTTestModel : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) NSInteger count;
@property (nonatomic, assign) BOOL isSpecial;
@property (nonatomic, strong) HTAddress *simpleAddress;
@property (nonatomic, strong) NSArray<NSString *> *comments;
@property (nonatomic, strong) NSArray<NSData *> *commentData;
@property (nonatomic, strong) NSData *data;
@property (nonatomic, strong) NSURL *url;

@end
