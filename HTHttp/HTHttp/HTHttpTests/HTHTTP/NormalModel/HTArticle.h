//
//  HTArticle.h
//  HTHttp
//
//  Created by Wangliping on 16/1/5.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RKMapping;

@interface HTArticle : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, strong) NSArray<NSString *> *chapters;
@property (nonatomic, assign) BOOL isNovel;

+ (RKMapping *)manuallyMapping;

@end
