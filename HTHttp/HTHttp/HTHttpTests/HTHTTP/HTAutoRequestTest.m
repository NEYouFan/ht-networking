//
//  HTAutoRequestTest.m
//  HTHttp
//
//  Created by Wangliping on 16/1/7.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "HTHttpTest.h"
#import "HTAutoGetPhotoListRequest.h"
#import "HTGetPhotoListRequest.h"
#import "HTNetworkingHelper.h"

/**
 *  针对自动生成请求相关机制的测试.
 */

@interface HTAutoRequestTest : XCTestCase

@end

@implementation HTAutoRequestTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    if (nil == [RKObjectManager sharedManager]) {
        [RKMIMETypeSerialization registerClass:[RKNSJSONSerialization class] forMIMEType:@"text/plain"];
        NSURL *baseURL = [NSURL URLWithString:@"http://localhost:3000"];
        HTNetworkingInit(baseURL);
    }
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

- (void)testAutoRequestParams {
    HTAutoGetPhotoListRequest *autoRequest = [[HTAutoGetPhotoListRequest alloc] init];
    autoRequest.limit = 20;
    autoRequest.offset = 0;
    NSDictionary *autoParams = [autoRequest requestParams];
    
    HTGetPhotoListRequest *request = [[HTGetPhotoListRequest alloc] init];
    NSDictionary *params = [request requestParams];
    
    expect([autoParams isEqualToDictionary:params]).to.equal(YES);
}

@end
