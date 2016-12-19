//
//  RKWikiPage.h
//  HTHttpDemo
//
//  Created by Wangliping on 15/12/9.
//  Copyright © 2015年 NetEase. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RKWikiPage : NSObject

@property (nonatomic, copy) NSString *body;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) NSData *data;
@property (nonatomic, strong) NSArray<NSData *> *commentData;

@end
