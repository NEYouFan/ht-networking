//
//  HTDemoRACPhotoListRequest.m
//  HTHttpDemo
//
//  Created by Wangliping on 16/2/15.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#import "HTDemoRACPhotoListRequest.h"

@implementation HTDemoRACPhotoListRequest

- (NSDictionary *)requestParams {
    if (0 == [_userName length]) {
        return [super requestParams];
    }
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:[super requestParams]];
    dic[@"name"] = _userName;
    return dic;
}

@end
