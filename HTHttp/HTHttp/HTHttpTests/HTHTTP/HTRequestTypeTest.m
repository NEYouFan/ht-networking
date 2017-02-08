//
//  HTRequestTypeTest.m
//  HTHttp
//
//  Created by Wangliping on 16/1/7.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "HTHttpTest.h"
#import "RKRequestTypeOperation.h"
#import "RKRequestTypes.h"
#import "RKConcreteHTTPRequestOperation.h"
#import "NSURLRequest+RKRequest.h"

/**
 *  Test different request type name.
 */

@interface RKHTTPRequestOperation ()

@property (nonatomic, strong) id<RKHTTPRequestOperationProtocol> httpRequestOperation;

@end

@interface HTRequestTypeTest : XCTestCase

@end

@implementation HTRequestTypeTest

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
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

- (void)testRequestOperationType {
    Class<RKHTTPRequestOperationProtocol> operationClass = [RKRequestTypeOperation operationForRequestType:RKRequestTypeHTTP];
    expect(operationClass == [RKConcreteHTTPRequestOperation class]).to.equal(YES);
   
    NSSet *registeredRequestTypes = [RKRequestTypeOperation registeredRequestTypes];
    expect([registeredRequestTypes containsObject:RKRequestTypeHTTP]).to.equal(YES);
    
    NSString *customRequestType = @"CustomRequestType";
    [RKRequestTypeOperation registerClass:[RKConcreteHTTPRequestOperation class] forRequestType:customRequestType];
    Class<RKHTTPRequestOperationProtocol> customOperationClass = [RKRequestTypeOperation operationForRequestType:customRequestType];
    expect(customOperationClass == [RKConcreteHTTPRequestOperation class]).to.equal(YES);
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.163.com"]];
    request.rk_requestTypeName = customRequestType;
    RKHTTPRequestOperation *operation = [[RKHTTPRequestOperation alloc] initWithRequest:request];
    expect([operation.httpRequestOperation isKindOfClass:[RKConcreteHTTPRequestOperation class]]).to.equal(YES);
    
    [RKRequestTypeOperation registerClass:[AFHTTPRequestOperation class] forRequestType:customRequestType];
    customOperationClass = [RKRequestTypeOperation operationForRequestType:customRequestType];
    expect(customOperationClass == [AFHTTPRequestOperation class]).to.equal(YES);
    
    [RKRequestTypeOperation unregisterClass:[AFHTTPRequestOperation class]];
    customOperationClass = [RKRequestTypeOperation operationForRequestType:customRequestType];
    // After unregister latest operation class, old registered class is still available.
    expect(customOperationClass == [RKConcreteHTTPRequestOperation class]).to.equal(YES);

    [RKRequestTypeOperation unregisterClass:[RKConcreteHTTPRequestOperation class]];
    customOperationClass = [RKRequestTypeOperation operationForRequestType:customRequestType];
    Class<RKHTTPRequestOperationProtocol> httpOperationClass = [RKRequestTypeOperation operationForRequestType:RKRequestTypeHTTP];
    expect(customOperationClass).to.equal(nil);
    expect(httpOperationClass).to.equal(nil);
}

@end
