//
//  HTCommentRequest.h
//  HTHttpDemo
//
//  Created by Wangliping on 15/11/13.
//  Copyright © 2015年 NetEase. All rights reserved.
//

#import "HTNetworking.h"

@class HTAuthor;

@interface HTCommentRequest : HTBaseRequest

@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *password;
@property (nonatomic, assign) CGFloat count;
@property (nonatomic, strong) HTAuthor *author;

@property (nonatomic, copy) NSString *cookie;
@property (nonatomic, copy) NSString *userInfo;

@end
