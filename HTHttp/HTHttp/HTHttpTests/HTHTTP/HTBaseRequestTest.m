//
//  HTSendRequestTest.m
//  HTHttp
//
//  Created by Wangliping on 16/1/4.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "HTHttpTest.h"
#import "HTUserInfo.h"
#import "HTGetUserInfoRequest.h"
#import "HTHTTPRequestOperation.h"
#import "HTNetworkingHelper.h"
#import "HTGetPhotoListRequest.h"
#import "HTPhotoInfo.h"
#import "NSURLResponse+HTCache.h"
#import "HTGetUserInfoWithHeaderRequest.h"
#import "HTGetUserInfoWithConfig.h"
#import "NSURLRequest+HTCache.h"
#import "NSURLRequest+HTFreeze.h"
#import "NSURLRequest+RKRequest.h"
#import "HTTestPostRequest.h"

/**
 *  使用HTBaseRequest来发送请求.
 */
@interface HTBaseRequestTest : XCTestCase <HTRequestDelegate>

@end

@implementation HTBaseRequestTest

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

- (void)testFullRequestUrl {
    NSString *baseURL = @"http://localhost:3000";
    NSString *relativeAbsolutUrl = [[NSURL URLWithString:@"user" relativeToURL:[NSURL URLWithString:baseURL]] absoluteString];
    NSString *absolutUrl = [[NSURL URLWithString:@"http://localhost:3000/user" relativeToURL:[NSURL URLWithString:baseURL]] absoluteString];
    
    expect([relativeAbsolutUrl isEqualToString:absolutUrl]).to.equal(YES);
    
    // Note: 证明了baseUrl不同也不要紧. 因为relativeToURL方法会处理的.
    NSString *absoluteRequestUrl = @"http://www.baidu.com:3000/user";
    NSString *anotherBaseUrl = [[NSURL URLWithString:absoluteRequestUrl relativeToURL:[NSURL URLWithString:baseURL]] absoluteString];
    expect([anotherBaseUrl isEqualToString:absoluteRequestUrl]).to.equal(YES);
}

- (void)testNormalGetRequest {
    HTGetUserInfoRequest *request = [[HTGetUserInfoRequest alloc] init];
    [request startWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        HTUserInfo *userInfo = [mappingResult.dictionary objectForKey:@"data"];
        expect([userInfo isKindOfClass:[HTUserInfo class]]).to.equal(YES);
        expect([userInfo.name length] > 0).to.equal(YES);
        expect(operation.HTTPRequestOperation).to.beKindOf([HTHTTPRequestOperation class]);
        
        CFRunLoopRef runLoopRef = CFRunLoopGetCurrent();
        CFRunLoopStop(runLoopRef);
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        expect(nil == error).to.equal(YES);
        
        CFRunLoopRef runLoopRef = CFRunLoopGetCurrent();
        CFRunLoopStop(runLoopRef);
    }];
    
    CFRunLoopRun();
}

- (void)testNormalRequestWithParams {
    HTGetPhotoListRequest *request = [[HTGetPhotoListRequest alloc] init];
    [request startWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        NSArray *photoList = [mappingResult.dictionary objectForKey:@"photolist"];
        HTPhotoInfo *photoInfo = [photoList firstObject];
        expect([photoInfo isKindOfClass:[HTPhotoInfo class]]).to.equal(YES);
        expect(operation.HTTPRequestOperation).to.beKindOf([HTHTTPRequestOperation class]);
        expect([photoInfo.name length] > 0).to.equal(YES);
        
        CFRunLoopRef runLoopRef = CFRunLoopGetCurrent();
        CFRunLoopStop(runLoopRef);
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        expect(nil == error).to.equal(YES);
        
        CFRunLoopRef runLoopRef = CFRunLoopGetCurrent();
        CFRunLoopStop(runLoopRef);
    }];
    
    CFRunLoopRun();
}

- (void)testNormalPostRequest {
    HTTestPostRequest *postRequest = [[HTTestPostRequest alloc] init];
    [postRequest startWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        NSArray *photoList = [mappingResult.dictionary objectForKey:@"photolist"];
        HTPhotoInfo *photoInfo = [photoList firstObject];
        expect([photoInfo isKindOfClass:[HTPhotoInfo class]]).to.equal(YES);
        expect(operation.HTTPRequestOperation).to.beKindOf([HTHTTPRequestOperation class]);
        expect([photoInfo.name length] > 0).to.equal(YES);
        
        CFRunLoopRef runLoopRef = CFRunLoopGetCurrent();
        CFRunLoopStop(runLoopRef);
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        expect(nil == error).to.equal(YES);
        
        CFRunLoopRef runLoopRef = CFRunLoopGetCurrent();
        CFRunLoopStop(runLoopRef);
    }];
    
    CFRunLoopRun();
}

- (void)testRequestWithCache {
    HTGetUserInfoRequest *request = [[HTGetUserInfoRequest alloc] init];
    request.cacheId = HTCachePolicyCacheFirst;
    [request startWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        HTUserInfo *userInfo = [mappingResult.dictionary objectForKey:@"data"];
        expect([userInfo isKindOfClass:[HTUserInfo class]]).to.equal(YES);
        expect([userInfo.name length] > 0).to.equal(YES);
        expect(operation.HTTPRequestOperation).to.beKindOf([HTHTTPRequestOperation class]);
        
        [request startWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            HTUserInfo *userInfo = [mappingResult.dictionary objectForKey:@"data"];
            expect([userInfo isKindOfClass:[HTUserInfo class]]).to.equal(YES);
            expect([userInfo.name length] > 0).to.equal(YES);
            expect(operation.HTTPRequestOperation).to.beKindOf([HTHTTPRequestOperation class]);
            expect(operation.HTTPRequestOperation.response.ht_isFromCache).to.equal(YES);
            expect(request.isDataFromCache).to.equal(YES);
            
            CFRunLoopRef runLoopRef = CFRunLoopGetCurrent();
            CFRunLoopStop(runLoopRef);
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            expect(nil == error).to.equal(YES);
            
            CFRunLoopRef runLoopRef = CFRunLoopGetCurrent();
            CFRunLoopStop(runLoopRef);
        }];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        expect(nil == error).to.equal(YES);
        
        CFRunLoopRef runLoopRef = CFRunLoopGetCurrent();
        CFRunLoopStop(runLoopRef);
    }];
    
    CFRunLoopRun();
}

- (void)testRequestConfig {
    HTGetUserInfoWithConfig *request = [[HTGetUserInfoWithConfig alloc] init];
    request.customTimeInterval = 55;
    request.customCacheExpireInteval = 115;
    request.customFreezeInteval = 150;
    [request startWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        HTUserInfo *userInfo = [mappingResult.dictionary objectForKey:@"data"];
        expect([userInfo isKindOfClass:[HTUserInfo class]]).to.equal(YES);
        expect([userInfo.name length] > 0).to.equal(YES);
        expect(operation.HTTPRequestOperation).to.beKindOf([HTHTTPRequestOperation class]);
        
        NSURLRequest *urlRequest = operation.HTTPRequestOperation.request;
        expect(urlRequest.timeoutInterval).to.equal(request.customTimeInterval);
        expect(urlRequest.ht_cacheExpireTimeInterval).to.equal(request.customCacheExpireInteval);
        expect(urlRequest.ht_freezeExpireTimeInterval).to.equal(request.customFreezeInteval);
        
        CFRunLoopRef runLoopRef = CFRunLoopGetCurrent();
        CFRunLoopStop(runLoopRef);
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        expect(nil == error).to.equal(YES);
        
        CFRunLoopRef runLoopRef = CFRunLoopGetCurrent();
        CFRunLoopStop(runLoopRef);
    }];
    
    CFRunLoopRun();
}

- (void)testRequestWithCustomHeaders {
    HTGetUserInfoWithHeaderRequest *request = [[HTGetUserInfoWithHeaderRequest alloc] init];
    [request startWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        HTUserInfo *userInfo = [mappingResult.dictionary objectForKey:@"data"];
        expect([userInfo isKindOfClass:[HTUserInfo class]]).to.equal(YES);
        expect([userInfo.name length] > 0).to.equal(YES);
        expect(operation.HTTPRequestOperation).to.beKindOf([HTHTTPRequestOperation class]);
        
        NSString *customHeader = [operation.HTTPRequestOperation.request.allHTTPHeaderFields objectForKey:@"UnitTestHeader"];
        expect([customHeader isEqualToString:@"HTGetUserInfoWithHeaderRequest"]).to.equal(YES);
        
        CFRunLoopRef runLoopRef = CFRunLoopGetCurrent();
        CFRunLoopStop(runLoopRef);
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        expect(nil == error).to.equal(YES);
        
        CFRunLoopRef runLoopRef = CFRunLoopGetCurrent();
        CFRunLoopStop(runLoopRef);
    }];
    
    CFRunLoopRun();
}

- (void)testRequestStatus {
    HTGetUserInfoRequest *request = [[HTGetUserInfoRequest alloc] init];
    [request startWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        // 到达回调结果时已经结束.
        expect(request.isExecuting).to.equal(NO);
        expect(operation.HTTPRequestOperation.isFinished).to.equal(YES);
        
        HTUserInfo *userInfo = [mappingResult.dictionary objectForKey:@"data"];
        expect([userInfo isKindOfClass:[HTUserInfo class]]).to.equal(YES);
        expect([userInfo.name length] > 0).to.equal(YES);
        expect(operation.HTTPRequestOperation).to.beKindOf([HTHTTPRequestOperation class]);
        
        CFRunLoopRef runLoopRef = CFRunLoopGetCurrent();
        CFRunLoopStop(runLoopRef);
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        expect(error).notTo.equal(nil);
        
        CFRunLoopRef runLoopRef = CFRunLoopGetCurrent();
        CFRunLoopStop(runLoopRef);
    }];
    
    CFRunLoopRun();
}

- (void)testCancelRequest {
    HTGetUserInfoRequest *request = [[HTGetUserInfoRequest alloc] init];
    [request startWithSuccess:nil failure:nil];
    
    [request cancel];
    expect(request.requestOperation.isCancelled).to.beTruthy();
}

- (void)testRequestWithDelegate {
    HTGetUserInfoRequest *request = [[HTGetUserInfoRequest alloc] init];
    request.requestDelegate = self;
    [request start];
    
    CFRunLoopRun();
}

- (void)testSendRequestWithDefaultManager {
    HTGetUserInfoRequest *request = [[HTGetUserInfoRequest alloc] init];
    [request startWithManager:[RKObjectManager sharedManager] success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        HTUserInfo *userInfo = [mappingResult.dictionary objectForKey:@"data"];
        expect([userInfo isKindOfClass:[HTUserInfo class]]).to.equal(YES);
        expect([userInfo.name length] > 0).to.equal(YES);
        expect(operation.HTTPRequestOperation).to.beKindOf([HTHTTPRequestOperation class]);
        
        CFRunLoopRef runLoopRef = CFRunLoopGetCurrent();
        CFRunLoopStop(runLoopRef);
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        expect(error).notTo.equal(nil);
        
        CFRunLoopRef runLoopRef = CFRunLoopGetCurrent();
        CFRunLoopStop(runLoopRef);
    }];
    
    CFRunLoopRun();
}

- (void)testSendRequestWithCustomManager {
    RKObjectManager *manager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:@"http://localhost:3000"]];
    [manager registerRequestOperationClass:[HTHTTPRequestOperation class]];
    [HTGetUserInfoRequest registerInMananger:manager];
    
    HTGetUserInfoRequest *request = [[HTGetUserInfoRequest alloc] init];
    [request startWithManager:manager success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        HTUserInfo *userInfo = [mappingResult.dictionary objectForKey:@"data"];
        expect([userInfo isKindOfClass:[HTUserInfo class]]).to.equal(YES);
        expect([userInfo.name length] > 0).to.equal(YES);
        expect(operation.HTTPRequestOperation).to.beKindOf([HTHTTPRequestOperation class]);
        
        CFRunLoopRef runLoopRef = CFRunLoopGetCurrent();
        CFRunLoopStop(runLoopRef);
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        expect(error).notTo.equal(nil);
        
        CFRunLoopRef runLoopRef = CFRunLoopGetCurrent();
        CFRunLoopStop(runLoopRef);
    }];
    
    CFRunLoopRun();
}

- (void)testDefaultErrorMapping {
    NSURL *baseURL = [NSURL URLWithString:@"http://localhost:3000"];
    RKObjectManager *manager = [RKObjectManager managerWithBaseURL:baseURL];
    expect([manager.responseDescriptors count] == 1);
    RKResponseDescriptor *descriptor = [manager.responseDescriptors firstObject];
    expect(descriptor.method).to.equal(RKRequestMethodAny);
    expect(descriptor.keyPath).to.equal(@"errorCode");
    expect(descriptor.pathPattern).to.equal(nil);
    expect([descriptor.statusCodes isEqualToIndexSet:RKStatusCodeIndexSetForClass(RKStatusCodeClassClientError)]).to.equal(YES);
    expect([descriptor.baseURL isEqual:baseURL]).to.equal(YES);
}

#pragma mark - HTRequestDelegate

- (void)htRequestFinished:(HTBaseRequest *)request {
    expect([request isKindOfClass:[HTBaseRequest class]]);
    
    if ([request isKindOfClass:[HTGetUserInfoRequest class]]) {
        HTUserInfo *userInfo = [request.requestResult.dictionary objectForKey:@"data"];
        expect([userInfo isKindOfClass:[HTUserInfo class]]).to.equal(YES);
        expect([userInfo.name length] > 0).to.equal(YES);
    }
    
    CFRunLoopRef runLoopRef = CFRunLoopGetCurrent();
    CFRunLoopStop(runLoopRef);
}

- (void)htRequestFailed:(HTBaseRequest *)request {
    expect(nil == request.requestOperation.error).to.equal(YES);
    
    CFRunLoopRef runLoopRef = CFRunLoopGetCurrent();
    CFRunLoopStop(runLoopRef);
}

@end
