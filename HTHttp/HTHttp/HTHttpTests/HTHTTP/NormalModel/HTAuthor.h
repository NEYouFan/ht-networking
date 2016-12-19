//
//  HTAuthor.h
//  HTHttp
//
//  Created by Wangliping on 16/1/5.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HTArticle;
@class HTAddress;
@class RKMapping;

@interface HTAuthor : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) HTArticle *article;
@property (nonatomic, strong) HTAddress *address;

+ (RKMapping *)manuallyMapping;

@end
