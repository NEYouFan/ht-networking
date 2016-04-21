//
//  HTDemoAuthor.h
//  HTHttpDemo
//
//  Created by Wangliping on 15/11/17.
//  Copyright © 2015年 NetEase. All rights reserved.
//

#import "HTHTTPModel.h"

@class HTDemoAddress;

@interface HTDemoAuthor : HTHTTPModel

/**
 *  姓名
 */
@property (nonatomic, copy) NSString *name;

/**
 *  电子邮箱
 */
@property (nonatomic, copy) NSString *email;

/**
 *  地址
 */
@property (nonatomic, strong) HTDemoAddress *address;

@end
