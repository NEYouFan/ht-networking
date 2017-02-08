//
//  HTMockUserInfo.h
//  HTHttpDemo
//
//  Created by Wangliping on 16/1/21.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HTMockUserInfo : NSObject

@property (nonatomic, copy) NSString *accessToken;
@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *testToken;
@property (nonatomic, copy) NSString *refreshToken;
@property (nonatomic, assign) BOOL admin;
@property (nonatomic, assign) CGFloat expireIn;
@property (nonatomic, assign) CGFloat refreshTokenExpireIn;

@end
