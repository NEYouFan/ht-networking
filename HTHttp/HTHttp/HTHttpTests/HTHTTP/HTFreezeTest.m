//
//  HTFreezeTest.m
//  HTHttp
//
//  Created by Wangliping on 16/1/4.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "HTHttpTest.h"
#import "HTFreezeManager.h"
#import "HTUserInfo.h"
#import "NSURLRequest+HTFreeze.h"
#import "NSURLRequest+HTCache.h"
#import "NSURLRequest+RKRequest.h"
#import "HTFreezePolicyMananger.h"
#import "HTFrozenRequest.h"
#import "HTFreezePolicy.h"
#import "HTTestCustomFreezePolicy.h"
#import "HTHTTPDate.h"

@interface HTFreezeTest : XCTestCase <HTFreezeManagerProtocol>

@end

@implementation HTFreezeTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    // User of HTHTTP shall start monitoring by itself otherwise no requests would be frozen.
    // TODO: 添加到文档中，之前是通过RKObjectMananger的属性来开启监听的；现在需要手动开启.
    [HTFreezeManager setupWithDelegate:nil isStartMonitoring:YES];
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

- (void)testFreezeRequestWithMananger {
    RKMapping *mapping = [HTUserInfo manuallyMapping];
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping method:RKRequestMethodGET pathPattern:@"/user" keyPath:@"data" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    RKObjectManager *manager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:@"http://localhost:3000"]];
    [manager addResponseDescriptor:responseDescriptor];
    [RKMIMETypeSerialization registerClass:[RKNSJSONSerialization class] forMIMEType:@"text/plain"];
    [manager registerRequestOperationClass:[HTHTTPRequestOperation class]];
    [HTFreezeManager setupWithDelegate:self isStartMonitoring:YES];
    
    NSMutableURLRequest *request = [manager requestWithObject:nil method:RKRequestMethodGET path:@"/user" parameters:nil];
    // Note: 这里可以对Request进行配置.
    request.ht_freezeId = [request ht_defaultFreezeId];
    request.ht_canFreeze = YES;
    request.ht_freezePolicyId = HTFreezePolicySendFreezeAutomatically;
    
    RKObjectRequestOperation *operation = [manager objectRequestOperationWithRequest:request success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        expect([mappingResult count] > 0).to.equal(YES);
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        // If any error happens then this test case failed.
        expect(error).to.equal(nil);

    }];

    [operation start];
    [operation waitUntilFinished];
}

- (void)testHTFreezePolicyManager {
    HTFreezePolicyMananger *policyManager = [HTFreezePolicyMananger sharedInstance];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.163.com"]];
    request.ht_freezePolicyId = HTFreezePolicySendFreezeAutomatically;
    HTFrozenRequest *frozenRequest = [[HTFrozenRequest alloc] init];
    frozenRequest.request = request;
    Class<HTFreezePolicyProtocol> policyClass = [policyManager freezePolicyClassForRequest:frozenRequest];
    expect(policyClass).notTo.equal(nil);
    expect(policyClass).to.equal([HTFreezePolicy class]);
    
    [policyManager removeFreezePolicy:HTFreezePolicySendFreezeAutomatically];
    policyClass = [policyManager freezePolicyClassForRequest:frozenRequest];
    expect(policyClass).to.equal(nil);
    
    [policyManager registeFreezePolicyWithPolicyId:(HTFreezePolicySendFreezeAutomatically + 1) policy:[HTTestCustomFreezePolicy class]];
    request.ht_freezePolicyId = (HTFreezePolicySendFreezeAutomatically + 1);
    policyClass = [policyManager freezePolicyClassForRequest:frozenRequest];
    expect(policyClass).notTo.equal(nil);
    expect(policyClass).to.equal([HTTestCustomFreezePolicy class]);
    
    [policyManager removeFreezePolicyClass:[HTTestCustomFreezePolicy class]];
    policyClass = [policyManager freezePolicyClassForRequest:frozenRequest];
    expect(policyClass).to.equal(nil);
}

- (void)testHTFrozenRequest {
    HTFreezeManager *freezeManager = [HTFreezeManager sharedInstance];
    [freezeManager clearAllFreezedRequestsOnCompletion:^{
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.163.com"]];
        request.ht_freezePolicyId = HTFreezePolicySendFreezeAutomatically;
        request.ht_cacheKey = @"TestCacheKey";
        request.ht_responseVersion = 3;
        request.rk_requestTypeName = @"PrivateTCP";
        
        HTFrozenRequest *frozenRequest = [[HTFrozenRequest alloc] init];
        frozenRequest.request = request;
        frozenRequest.version = 1;
        frozenRequest.createDate = [HTHTTPDate sharedInstance].now;
        frozenRequest.expireDate = [NSDate dateWithTimeInterval:86400 sinceDate:frozenRequest.createDate];
        frozenRequest.requestKey = request.ht_freezeId;
        
        BOOL isExpired = [frozenRequest isExpired];
        expect(isExpired).to.equal(NO);
        
        BOOL isDateInvalid = [frozenRequest isDateInvalid];
        expect(isDateInvalid).to.equal(NO);

        BOOL hasRecordWithRequestKey = [HTFrozenRequest hasRecordWithRequestKey:frozenRequest.requestKey];
        expect(hasRecordWithRequestKey).to.equal(NO);
        [frozenRequest save];
        hasRecordWithRequestKey = [HTFrozenRequest hasRecordWithRequestKey:frozenRequest.requestKey];
        expect(hasRecordWithRequestKey).to.equal(YES);
        
        CFRunLoopRef runLoopRef = CFRunLoopGetCurrent();
        CFRunLoopStop(runLoopRef);
    }];
    
    CFRunLoopRun();
}

- (void)testSaveAndLoadFrozenRequest {
    HTFreezeManager *freezeManager = [HTFreezeManager sharedInstance];
    [freezeManager clearAllFreezedRequestsOnCompletion:^{
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://localhost:3000"]];
        request.ht_freezeId = @"It is a test freezeId";
        request.ht_canFreeze = YES;
        request.rk_requestTypeName = @"RequestOperationNotExist";
        request.ht_cacheKey = @"It is a test cache Key";
        
        HTFrozenRequest *htRequest = [[HTFrozenRequest alloc] init];
        htRequest.requestKey = request.ht_freezeId;
        htRequest.request = request;
        [htRequest save];
        
        HTFrozenRequest *queriedRequest = [[HTFreezeManager sharedInstance] queryByFreezeId:request.ht_freezeId];
        NSURLRequest *httpRequest = queriedRequest.request;
        expect([request.ht_freezeId isEqualToString:httpRequest.ht_freezeId]).to.equal(YES);
        expect(request.ht_canFreeze).to.equal(httpRequest.ht_canFreeze);
        expect([request.rk_requestTypeName isEqualToString:httpRequest.rk_requestTypeName]).to.equal(YES);
        expect([request.ht_cacheKey isEqualToString:httpRequest.ht_cacheKey]).to.equal(YES);
        
        CFRunLoopRef runLoopRef = CFRunLoopGetCurrent();
        CFRunLoopStop(runLoopRef);
    }];

    CFRunLoopRun();
}

#pragma mark - Test Freeze Mananger

- (void)testFreezeRequestWorkFlow {
    HTFreezeManager *freezeManager = [HTFreezeManager sharedInstance];
    [freezeManager clearAllFreezedRequestsOnCompletion:^{
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.163.com"]];
        request.ht_freezePolicyId = HTFreezePolicySendFreezeAutomatically;
        request.ht_canFreeze = YES;
        request.ht_cacheKey = @"TestCacheKey";
        request.ht_responseVersion = 3;
        request.rk_requestTypeName = @"PrivateTCP";
        
        [freezeManager freeze:request];
        expect([freezeManager queryByFreezeId:request.ht_freezeId] != nil).will.beTruthy;
        expect([[freezeManager queryByFreezeId:request.ht_freezeId] isEqual:request]).will.beTruthy;
    }];
}

#pragma mark - HTFreezeManagerProtocol

- (RKObjectManager *)objectManagerForRequest:(NSURLRequest *)request {
    return nil;
}

@end
