//
//  HTHTTPFamousAuthor.h
//  HTHttp
//
//  Created by Wangliping on 16/1/7.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#import "HTHTTPAuthor.h"

@interface HTHTTPFamousAuthor : HTHTTPAuthor

@property (nonatomic, copy) NSArray<NSString *> *fans;

+ (RKMapping *)manuallyMapping;

@end
