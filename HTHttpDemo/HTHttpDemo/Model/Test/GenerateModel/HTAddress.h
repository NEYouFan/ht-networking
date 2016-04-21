//
//  HTAddress.h
//  HTHttpDemo
//
//  Created by Wangliping on 15/11/20.
//  Copyright © 2015年 NetEase. All rights reserved.
//

#import "HTHTTPModel.h"

@interface HTAddress : HTHTTPModel

/**
 *  省
 */
@property (nonatomic, copy) NSString *province;

/**
 *  城市
 */
@property (nonatomic, copy) NSString *city;

@end
