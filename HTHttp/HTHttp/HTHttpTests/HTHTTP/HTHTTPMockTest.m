//
//  HTHTTPMockTest.m
//  HTHttp
//
//  Created by Wangliping on 16/1/25.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "HTHttpTest.h"
#import "NSObject+HTMapping.h"
#import "HTMockUserInfo.h"
#import "HTMockHTTPRequestOperation.h"
#import "NSURLRequest+HTMock.h"
#import "HTMockUserInfoRequest.h"
#import "HTSecurityUserInfoRequest.h"
#import "HTNetworkingHelper.h"
#import "HTNetworking.h"

@interface HTHTTPMockTest : XCTestCase

@end

@implementation HTHTTPMockTest

- (void)setUp {
    [super setUp];
    
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
    // Use recording to get started writing UI tests.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testMockWithObjectManager {
    // 添加ObjectMapping
    RKMapping *mapping = [HTMockUserInfo ht_modelMapping];
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping method:RKRequestMethodPOST pathPattern:@"/authorize" keyPath:@"data" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    // 添加ResponseDescriptor.
    RKObjectManager *manager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:@"http://localhost:3000"]];
    [manager addResponseDescriptor:responseDescriptor];
    [manager registerRequestOperationClass:[HTMockHTTPRequestOperation class]];
    
    NSURLRequest *request = [manager requestWithObject:nil method:RKRequestMethodPOST path:@"/authorize" parameters:nil];
    request.ht_mockBlock = ^(NSURLRequest *mockRequest) {
        mockRequest.ht_mockResponseObject =
            @{
                @"data": @{
                    @"accessToken": @"1111111-d595-4623-bc23-90f7123bc551",
                    @"admin": @(YES),
                    @"expireIn": @(604800),
                    @"refreshToken": @"1111111-ac5a-4fda-8c45-4af6341aeb5a",
                    @"refreshTokenExpireIn": @(2592000),
                    @"userName": @"测试",
                    @"yunxinToken":@"1111111-acda-4gda-8cd5-4afd341ded5d"
                },
                @"code": @(200)
            };
    };
    
    RKObjectRequestOperation *operation = [manager objectRequestOperationWithRequest:request success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        NSObject *dataObject = [mappingResult.dictionary objectForKey:@"data"];
        expect([dataObject isKindOfClass:[HTMockUserInfo class]]).to.equal(YES);
        
        HTMockUserInfo *mockUserInfo = (HTMockUserInfo *)dataObject;
        expect([mockUserInfo.userName  isEqualToString:@"测试"]).to.equal(YES);
        
        CFRunLoopRef runLoopRef = CFRunLoopGetCurrent();
        CFRunLoopStop(runLoopRef);
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        // If failure, then the test failed.
        expect(NO).to.equal(YES);
        
        CFRunLoopRef runLoopRef = CFRunLoopGetCurrent();
        CFRunLoopStop(runLoopRef);
    }];
    
    [operation start];
    [operation waitUntilFinished];
    
    CFRunLoopRun();
}

- (void)testMockWithRequest {
    [HTBaseRequest enableMockTest];
    HTMockUserInfoRequest *request = [[HTMockUserInfoRequest alloc] init];
    request.enableMock = YES;
    request.mockBlock = ^(NSURLRequest *mockRequest) {
        mockRequest.ht_mockResponseObject =
        @{
          @"data": @{
                  @"accessToken": @"1111111-d595-4623-bc23-90f7123bc551",
                  @"admin": @(YES),
                  @"expireIn": @(604800),
                  @"refreshToken": @"1111111-ac5a-4fda-8c45-4af6341aeb5a",
                  @"refreshTokenExpireIn": @(2592000),
                  @"userName": @"测试",
                  @"yunxinToken":@"1111111-acda-4gda-8cd5-4afd341ded5d"
                  },
          @"code": @(200)
          };
    };
    //        mockRequest.ht_mockJsonFilePath = [[NSBundle mainBundle] pathForResource:@"HTMockAuthorize" ofType:@"json"];
    [request startWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        NSObject *dataObject = [mappingResult.dictionary objectForKey:@"data"];
        expect([dataObject isKindOfClass:[HTMockUserInfo class]]).to.equal(YES);
        
        HTMockUserInfo *mockUserInfo = (HTMockUserInfo *)dataObject;
        expect([mockUserInfo.userName  isEqualToString:@"测试"]).to.equal(YES);
        
        CFRunLoopRef runLoopRef = CFRunLoopGetCurrent();
        CFRunLoopStop(runLoopRef);
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        // If failure, then the test failed.
        expect(NO).to.equal(YES);
        
        CFRunLoopRef runLoopRef = CFRunLoopGetCurrent();
        CFRunLoopStop(runLoopRef);
    }];
    
    CFRunLoopRun();
}

#pragma mark - Test Different Mock Data

- (void)testMockResponseObject {
    RKMapping *mapping = [HTMockUserInfo ht_modelMapping];
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping method:RKRequestMethodPOST pathPattern:@"/authorize" keyPath:@"data" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    RKObjectManager *manager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:@"http://localhost:3000"]];
    [manager addResponseDescriptor:responseDescriptor];
    [manager registerRequestOperationClass:[HTMockHTTPRequestOperation class]];
    
    NSURLRequest *request = [manager requestWithObject:nil method:RKRequestMethodPOST path:@"/authorize" parameters:nil];
    request.ht_mockResponseObject = @{
          @"data": @{
                  @"accessToken": @"1111111-d595-4623-bc23-90f7123bc551",
                  @"admin": @(YES),
                  @"expireIn": @(604800),
                  @"refreshToken": @"1111111-ac5a-4fda-8c45-4af6341aeb5a",
                  @"refreshTokenExpireIn": @(2592000),
                  @"userName": @"测试",
                  @"yunxinToken":@"1111111-acda-4gda-8cd5-4afd341ded5d"
                  },
          @"code": @(200)};
    RKObjectRequestOperation *operation = [manager objectRequestOperationWithRequest:request success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        NSObject *dataObject = [mappingResult.dictionary objectForKey:@"data"];
        expect([dataObject isKindOfClass:[HTMockUserInfo class]]).to.equal(YES);
        
        HTMockUserInfo *mockUserInfo = (HTMockUserInfo *)dataObject;
        expect([mockUserInfo.userName  isEqualToString:@"测试"]).to.equal(YES);
        
        CFRunLoopRef runLoopRef = CFRunLoopGetCurrent();
        CFRunLoopStop(runLoopRef);
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        // If failure, then the test failed.
        expect(NO).to.equal(YES);
        
        CFRunLoopRef runLoopRef = CFRunLoopGetCurrent();
        CFRunLoopStop(runLoopRef);
    }];
    
    [operation start];
    [operation waitUntilFinished];
    
    CFRunLoopRun();
}

- (void)testMockResponseData {
    RKMapping *mapping = [HTMockUserInfo ht_modelMapping];
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping method:RKRequestMethodPOST pathPattern:@"/authorize" keyPath:@"data" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    RKObjectManager *manager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:@"http://localhost:3000"]];
    [manager addResponseDescriptor:responseDescriptor];
    [manager registerRequestOperationClass:[HTMockHTTPRequestOperation class]];
    
    NSURLRequest *request = [manager requestWithObject:nil method:RKRequestMethodPOST path:@"/authorize" parameters:nil];
    NSDictionary *responseObject = @{
                                      @"data": @{
                                              @"accessToken": @"1111111-d595-4623-bc23-90f7123bc551",
                                              @"admin": @(YES),
                                              @"expireIn": @(604800),
                                              @"refreshToken": @"1111111-ac5a-4fda-8c45-4af6341aeb5a",
                                              @"refreshTokenExpireIn": @(2592000),
                                              @"userName": @"测试",
                                              @"yunxinToken":@"1111111-acda-4gda-8cd5-4afd341ded5d"
                                              },
                                      @"code": @(200)};
    request.ht_mockResponseData = [NSJSONSerialization dataWithJSONObject:responseObject options:NSJSONWritingPrettyPrinted error:nil];
    RKObjectRequestOperation *operation = [manager objectRequestOperationWithRequest:request success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        NSObject *dataObject = [mappingResult.dictionary objectForKey:@"data"];
        expect([dataObject isKindOfClass:[HTMockUserInfo class]]).to.equal(YES);
        
        HTMockUserInfo *mockUserInfo = (HTMockUserInfo *)dataObject;
        expect([mockUserInfo.userName  isEqualToString:@"测试"]).to.equal(YES);
        
        CFRunLoopRef runLoopRef = CFRunLoopGetCurrent();
        CFRunLoopStop(runLoopRef);
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        // If failure, then the test failed.
        expect(NO).to.equal(YES);
        
        CFRunLoopRef runLoopRef = CFRunLoopGetCurrent();
        CFRunLoopStop(runLoopRef);
    }];
    
    [operation start];
    [operation waitUntilFinished];
    
    CFRunLoopRun();
}

- (void)testMockResponseString {
    RKMapping *mapping = [HTMockUserInfo ht_modelMapping];
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping method:RKRequestMethodPOST pathPattern:@"/authorize" keyPath:@"data" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    RKObjectManager *manager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:@"http://localhost:3000"]];
    [manager addResponseDescriptor:responseDescriptor];
    [manager registerRequestOperationClass:[HTMockHTTPRequestOperation class]];
    
    NSURLRequest *request = [manager requestWithObject:nil method:RKRequestMethodPOST path:@"/authorize" parameters:nil];
    NSDictionary *responseObject = @{
                                     @"data": @{
                                             @"accessToken": @"1111111-d595-4623-bc23-90f7123bc551",
                                             @"admin": @(YES),
                                             @"expireIn": @(604800),
                                             @"refreshToken": @"1111111-ac5a-4fda-8c45-4af6341aeb5a",
                                             @"refreshTokenExpireIn": @(2592000),
                                             @"userName": @"测试",
                                             @"yunxinToken":@"1111111-acda-4gda-8cd5-4afd341ded5d"
                                             },
                                     @"code": @(200)};
    NSData *data = [NSJSONSerialization dataWithJSONObject:responseObject options:NSJSONWritingPrettyPrinted error:nil];
    NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    request.ht_mockResponseString = responseString;
    RKObjectRequestOperation *operation = [manager objectRequestOperationWithRequest:request success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        NSObject *dataObject = [mappingResult.dictionary objectForKey:@"data"];
        expect([dataObject isKindOfClass:[HTMockUserInfo class]]).to.equal(YES);
        
        HTMockUserInfo *mockUserInfo = (HTMockUserInfo *)dataObject;
        expect([mockUserInfo.userName  isEqualToString:@"测试"]).to.equal(YES);
        
        CFRunLoopRef runLoopRef = CFRunLoopGetCurrent();
        CFRunLoopStop(runLoopRef);
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        // If failure, then the test failed.
        expect(NO).to.equal(YES);
        
        CFRunLoopRef runLoopRef = CFRunLoopGetCurrent();
        CFRunLoopStop(runLoopRef);
    }];
    
    [operation start];
    [operation waitUntilFinished];
    
    CFRunLoopRun();
}

- (void)testMockResponseJsonFilePath {
    RKMapping *mapping = [HTMockUserInfo ht_modelMapping];
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping method:RKRequestMethodPOST pathPattern:@"/authorize" keyPath:@"data" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    RKObjectManager *manager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:@"http://localhost:3000"]];
    [manager addResponseDescriptor:responseDescriptor];
    [manager registerRequestOperationClass:[HTMockHTTPRequestOperation class]];
    
    NSURLRequest *request = [manager requestWithObject:nil method:RKRequestMethodPOST path:@"/authorize" parameters:nil];
    NSBundle *curBundle = [NSBundle bundleForClass:[self class]];
    request.ht_mockJsonFilePath = [curBundle pathForResource:@"HTMockAuthorize" ofType:@"json"];
    RKObjectRequestOperation *operation = [manager objectRequestOperationWithRequest:request success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        NSObject *dataObject = [mappingResult.dictionary objectForKey:@"data"];
        expect([dataObject isKindOfClass:[HTMockUserInfo class]]).to.equal(YES);
        
        HTMockUserInfo *mockUserInfo = (HTMockUserInfo *)dataObject;
        expect([mockUserInfo.userName  isEqualToString:@"测试"]).to.equal(YES);
        
        CFRunLoopRef runLoopRef = CFRunLoopGetCurrent();
        CFRunLoopStop(runLoopRef);
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        // If failure, then the test failed.
        expect(NO).to.equal(YES);
        
        CFRunLoopRef runLoopRef = CFRunLoopGetCurrent();
        CFRunLoopStop(runLoopRef);
    }];
    
    [operation start];
    [operation waitUntilFinished];
    
    CFRunLoopRun();
}

- (void)testMockResponseError {
    RKMapping *mapping = [HTMockUserInfo ht_modelMapping];
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping method:RKRequestMethodPOST pathPattern:@"/authorize" keyPath:@"data" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    RKObjectManager *manager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:@"http://localhost:3000"]];
    [manager addResponseDescriptor:responseDescriptor];
    [manager registerRequestOperationClass:[HTMockHTTPRequestOperation class]];
    
    NSURLRequest *request = [manager requestWithObject:nil method:RKRequestMethodPOST path:@"/authorize" parameters:nil];
    request.ht_mockError = [NSError errorWithDomain:@"testMockResponseError" code:555 userInfo:nil];
    RKObjectRequestOperation *operation = [manager objectRequestOperationWithRequest:request success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        // If success, then the test failes.
        expect(NO).to.equal(YES);
        
        CFRunLoopRef runLoopRef = CFRunLoopGetCurrent();
        CFRunLoopStop(runLoopRef);
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
//        expect([error.domain isEqualToString:@"testMockResponseError"]).to.equal(YES);
//        expect(error.code).to.equal(555);
        
        CFRunLoopRef runLoopRef = CFRunLoopGetCurrent();
        CFRunLoopStop(runLoopRef);
    }];
    
    [operation start];
    [operation waitUntilFinished];
    
    CFRunLoopRun();
}

@end
