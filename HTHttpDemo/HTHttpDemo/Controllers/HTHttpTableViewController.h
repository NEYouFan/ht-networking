//
//  HTHttpTableViewController.h
//  HTHttpDemo
//
//  Created by Wang Liping on 15/9/17.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HTHttpTableViewController : UIViewController

/**
 *  生成方法名列表. 每个方法名对应一个测试方法.
 *
 *  @return 返回一个NSString的数组.
 */
- (NSArray *)generateMethodNameList;

@end
