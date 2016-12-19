//
//  HTHTTPUserInfo.h
//  HTHttp
//
//  Created by Wangliping on 16/1/7.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#import "HTHTTPModel.h"

@interface HTHTTPUserInfo : HTHTTPModel

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *password;
@property (nonatomic, assign) long userId;
@property (nonatomic, assign) long balance;
@property (nonatomic, copy) NSString *version;

@end
