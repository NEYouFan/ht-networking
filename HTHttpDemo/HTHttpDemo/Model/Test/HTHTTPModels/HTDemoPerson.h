//
//  HTDemoPerson.h
//  HTHttpDemo
//
//  Created by Wangliping on 15/11/17.
//  Copyright © 2015年 NetEase. All rights reserved.
//

#import "HTHTTPModel.h"

@interface HTDemoPerson : HTHTTPModel

/**
 *  姓名
 */
@property (nonatomic, copy) NSString *name;

/**
 *  测试嵌套. 对于多重嵌套，第二层不再解析HTDemoPerson的relationshipMapping.
 */
@property (nonatomic, strong) HTDemoPerson *son;

@end
