//
//  HTHTTPAddress.h
//  HTHttp
//
//  Created by Wangliping on 16/1/7.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#import "HTHTTPModel.h"

@interface HTHTTPAddress : HTHTTPModel

@property (nonatomic, copy) NSString *province;
@property (nonatomic, copy) NSString *city;

+ (RKMapping *)manuallyMapping;

@end
