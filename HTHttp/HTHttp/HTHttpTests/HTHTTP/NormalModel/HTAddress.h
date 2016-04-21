//
//  HTAddress.h
//  HTHttp
//
//  Created by Wangliping on 16/1/5.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RKMapping;

@interface HTAddress : NSObject

@property (nonatomic, copy) NSString *province;
@property (nonatomic, copy) NSString *city;

+ (RKMapping *)manuallyMapping;

@end
