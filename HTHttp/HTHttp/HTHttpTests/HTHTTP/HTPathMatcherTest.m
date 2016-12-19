//
//  HTPathMatcherTest.m
//  HTHttp
//
//  Created by Wang Liping on 15/9/10.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "RKPathMatcher.h"
#import "HTHttpTest.h"
#import "HTUserInfo.h"

@interface HTPathMatcherTest : XCTestCase

@end

@implementation HTPathMatcherTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    XCTAssert(YES, @"Pass");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}


- (void)testRKPathMatch {
    RKPathMatcher *matcher = [RKPathMatcher pathMatcherWithPattern:@"http://localhost:3000/user"];
    NSDictionary *parsedArguments = nil;
    BOOL isMatch1 = [matcher matchesPath:@"http://localhost:3000/user?name=hehe" tokenizeQueryStrings:NO parsedArguments:&parsedArguments];
    BOOL isMatch2 = [matcher matchesPath:@"http://localhost:3000/user/JsonId" tokenizeQueryStrings:NO parsedArguments:&parsedArguments];
    NSLog(@"%d, %d", isMatch1, isMatch2);
    
    
    matcher = [RKPathMatcher pathMatcherWithPattern:@"localhost:3000/user"];
    isMatch1 = [matcher matchesPath:@"http://localhost:3000/user?name=hehe" tokenizeQueryStrings:NO parsedArguments:&parsedArguments];
    isMatch2 = [matcher matchesPath:@"http://localhost:3000/user/JsonId" tokenizeQueryStrings:NO parsedArguments:&parsedArguments];
    NSLog(@"%d, %d", isMatch1, isMatch2);
    
    matcher = [RKPathMatcher pathMatcherWithPattern:@"http://localhost:3000/user/JsonId"];
    isMatch1 = [matcher matchesPath:@"http://localhost:3000/user?name=hehe" tokenizeQueryStrings:NO parsedArguments:&parsedArguments];
    isMatch2 = [matcher matchesPath:@"http://localhost:3000/user/JsonId" tokenizeQueryStrings:NO parsedArguments:&parsedArguments];
    NSLog(@"%d, %d", isMatch1, isMatch2);
    
    matcher = [RKPathMatcher pathMatcherWithPattern:@"http://localhost/user"];
    isMatch1 = [matcher matchesPath:@"http://localhost/user?name=hehe" tokenizeQueryStrings:NO parsedArguments:&parsedArguments];
    isMatch2 = [matcher matchesPath:@"http://localhost/user/JsonId" tokenizeQueryStrings:NO parsedArguments:&parsedArguments];
    NSLog(@"%d, %d", isMatch1, isMatch2);
    
    matcher = [RKPathMatcher pathMatcherWithPattern:@"/user"];
    isMatch1 = [matcher matchesPath:@"/user?name=hehe" tokenizeQueryStrings:NO parsedArguments:&parsedArguments];
    isMatch2 = [matcher matchesPath:@"/user1" tokenizeQueryStrings:NO parsedArguments:&parsedArguments];
    BOOL isMatch3 = [matcher matchesPath:@"/test/user" tokenizeQueryStrings:NO parsedArguments:&parsedArguments];
    NSLog(@"%d, %d, %d", isMatch1, isMatch2, isMatch3);
}


- (void)testFullPathPattern {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[HTUserInfo class]];
    [mapping addAttributeMappingsFromArray:@[@"userId", @"balance"]];
    
    [mapping addAttributeMappingsFromDictionary:@{@"version":@"name", @"status":@"password"}];
    // RKObjectManager修正后, Path pattern可使用全路径.
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping method:RKRequestMethodGET pathPattern:@"http://localhost:3000/user" keyPath:@"data" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    RKObjectManager *manager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:@"http://baidu:3000"]];
    [RKMIMETypeSerialization registerClass:[RKNSJSONSerialization class] forMIMEType:@"text/plain"];
    [manager addResponseDescriptor:responseDescriptor];
    
    [manager getObject:nil path:@"http://localhost:3000/user" parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        HTUserInfo *userInfo = [mappingResult.dictionary objectForKey:@"data"];
        expect([userInfo isKindOfClass:[HTUserInfo class]]).to.equal(YES);
        expect([userInfo.name length] > 0).to.equal(YES);
        
        CFRunLoopRef runLoopRef = CFRunLoopGetCurrent();
        CFRunLoopStop(runLoopRef);
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        expect(NO).to.equal(YES);
        CFRunLoopRef runLoopRef = CFRunLoopGetCurrent();
        CFRunLoopStop(runLoopRef);
    }];
    
    CFRunLoopRun();
}

@end
