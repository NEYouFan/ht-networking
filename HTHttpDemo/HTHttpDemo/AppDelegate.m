//
//  AppDelegate.m
//  HTHttpDemo
//
//  Created by NetEase on 15/7/23.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import "AppDelegate.h"
#import "HTLogFormatter.h"
#import "CocoaLumberjack.h"
#import "RKLog.h"
#import "HTNetworking.h"

static NSString * const HTDemoBaseUrl = @"http://localhost:3000";

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)initNetworking {
    [RKMIMETypeSerialization registerClass:[RKNSJSONSerialization class] forMIMEType:@"text/plain"];
    NSURL *baseURL = [NSURL URLWithString:HTDemoBaseUrl];
    HTNetworkingInit(baseURL);
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
//    RKLogConfigureByName("RestKit", RKlcl_vDebug);
//    RKLogConfigureFromEnvironment();
    
    // Override point for customization after application launch.
#if DEBUG
    //debug版本，打开ASL和TTY，使用ModuleFormatter输出 module名
    DDTTYLogger.sharedInstance.logFormatter = [HTLogFormatter new];
    [DDLog addLogger:DDTTYLogger.sharedInstance];
    [DDLog addLogger:DDASLLogger.sharedInstance];
    [[DDTTYLogger sharedInstance] setColorsEnabled:YES];
    
    DDFileLogger * fileLogger = [[DDFileLogger alloc] init];
    
    fileLogger.maximumFileSize = 1024 * 1;  //  1 KB
    fileLogger.rollingFrequency = 60;       // 60 Seconds
    
    fileLogger.logFileManager.maximumNumberOfLogFiles = 4;
    
    [DDLog addLogger:fileLogger withLevel:DDLogLevelInfo];
#else
    //release版，关闭ASL，打开TTY和file logger，将所有log level设置为error
    [DDLog addLogger:DDASLLogger.sharedInstance];
    
    DDFileLogger * fileLogger = [[DDFileLogger alloc] init];
    
    fileLogger.maximumFileSize = 1024 * 1;  //  1 KB
    fileLogger.rollingFrequency = 60;       // 60 Seconds
    
    fileLogger.logFileManager.maximumNumberOfLogFiles = 4;
    
    [DDLog addLogger:fileLogger withLevel:DDLogLevelError];
#endif
    
    [self initNetworking];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
