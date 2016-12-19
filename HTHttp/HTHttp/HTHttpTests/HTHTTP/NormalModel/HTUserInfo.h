//
//  HTUserInfo.h
//  HTHttp
//
//  Created by Wangliping on 16/1/4.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RKMapping;

// Test model class with our own server.
@interface HTUserInfo : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *password;
@property (nonatomic, assign) long userId;
@property (nonatomic, assign) long balance;
@property (nonatomic, copy) NSString *version;

+ (RKMapping *)manuallyMapping;

@end
