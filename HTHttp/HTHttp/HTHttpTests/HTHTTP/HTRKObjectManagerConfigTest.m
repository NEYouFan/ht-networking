//
//  HTRKObjectManagerConfig.m
//  HTHttp
//
//  Created by NetEase on 15/8/7.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "HTHttpTest.h"

@interface HTRKObjectManagerConfigTest : XCTestCase

@end

// Test cases for creating requests with RKObjectManager's own configuration.

@implementation HTRKObjectManagerConfigTest

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

- (void)testDefaultAcceptHeaderWithMIMEType {
    // This method is used to test whether the API '- (void)setAcceptHeaderWithMIMEType:(NSString *)MIMEType;' of RKObjectManager is called default.
    NSString *url = @"http://localhost:4567";
    NSURL *baseUrl = [[NSURL alloc] initWithString:url];
    RKObjectManager *manager = [RKObjectManager managerWithBaseURL:baseUrl];

    NSDictionary *parameters = @{@"key":@"value"};
    NSString *getPath = @"download";
    NSURLRequest *request = [manager requestWithObject:nil method:RKRequestMethodGET path:getPath parameters:parameters];
    expect([[[request allHTTPHeaderFields] objectForKey:@"Accept"] isEqualToString:RKMIMETypeJSON]).to.equal(YES);
    
    NSURLRequest *clientRequest = [manager.requestProvider requestWithMethod:@"GET" path:getPath parameters:parameters];
    expect([[[clientRequest allHTTPHeaderFields] objectForKey:@"Accept"] isEqualToString:RKMIMETypeJSON]).to.equal(YES);
}

- (void)testSetAcceptHeaderWithMIMEType {
    // This method is used to test the API '- (void)setAcceptHeaderWithMIMEType:(NSString *)MIMEType;' of RKObjectManager.
    NSString *url = @"http://localhost:4567";
    NSURL *baseUrl = [[NSURL alloc] initWithString:url];
    NSDictionary *parameters = @{@"key":@"value"};
    NSString *getPath = @"download";
    RKObjectManager *manager = [RKObjectManager managerWithBaseURL:baseUrl];
    
    // Test 1
    {
        // Set accept header to RKMIMETypeXML.
        [manager setAcceptHeaderWithMIMEType:RKMIMETypeXML];
        
        NSURLRequest *request = [manager requestWithObject:nil method:RKRequestMethodGET path:getPath parameters:parameters];
        expect([[[request allHTTPHeaderFields] objectForKey:@"Accept"] isEqualToString:RKMIMETypeXML]).to.equal(YES);
        
        NSURLRequest *clientRequest = [manager.requestProvider requestWithMethod:@"GET" path:getPath parameters:parameters];
        expect([[[clientRequest allHTTPHeaderFields] objectForKey:@"Accept"] isEqualToString:RKMIMETypeXML]).to.equal(YES);
    }

    // Test 2
    {
        // Clear "Accept Header"
        [manager setAcceptHeaderWithMIMEType:nil];
        
        NSURLRequest *request = [manager requestWithObject:nil method:RKRequestMethodGET path:getPath parameters:parameters];
        expect( 0 == [[[request allHTTPHeaderFields] objectForKey:@"Accept"] length]).to.equal(YES);
        
        NSURLRequest *clientRequest = [manager.requestProvider requestWithMethod:@"GET" path:getPath parameters:parameters];
        expect(0 == [[[clientRequest allHTTPHeaderFields] objectForKey:@"Accept"] length]).to.equal(YES);
    }
    
    // Test 3
    {
        // Custom MIME Type
        NSString *customMIMEType = @"*.*, test";
        [manager setAcceptHeaderWithMIMEType:customMIMEType];
        
        NSURLRequest *request = [manager requestWithObject:nil method:RKRequestMethodGET path:getPath parameters:parameters];
        expect([[[request allHTTPHeaderFields] objectForKey:@"Accept"] isEqualToString:customMIMEType]).to.equal(YES);
        
        NSURLRequest *clientRequest = [manager.requestProvider requestWithMethod:@"GET" path:getPath parameters:parameters];
        expect([[[clientRequest allHTTPHeaderFields] objectForKey:@"Accept"] isEqualToString:customMIMEType]).to.equal(YES);
    }
    
    // Test 4
    {
        // Check whether RKRequestProvider can set accept header.
        [manager.requestProvider setDefaultHeader:@"Accept" value:RKMIMETypeFormURLEncoded];
        
        NSURLRequest *request = [manager requestWithObject:nil method:RKRequestMethodGET path:getPath parameters:parameters];
        expect([[[request allHTTPHeaderFields] objectForKey:@"Accept"] isEqualToString:RKMIMETypeFormURLEncoded]).to.equal(YES);
        
        NSURLRequest *clientRequest = [manager.requestProvider requestWithMethod:@"GET" path:getPath parameters:parameters];
        expect([[[clientRequest allHTTPHeaderFields] objectForKey:@"Accept"] isEqualToString:RKMIMETypeFormURLEncoded]).to.equal(YES);
    }
    
    // Summary:
    // 1 setAcceptHeaderWithMIMEType add HTTP Header "Accept".
    // 2 Requests created with both Request Provider or Manager are taken effect on.
    // 3 There is no difference between GET and POST requests.
}

- (void)testObjectManagerRequestSerializationMIMETypeForGetRequest {
    // Test whether RKObjectManager get correct request after setting requestSerializationMIMEType.
    // requestSerializationMIMEType的设定不影响GET, HEAD, DELETE类型的request.
    NSString *url = @"http://localhost:4567";
    NSURL *baseUrl = [[NSURL alloc] initWithString:url];
    NSDictionary *parameters = @{@"key":@"value"};
    NSString *getPath = @"photolist";
    
    RKObjectManager *manager = [RKObjectManager managerWithBaseURL:baseUrl];
    // Default parameterEncoding is RKMIMETypeFormURLEncoded.
    expect(manager.requestSerializationMIMEType == RKMIMETypeFormURLEncoded).to.equal(YES);
    NSURLRequest *request = [manager requestWithObject:nil method:RKRequestMethodGET path:getPath parameters:parameters];
    
    manager.requestSerializationMIMEType = RKMIMETypeJSON;
    NSURLRequest *ascRequest = [manager requestWithObject:nil method:RKRequestMethodGET path:getPath parameters:parameters];
    
    expect([request isEqual:ascRequest]).to.equal(YES);
    expect([request.URL.absoluteString isEqualToString:ascRequest.URL.absoluteString]).to.equal(YES);
}

- (void)testObjectManagerRequestSerializationMIMETypeForPostRequest {
    // Test whether RKObjectManager get correct request after setting requestSerializationMIMEType.
    // requestSerializationMIMEType的设定会影响POST类型的request.
    // TODO: 影响一个是HTTPBODY, 一个是CONTENT_TYPE.
    NSString *url = @"http://localhost:4567";
    NSURL *baseUrl = [[NSURL alloc] initWithString:url];
    NSDictionary *parameters = @{@"key":@"value"};
    NSString *postPath = @"upload";
    
    RKObjectManager *manager = [RKObjectManager managerWithBaseURL:baseUrl];
    // Default parameterEncoding is RKMIMETypeFormURLEncoded.
    expect(manager.requestSerializationMIMEType == RKMIMETypeFormURLEncoded).to.equal(YES);
    NSMutableURLRequest *request = [manager requestWithObject:nil method:RKRequestMethodPOST path:postPath parameters:parameters];
    
    manager.requestSerializationMIMEType = RKMIMETypeJSON;
    NSMutableURLRequest *ascRequest = [manager requestWithObject:nil method:RKRequestMethodPOST path:postPath parameters:parameters];
    
    expect([request isEqual:ascRequest]).to.equal(NO);
    expect([request.URL.absoluteString isEqualToString:ascRequest.URL.absoluteString]).to.equal(YES);
    expect([request.allHTTPHeaderFields isEqual:ascRequest.allHTTPHeaderFields]).to.equal(NO);
    expect([request.HTTPBody isEqualToData:ascRequest.HTTPBody]).to.equal(NO);
}

- (void)testChangingRequestProvider
{
    RKObjectManager *manager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:@"http://restkit.org"]];
    manager.requestProvider = [RKRequestProvider requestProviderWithBaseURL:[NSURL URLWithString:@"http://google.com/"]];
    expect([manager.baseURL absoluteString]).to.equal(@"http://google.com/");
    // TODO: 待解决的问题. 更换RequestProvider后，所有的设置都失效了.
//    expect([manager.defaultHeaders valueForKey:@"Accept"]).to.equal(RKMIMETypeJSON);
}

- (void)testHttpDefaultHeaderValueToJSON {
    // Check testInitializationWithBaseURLSetsDefaultAcceptHeaderValueToJSON.
    RKObjectManager *manager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:@"http://restkit.org"]];
    expect([manager defaultHeaders][@"Accept"]).to.equal(RKMIMETypeJSON);
}

@end
