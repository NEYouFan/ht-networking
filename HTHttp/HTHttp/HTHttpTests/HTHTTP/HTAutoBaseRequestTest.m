//
//  HTAutoBaseRequestTest.m
//  HTHttp
//
//  Created by Wangliping on 16/1/11.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "HTHttpTest.h"
#import "HTAutoBaseRequest.h"
#import "HTAutoGetUserInfoRequest.h"
#import "HTDefaultCachePolicy.h"
#import "HTFreezePolicy.h"
#import "RKObjectManager.h"
#import "RKObjectRequestOperation.h"

@interface HTAutoBaseRequestTest : XCTestCase

@end

@implementation HTAutoBaseRequestTest

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

- (void)testAutoBaseRequest {
    // Check default property of HTAutoBaseRequest.
    HTAutoBaseRequest *autoBaseRequest = [[HTAutoBaseRequest alloc] init];
    expect([autoBaseRequest requestTimeoutInterval]).to.equal(60);
    expect([autoBaseRequest needCustomRequest]).to.equal(NO);
    expect([autoBaseRequest cachePolicyClass]).to.equal(nil);
    expect([autoBaseRequest cacheVersion]).to.equal(0);
    expect([autoBaseRequest cacheExpireTimeInterval]).to.equal(0);
    expect([autoBaseRequest cacheSensitiveData]).to.equal(nil);
    expect([autoBaseRequest freezeExpireTimeInterval]).to.equal(0);
    expect([autoBaseRequest frozenPolicyClass]).to.equal(nil);
    expect([autoBaseRequest requestType]).to.equal(nil);
    
    
    // Check set properties of HTAutoBaseRequest.
    autoBaseRequest.customRequestTimeoutInterval = 30;
    expect([autoBaseRequest requestTimeoutInterval]).to.equal(30);
    
    autoBaseRequest.configNeedCustomRequest = YES;
    expect([autoBaseRequest needCustomRequest]).to.equal(YES);
    
    autoBaseRequest.cachePolicyClass = [HTDefaultCachePolicy class];
    expect([autoBaseRequest cachePolicyClass]).notTo.equal(nil);
    
    NSString *customCacheKey = @"It is a cache Key";
    autoBaseRequest.customCacheKey = customCacheKey;
    expect([[autoBaseRequest cacheKey] isEqualToString:customCacheKey]).to.equal(YES);

    NSString *customCacheKeyInBlock = @"It is a cache key in block";
    autoBaseRequest.cacheKeyBlock = ^(HTAutoBaseRequest *request, RKObjectManager *mananger) {
        return customCacheKeyInBlock;
    };
    expect([[autoBaseRequest cacheKeyWithManager:nil] isEqualToString:customCacheKeyInBlock]).to.equal(YES);
    
    autoBaseRequest.customCacheKey = nil;
    expect([[autoBaseRequest cacheKey] isEqualToString:customCacheKeyInBlock]).to.equal(YES);
    
    
    autoBaseRequest.cacheParamsFilterBlock = ^(HTAutoBaseRequest *request, NSDictionary *params) {
        return @{@"testParamKey":@"testParamValue"};
    };
    expect([[autoBaseRequest cacheKeyFilteredRequestParams:[autoBaseRequest requestParams]] isEqualToDictionary:@{@"testParamKey":@"testParamValue"}]).to.equal(YES);
    
    autoBaseRequest.cacheVersion = 10;
    expect([autoBaseRequest cacheVersion]).to.equal(10);
    
    autoBaseRequest.cacheExpireTimeInterval = 120;
    expect([autoBaseRequest cacheExpireTimeInterval]).to.equal(120);

    autoBaseRequest.cacheSensitiveData = @(autoBaseRequest.htVersion);
    expect([autoBaseRequest cacheSensitiveData]).to.equal(@(autoBaseRequest.htVersion));

    autoBaseRequest.freezeExpireTimeInterval = 150;
    expect([autoBaseRequest freezeExpireTimeInterval]).to.equal(150);
    
    autoBaseRequest.frozenPolicyClass = [HTFreezePolicy class];
    expect([autoBaseRequest frozenPolicyClass]).notTo.equal(nil);
    
    
    autoBaseRequest.freezeSensitiveData = @"1";
    expect([autoBaseRequest freezeSensitiveData]).to.equal(@"1");

    
    NSString *customFreezeKey = @"It is a freeze Key";
    autoBaseRequest.customFreezeKey = customFreezeKey;
    expect([[autoBaseRequest freezeKey] isEqualToString:customFreezeKey]).to.equal(YES);
    
    NSString *customFreezeKeyInBlock = @"It is a cache key in block";
    autoBaseRequest.freezeKeyBlock = ^(HTAutoBaseRequest *request, RKObjectManager *mananger) {
        return customFreezeKeyInBlock;
    };
    expect([[autoBaseRequest freezeKeyWithManager:nil] isEqualToString:customFreezeKeyInBlock]).to.equal(YES);
    
    autoBaseRequest.customFreezeKey = nil;
    expect([[autoBaseRequest freezeKey] isEqualToString:customFreezeKeyInBlock]).to.equal(YES);

    autoBaseRequest.customRequestType = @"PrivateTCP";
    expect([[autoBaseRequest requestType] isEqualToString:@"PrivateTCP"]).to.equal(YES);
    
    expect([autoBaseRequest constructingBodyBlock]).to.equal(autoBaseRequest.customConstructingBlock);
    
    autoBaseRequest.customValidResultBlock = ^(RKObjectRequestOperation *operation) {
        return YES;
    };
    expect([autoBaseRequest validResultBlock](nil)).to.equal(YES);
    
    autoBaseRequest.customValidResultBlock = ^(RKObjectRequestOperation *operation) {
        return NO;
    };
    expect([autoBaseRequest validResultBlock](nil)).to.equal(NO);
    
    autoBaseRequest.customRequestBlock = ^(HTAutoBaseRequest *autoHTRequest, NSMutableURLRequest *request) {
        request.timeoutInterval = 1000;
    };
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://www.163.com"]];
    expect(request.timeoutInterval).to.equal(60);
    [autoBaseRequest customRequest:request];
    expect(request.timeoutInterval).to.equal(1000);
}

- (void)testCacheKeySensitiveData {
    HTAutoGetUserInfoRequest *autoRequest = [[HTAutoGetUserInfoRequest alloc] init];
    HTAutoGetUserInfoRequest *anotherAutoRequest = [[HTAutoGetUserInfoRequest alloc] init];
    expect([[autoRequest cacheKey] isEqualToString:[anotherAutoRequest cacheKey]]).to.equal(YES);
    
    autoRequest.cacheSensitiveData = @(1);
    expect([[autoRequest cacheKey] isEqualToString:[anotherAutoRequest cacheKey]]).to.equal(NO);
    
    anotherAutoRequest.cacheSensitiveData = @(1);
    expect([[autoRequest cacheKey] isEqualToString:[anotherAutoRequest cacheKey]]).to.equal(YES);
}

- (void)testFreezeKeySensitiveData {
    HTAutoGetUserInfoRequest *autoRequest = [[HTAutoGetUserInfoRequest alloc] init];
    HTAutoGetUserInfoRequest *anotherAutoRequest = [[HTAutoGetUserInfoRequest alloc] init];
    expect([[autoRequest freezeKey] isEqualToString:[anotherAutoRequest freezeKey]]).to.equal(YES);
    
    autoRequest.freezeSensitiveData = @"1";
    expect([[autoRequest freezeKey] isEqualToString:[anotherAutoRequest cacheKey]]).to.equal(NO);
    
    anotherAutoRequest.freezeSensitiveData = @"1";
    expect([[autoRequest freezeKey] isEqualToString:[anotherAutoRequest freezeKey]]).to.equal(YES);
}

@end
