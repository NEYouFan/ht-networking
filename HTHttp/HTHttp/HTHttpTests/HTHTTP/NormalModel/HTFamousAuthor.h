//
//  HTFamousAuthor.h
//  HTHttp
//
//  Created by Wangliping on 16/1/5.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#import "HTAuthor.h"

@interface HTFamousAuthor : HTAuthor

@property (nonatomic, copy) NSArray<NSString *> *fans;

+ (RKMapping *)manuallyMapping;

// 手写的当前类的属性.
+ (NSArray *)manualPropertyList;
+ (NSDictionary *)manualPropertyDic;

// 手写的包含父类(除NSObject外)的属性.
+ (NSArray *)manualAllPropertyList;
+ (NSDictionary *)manualAllPropertyDic;

@end
