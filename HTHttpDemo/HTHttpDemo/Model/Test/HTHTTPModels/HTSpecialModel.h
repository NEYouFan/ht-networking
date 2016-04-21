//
//  HTSpecialModel.h
//  HTHttpDemo
//
//  Created by Wangliping on 15/12/8.
//  Copyright © 2015年 NetEase. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HTSimpleAddress;

@interface HTSpecialModel : NSObject

@property (nonatomic, copy) NSString *name;
//@property (nonatomic, assign, readonly) NSInteger count;
@property (nonatomic, assign) NSInteger count;
@property (nonatomic, assign) BOOL isSpecial;
@property (nonatomic, strong) HTSimpleAddress *simpleAddress;
@property (nonatomic, strong) NSArray<NSString *> *comments;
@property (nonatomic, strong) NSArray<HTSimpleAddress *> *addressList;
@property (nonatomic, strong) NSArray<NSData *> *commentData;
@property (nonatomic, strong) NSData *data;
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) NSURLRequest *request;
@property (nonatomic, assign) SEL testSelector;
@property (nonatomic, assign) IMP testImplementation;
@property (nonatomic, assign) CFStringRef stringRef;
@property (nonatomic, assign, setter=specialNameSet:, getter=specialNameGet) NSString *myName;

- (void)updateCount;

@end
