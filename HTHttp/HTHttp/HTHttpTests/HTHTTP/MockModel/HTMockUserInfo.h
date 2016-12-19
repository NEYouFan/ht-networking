//
//  HTMockUserInfo.h
//  HTHttp
//
//  Created by Wangliping on 16/1/25.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@interface HTMockUserInfo : NSObject

@property (nonatomic, copy) NSString *accessToken;
@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *yunxinToken;
@property (nonatomic, copy) NSString *refreshToken;
@property (nonatomic, assign) BOOL admin;
@property (nonatomic, assign) CGFloat expireIn;
@property (nonatomic, assign) CGFloat refreshTokenExpireIn;

@end
