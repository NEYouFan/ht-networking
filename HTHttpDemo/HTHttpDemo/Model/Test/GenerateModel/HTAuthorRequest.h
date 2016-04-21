//
//  HTAuthorRequest.h
//  HTHttpDemo
//
//  Created by Wangliping on 15/11/13.
//  Copyright © 2015年 NetEase. All rights reserved.
//

#import "HTBaseRequest.h"

@class HTAddress;

@interface HTAuthorRequest : HTBaseRequest

@property (nonatomic, strong) HTAddress *address;

@end
