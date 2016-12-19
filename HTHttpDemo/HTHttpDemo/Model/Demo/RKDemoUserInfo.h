//
//  RKEUserInfo.h
//  RKExample
//
//  Created by NetEase on 15/7/22.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RKDemoUserInfo : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *password;
@property (nonatomic, assign) long userId;
@property (nonatomic, assign) long balance;
@property (nonatomic, copy) NSString *version;

@end
