//
//  HTHTTPDate.m
//  Pods
//
//  Created by Wangliping on 15/12/1.
//
//

#import "HTHTTPDate.h"

@implementation HTHTTPDate

+ (instancetype)sharedInstance {
    static HTHTTPDate *sharedDate = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        sharedDate = [[HTHTTPDate alloc] init];
    });
    
    return sharedDate;
}

- (NSDate *)now {
    NSDate *currentTime = [_delegate respondsToSelector:@selector(getCurrentTime)] ? [_delegate getCurrentTime] : [NSDate date];
    return currentTime;
}

@end
