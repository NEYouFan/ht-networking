//
//  RKRequestProviderTest.m
//  HTHttp
//
//  Created by NetEase on 15/7/28.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "HTHttpTest.h"

// Check whether RKRequestProvider creates correct requests.

@interface RKRequestProviderTest : XCTestCase

@end

@implementation RKRequestProviderTest

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

- (void)testRequestProvider {
    NSString *url = @"http://localhost:4567";
    NSURL *baseUrl = [[NSURL alloc] initWithString:url];
    NSDictionary *parameters = @{@"key":@"value"};
    
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:baseUrl];
    AFHTTPRequestOperation *operation = [manager GET:@"photolist" parameters:parameters success:nil failure:nil];
    
    RKRequestProvider *requestProvider = [[RKRequestProvider alloc] initWithBaseURL:baseUrl];
    NSURLRequest *request = [requestProvider requestWithMethod:@"GET" path:@"photolist" parameters:parameters];
    
    expect([request isEqual:operation.request]).to.equal(YES);
    
    operation = [manager POST:@"upload" parameters:parameters success:nil failure:nil];
    request = [requestProvider requestWithMethod:@"POST" path:@"upload" parameters:parameters];
    expect([request isEqual:operation.request]).to.equal(YES);
}

- (void)testRequestProviderWithCustomHeader {
    NSString *url = @"http://localhost:4567";
    NSURL *baseUrl = [[NSURL alloc] initWithString:url];
    NSDictionary *parameters = @{@"key":@"value"};
    
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:baseUrl];
    [manager.requestSerializer setValue:@"TestAgent" forHTTPHeaderField:@"User-Agent"];
    AFHTTPRequestOperation *operation = [manager GET:@"photolist" parameters:parameters success:nil failure:nil];
    
    RKRequestProvider *requestProvider = [[RKRequestProvider alloc] initWithBaseURL:baseUrl];
    [requestProvider setDefaultHeader:@"User-Agent" value:@"TestAgent"];
    NSURLRequest *request = [requestProvider requestWithMethod:@"GET" path:@"photolist" parameters:parameters];
    expect([request isEqual:operation.request]).to.equal(YES);
    expect([request.allHTTPHeaderFields isEqual:operation.request.allHTTPHeaderFields]).to.equal(YES);
    
    operation = [manager POST:@"upload" parameters:parameters success:nil failure:nil];
    request = [requestProvider requestWithMethod:@"POST" path:@"upload" parameters:parameters];
    expect([request isEqual:operation.request]).to.equal(YES);
    expect([request.allHTTPHeaderFields isEqual:operation.request.allHTTPHeaderFields]).to.equal(YES);
}

- (void)testJsonParametersForGetRequest {
    NSString *url = @"http://localhost:4567";
    NSURL *baseUrl = [[NSURL alloc] initWithString:url];
    NSDictionary *parameters = @{@"key":@"value"};
    
    // 对于GET请求, requestSerializer的设定不影响request的内容.
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:baseUrl];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    AFHTTPRequestOperation *operation = [manager GET:@"photolist" parameters:parameters success:nil failure:nil];
    
    RKRequestProvider *requestProvider = [[RKRequestProvider alloc] initWithBaseURL:baseUrl];
    requestProvider.parameterEncoding = RKJSONParameterEncoding;
    NSURLRequest *request = [requestProvider requestWithMethod:@"GET" path:@"photolist" parameters:parameters];
    expect([request isEqual:operation.request]).to.equal(YES);
}

- (void)testJsonParametersForPostRequest {
    #warning RKRequestProvider的requestSerializer没有开放设置. 而且不开放设置为AFJSONRequestSerializer对于RKObjectMananger并没有影响，因为RKObjectMananger的post request参数并没有使用RKRequestProvider的Serializer来处理参数.
    // TODO: 对于POST请求，RKRequestProvider和AFNetworking 2.0并不是完全等价. 不支持requestSerializer的设定.
//    NSString *url = @"http://localhost:4567";
//    NSURL *baseUrl = [[NSURL alloc] initWithString:url];
//    NSDictionary *parameters = @{@"key":@"value"};
//    
//    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:baseUrl];
//    manager.requestSerializer = [AFJSONRequestSerializer serializer];
//    AFHTTPRequestOperation *operation = [manager POST:@"upload" parameters:parameters success:nil failure:nil];
//    
//    RKRequestProvider *client = [[RKRequestProvider alloc] initWithBaseURL:baseUrl];
//    client.parameterEncoding = AFJSONParameterEncoding;
//    NSURLRequest *request = [client requestWithMethod:@"POST" path:@"upload" parameters:parameters];
}

- (void)testHttpDefaultHeaderAcceptCustomValue {
    // Check testInitializationWithRKRequestProviderSetsNilAcceptHeaderValue in RestKit.
    RKRequestProvider *requestProvider = [RKRequestProvider requestProviderWithBaseURL:[NSURL URLWithString:@"http://restkit.org"]];
    [requestProvider setDefaultHeader:@"Accept" value:@"this/that"];
    RKObjectManager *manager = [[RKObjectManager alloc] initWithRequestProvider:requestProvider];
    expect([manager defaultHeaders][@"Accept"]).to.equal(@"this/that");
}

- (void)testReqeustProviderPropertyStringEncoding {
    // 测试RKRequestProvider的属性stringEncoding的作用.
    NSString *url = @"http://localhost:4567";
    NSURL *baseUrl = [[NSURL alloc] initWithString:url];
    NSDictionary *parameters = @{@"key":@"中文字符串"};
    NSString* getPath = @"photolist";
    
    RKRequestProvider *requestProvider = [RKRequestProvider requestProviderWithBaseURL:[NSURL URLWithString:url]];
    NSURLRequest* request = [requestProvider requestWithMethod:@"GET" path:getPath parameters:parameters];
    
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:baseUrl];
    NSMutableURLRequest *afnRequest = [manager.requestSerializer requestWithMethod:@"GET" URLString:[[NSURL URLWithString:getPath relativeToURL:baseUrl] absoluteString] parameters:parameters error:nil];
    expect([request isEqual:afnRequest]).to.equal(YES);
    
    requestProvider.stringEncoding = NSASCIIStringEncoding;
    request = [requestProvider requestWithMethod:@"GET" path:getPath parameters:parameters];
    expect([request isEqual:afnRequest]).to.equal(NO);
}

- (void)testRKRequestProviderStringEncodingForGetRequest {
    // Test whether RKRequestProvider get correct request after setting string encoding.
    NSString *url = @"http://localhost:4567";
    NSURL *baseUrl = [[NSURL alloc] initWithString:url];
    NSDictionary *parameters = @{@"key":@"中文字符串"};
    NSString* getPath = @"photolist";
    
    RKRequestProvider *requestProvider = [RKRequestProvider requestProviderWithBaseURL:[NSURL URLWithString:url]];
    NSURLRequest* request = [requestProvider requestWithMethod:@"GET" path:getPath parameters:parameters];
    
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:baseUrl];
    NSMutableURLRequest *afnRequest = [manager.requestSerializer requestWithMethod:@"GET" URLString:[[NSURL URLWithString:getPath relativeToURL:baseUrl] absoluteString] parameters:parameters error:nil];
    
    // 默认情况下创建出来的request相同.
    expect([request isEqual:afnRequest]).to.equal(YES);
    
    // stringEncoding变化时, request的URL变化.
    requestProvider.stringEncoding = NSASCIIStringEncoding;
    request = [requestProvider requestWithMethod:@"GET" path:getPath parameters:parameters];
    expect([request isEqual:afnRequest]).to.equal(NO);
    expect([request.URL.absoluteString isEqualToString:afnRequest.URL.absoluteString]).to.equal(NO);
}

- (void)testRKRequestProviderStringEncodingForPostRequest {
    // Test whether RKRequestProvider get correct request after setting string encoding.
    NSString *url = @"http://localhost:4567";
    NSURL *baseUrl = [[NSURL alloc] initWithString:url];
    NSDictionary *parameters = @{@"key":@"中文字符串"};
    NSString* getPath = @"photolist";
    
    RKRequestProvider *requestProvider = [RKRequestProvider requestProviderWithBaseURL:baseUrl];
    NSURLRequest* request = [requestProvider requestWithMethod:@"POST" path:getPath parameters:parameters];
    
    requestProvider.stringEncoding = NSASCIIStringEncoding;
    NSURLRequest* ascRequest = [requestProvider requestWithMethod:@"POST" path:getPath parameters:parameters];
    expect([request.allHTTPHeaderFields isEqualToDictionary:ascRequest.allHTTPHeaderFields]);
    
    // 编码方式影响HTTP BODY.
    expect([request.HTTPBody isEqualToData:ascRequest.HTTPBody]).to.equal(NO);
}

- (void)testRequestProviderProperyParamEncoding {
    // TODO: 测试RKRequestProvider的属性paramEncoding的作用. 似乎已有相关测试并且在RKObjectManager上生效.
    // 主要的问题是RKRequestProvider的功能和AFN不等价了.
    // 如果允许RKRequestProvider与AFN等价，那么需要更改在设置paramEncoding时更改掉requestSerializer.
    NSString *url = @"http://localhost:4567";
    NSURL *baseUrl = [[NSURL alloc] initWithString:url];
    NSDictionary *parameters = @{@"key":@"value"};
    
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:baseUrl];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"TestAgent" forHTTPHeaderField:@"User-Agent"];
    AFHTTPRequestOperation *operation = [manager GET:@"photolist" parameters:parameters success:nil failure:nil];
    
    RKRequestProvider *requestProvider = [[RKRequestProvider alloc] initWithBaseURL:baseUrl];
    [requestProvider setDefaultHeader:@"User-Agent" value:@"TestAgent"];
    
    NSURLRequest *request = [requestProvider requestWithMethod:@"GET" path:@"photolist" parameters:parameters];
    
    expect([request.allHTTPHeaderFields isEqual:operation.request.allHTTPHeaderFields]).to.equal(YES);
    
#warning RKRequestProvider的requestSerializer没有开放设置. 而且不开放设置为AFJSONRequestSerializer对于RKObjectMananger并没有影响，因为RKObjectMananger的post request参数并没有使用RKRequestProvider的Serializer来处理参数.
//    operation = [manager POST:@"upload" parameters:parameters success:nil failure:nil];
//    request = [client requestWithMethod:@"POST" path:@"upload" parameters:parameters];
//    expect([request.allHTTPHeaderFields isEqual:operation.request.allHTTPHeaderFields]).to.equal(YES);
}

- (void)testRKRequestProviderHeader {
    NSString *url = @"http://localhost:4567";
    NSURL *baseUrl = [[NSURL alloc] initWithString:url];
    RKRequestProvider *requestProvider = [RKRequestProvider requestProviderWithBaseURL:baseUrl];
    [requestProvider setDefaultHeader:@"defaultTestHeader" value:@"测试Header"];
    NSString *testHeader = [requestProvider defaultValueForHeader:@"defaultTestHeader"];
    expect([testHeader isEqualToString:@"测试Header"]).to.equal(YES);
    
    NSString *testToken = @"TestToken";
    [requestProvider setAuthorizationHeaderWithToken:testToken];
    NSString *authorizenHeader = [requestProvider defaultValueForHeader:@"Authorization"];
    expect([authorizenHeader rangeOfString:testToken].length).to.equal([testToken length]);
    
    NSString *userName = @"lwang";
    NSString *password = @"Hubei";
    [requestProvider setAuthorizationHeaderWithUsername:userName password:password];
    NSString *userAuthorizenHeader = [requestProvider defaultValueForHeader:@"Authorization"];
    expect([userAuthorizenHeader isEqualToString:authorizenHeader]).to.equal(NO);
    
    [requestProvider clearAuthorizationHeader];
    NSString *clearedAuthorizationHeader = [requestProvider defaultValueForHeader:@"Authorization"];
    expect([clearedAuthorizationHeader length]).to.equal(0);
    
    requestProvider.stringEncoding = NSUTF8StringEncoding;
    requestProvider.parameterEncoding = NSUTF8StringEncoding;
    requestProvider.defaultTimeout = 300;
    requestProvider.securityPolicy = [AFSecurityPolicy defaultPolicy];
    requestProvider.defaultCredential = [[NSURLCredential alloc] initWithUser:@"user" password:@"password" persistence:NSURLCredentialPersistenceForSession];
    requestProvider.defaultHeaders = @{@"User-Agent" : @"MyClient"};
    requestProvider.defaultParams = @{@"name":@"lwang"};
    
    NSRange rang = [[requestProvider description] rangeOfString:url];
    expect(rang.length).to.equal([url length]);
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:requestProvider];
    expect(data).toNot.equal(Nil);
    
    RKRequestProvider *decodeRequestProvider = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    expect(decodeRequestProvider.stringEncoding == requestProvider.stringEncoding).to.equal(YES);
    expect(decodeRequestProvider.parameterEncoding == requestProvider.parameterEncoding).to.equal(YES);
    expect(decodeRequestProvider.securityPolicy != nil).to.equal(YES);
    expect([decodeRequestProvider.defaultCredential isEqual:requestProvider.defaultCredential]).to.equal(YES);
    expect([decodeRequestProvider.defaultHeaders isEqualToDictionary:requestProvider.defaultHeaders]).to.equal(YES);
    expect([decodeRequestProvider.defaultParams isEqualToDictionary:requestProvider.defaultParams]).to.equal(YES);
    
    RKRequestProvider *copiedRequestProvider = [requestProvider copy];
    expect(copiedRequestProvider.stringEncoding == requestProvider.stringEncoding).to.equal(YES);
    expect(copiedRequestProvider.parameterEncoding == requestProvider.parameterEncoding).to.equal(YES);
    expect(copiedRequestProvider.securityPolicy != nil).to.equal(YES);
    expect([copiedRequestProvider.defaultCredential isEqual:requestProvider.defaultCredential]).to.equal(YES);
    expect([copiedRequestProvider.defaultHeaders isEqualToDictionary:requestProvider.defaultHeaders]).to.equal(YES);
    expect([copiedRequestProvider.defaultParams isEqualToDictionary:requestProvider.defaultParams]).to.equal(YES);
}

@end
