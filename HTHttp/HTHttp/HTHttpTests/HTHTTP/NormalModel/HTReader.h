//
//  HTReader.h
//  HTHttp
//
//  Created by Wangliping on 16/1/5.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTModelProtocol.h"

@class RKMapping;
@class HTArticle;
@class HTAddress;

// TODO: (添加到文档) Note: 如果一个类在数组里包含有其他类型的Model, 那么在调用ht_modelMapping之前要么遵循HTModelProtocol协议，要么从HTHTTPModel派生，否则是无法正确自动取到ht_modeMapping的.
@interface HTReader : NSObject <HTModelProtocol>

@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) NSArray<HTArticle *> *articles;
@property (nonatomic, strong) HTAddress *address;
@property (nonatomic, strong) NSArray<NSString *> *favoriteList;

+ (RKMapping *)manuallyMapping;

+ (RKMapping *)manuallyMappingWithBlackPropertyList:(NSArray *)blackPropertyList;

@end
