//
//  HTAuthor.h
//  HTHttpDemo
//
//  Created by Wangliping on 15/11/13.
//  Copyright © 2015年 NetEase. All rights reserved.
//

#import "HTHTTPModel.h"

@class HTAddress;

@interface HTAuthor : HTHTTPModel

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
@property (nonatomic, strong) HTAddress *address;

@end
