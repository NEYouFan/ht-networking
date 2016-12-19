//
//  HTTestModelArchive.h
//  HTHttp
//
//  Created by Wangliping on 16/1/7.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#import <Foundation/Foundation.h>

// 在HTTestModel基础上去除了HTAddress类型的属性，因为HTAddress不支持NSCoding协议.
@interface HTTestModelArchive : NSObject <NSCoding>

@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) NSInteger count;
@property (nonatomic, assign) BOOL isSpecial;
@property (nonatomic, strong) NSArray<NSString *> *comments;
@property (nonatomic, strong) NSArray<NSData *> *commentData;
@property (nonatomic, strong) NSData *data;
@property (nonatomic, strong) NSURL *url;

@end
