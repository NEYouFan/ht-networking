//
//  HTDemoSepcList.h
//  HTHttpDemo
//
//  Created by Wangliping on 15/10/29.
//  Copyright © 2015年 NetEase. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HTDemoSpec : NSObject

@property (nonatomic, assign) NSInteger listId;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) NSInteger type;
@property (nonatomic, strong) NSMutableArray *skuSpecValueList;

@end
