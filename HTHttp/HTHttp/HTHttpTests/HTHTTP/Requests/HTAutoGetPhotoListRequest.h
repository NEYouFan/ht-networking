//
//  HTAutoGetPhotoListRequest.h
//  HTHttp
//
//  Created by Wangliping on 16/1/7.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#import "HTBaseRequest.h"

@interface HTAutoGetPhotoListRequest : HTBaseRequest

@property (nonatomic, assign) CGFloat limit;
@property (nonatomic, assign) CGFloat offset;

@end
