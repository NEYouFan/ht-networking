//
//  HTDemoPhotoInfo.h
//  HTHttpDemo
//
//  Created by Wang Liping on 15/9/18.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import "HTNetworking.h"

@interface HTDemoPhotoInfo : HTHTTPModel

@property (nonatomic, copy) NSString *uuid;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *imageUrl;
@property (nonatomic, copy) NSString *thumbImageUrl;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *comment;
@property (nonatomic, copy) NSString *address;
@property (nonatomic, copy) NSString *author;

@end







