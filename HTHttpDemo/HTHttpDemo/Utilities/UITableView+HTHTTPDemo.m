//
//  UITableView+HTHTTPDemo.m
//  HTHttpDemo
//
//  Created by Wang Liping on 15/9/17.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import "UITableView+HTHTTPDemo.h"

@implementation UITableView (HTHTTPDemo)

- (void)ht_DemoConfigViewTop:(UIView*)topView bottom:(UIView*)bottomView leading:(UIView*)leadingView trailing:(UIView*)trailingView constants:(NSArray*)conArr
{
    if (nil != conArr && [conArr count] < 4) {
        return;
    }
    
    self.translatesAutoresizingMaskIntoConstraints = NO;
    [self.superview addConstraint:[NSLayoutConstraint
                                   constraintWithItem:self
                                   attribute:NSLayoutAttributeTop
                                   relatedBy:NSLayoutRelationEqual
                                   toItem:topView ? topView : self.superview
                                   attribute:topView ? NSLayoutAttributeBottom : NSLayoutAttributeTop
                                   multiplier:1
                                   constant:conArr ? [conArr[0] floatValue] : 0]];
    [self.superview addConstraint:[NSLayoutConstraint
                                   constraintWithItem:self
                                   attribute:NSLayoutAttributeBottom
                                   relatedBy:NSLayoutRelationEqual
                                   toItem:bottomView ? bottomView : self.superview
                                   attribute:bottomView ? NSLayoutAttributeTop : NSLayoutAttributeBottom
                                   multiplier:1
                                   constant:conArr ? [conArr[1] floatValue] : 0]];
    [self.superview addConstraint:[NSLayoutConstraint
                                   constraintWithItem:self
                                   attribute:NSLayoutAttributeLeading
                                   relatedBy:NSLayoutRelationEqual
                                   toItem:leadingView ? leadingView : self.superview
                                   attribute:leadingView ? NSLayoutAttributeTrailing : NSLayoutAttributeLeading
                                   multiplier:1
                                   constant:conArr ? [conArr[2] floatValue] : 0]];
    [self.superview addConstraint:[NSLayoutConstraint
                                   constraintWithItem:self
                                   attribute:NSLayoutAttributeTrailing
                                   relatedBy:NSLayoutRelationEqual
                                   toItem:trailingView ? trailingView : self.superview
                                   attribute:trailingView ? NSLayoutAttributeLeading :NSLayoutAttributeTrailing
                                   multiplier:1
                                   constant:conArr ? [conArr[3] floatValue] : 0]];
    
}

@end
