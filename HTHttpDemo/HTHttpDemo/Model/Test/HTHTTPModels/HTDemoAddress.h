//
//  HTDemoAddress.h
//  HTHttpDemo
//
//  Created by Wangliping on 15/11/17.
//  Copyright © 2015年 NetEase. All rights reserved.
//

#import "HTHTTPModel.h"

@interface HTDemoAddress : HTHTTPModel

/**
 *  省
 */
@property (nonatomic, copy) NSString *province;

/**
 *  城市
 */
@property (nonatomic, copy) NSString *city;

@end
