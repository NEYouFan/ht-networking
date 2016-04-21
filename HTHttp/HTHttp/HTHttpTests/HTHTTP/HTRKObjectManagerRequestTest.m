//
//  HTRKObjectManagerTest.m
//  HTHttp
//
//  Created by NetEase on 15/7/30.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "HTHttpTest.h"

// Check whether RKObjectManager creates correct request as we want by comparing with AFN 2.0.
@interface HTRKObjectManagerRequestTest : XCTestCase

@end

@implementation HTRKObjectManagerRequestTest

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

- (void)testHttpRequestSerializerHeader {
    NSString *url = @"http://localhost:4567";
    NSURL *baseUrl = [[NSURL alloc] initWithString:url];
    NSDictionary *parameters = @{@"key":@"value"};
    NSString *getPath = @"photolist";
    NSString *postPath = @"upload";
    
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:baseUrl];
//    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"TestAgent" forHTTPHeaderField:@"User-Agent"];
    AFHTTPRequestOperation *operation = [manager GET:getPath parameters:parameters success:nil failure:nil];
    
    RKObjectManager *objectManager = [RKObjectManager managerWithBaseURL:baseUrl];
    // Header只需要设置AcceptHeaderWithMIMEType即可.
    [objectManager setAcceptHeaderWithMIMEType:RKMIMETypeJSON];
    [objectManager setAcceptHeaderWithMIMEType:RKMIMETypeXML];
    [objectManager setAcceptHeaderWithMIMEType:nil];
    
    // .....
//    [objectManager setAcceptHeaderWithMIMEType:@"*/*"];
//    [objectManager setAcceptHeaderWithMIMEType:[NSString stringWithFormat:@"%@,%@,%@,%@", RKMIMETypeJSON, RKMIMETypeTextXML, RKMIMETypeXML, RKMIMETypeFormURLEncoded]];
    
    // 此时无论使用RKRequestProvider或者直接使用RKObjectManager即可.
    RKRequestProvider *requestProvider = objectManager.requestProvider;
    [requestProvider setDefaultHeader:@"User-Agent" value:@"TestAgent"];
    NSURLRequest *request = [requestProvider requestWithMethod:@"GET" path:getPath parameters:parameters];
    NSMutableURLRequest *managerReqeust = [objectManager requestWithObject:nil method:RKRequestMethodGET path:getPath parameters:parameters];
    expect([request.allHTTPHeaderFields isEqual:operation.request.allHTTPHeaderFields]).to.equal(YES);
    expect([managerReqeust.allHTTPHeaderFields isEqual:operation.request.allHTTPHeaderFields]).to.equal(YES);
    
    
    AFHTTPRequestOperation *postOperation = [manager POST:postPath parameters:parameters success:nil failure:nil];
    request = [requestProvider requestWithMethod:@"POST" path:postPath parameters:parameters];
    managerReqeust = [objectManager requestWithObject:nil method:RKRequestMethodPOST path:postPath parameters:parameters];
    expect([request.allHTTPHeaderFields isEqual:postOperation.request.allHTTPHeaderFields]).to.equal(YES);
    
    // RKObjectManager创建出来的request的Content-Type会和AFN2.x有所不同，其余相同.
    [managerReqeust setValue:[postOperation.request.allHTTPHeaderFields objectForKey:@"Content-Type"] forHTTPHeaderField:@"Content-Type"];
    expect([managerReqeust.allHTTPHeaderFields isEqual:postOperation.request.allHTTPHeaderFields]).to.equal(YES);
}

- (void)testJsonParametersForGetRequest {
    NSString *url = @"http://localhost:4567";
    NSURL *baseUrl = [[NSURL alloc] initWithString:url];
    NSDictionary *parameters = @{@"key":@"value", @"中文key":@"中文value"};
    NSString *getPath = @"photolist";
    
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:baseUrl];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    AFHTTPRequestOperation *operation = [manager GET:getPath parameters:parameters success:nil failure:nil];
    
    RKObjectManager *objectManager = [RKObjectManager managerWithBaseURL:baseUrl];
    // Note: requestSerializationMIMEType指明以何种方式来序列化Request的参数.
    objectManager.requestSerializationMIMEType = RKMIMETypeJSON;
    
    // Note: 在request中标明服务器应该返回什么类型的数据，默认是JSON. 但问题是服务器不一定会按照指定的格式正确返回.
    // [objectManager setAcceptHeaderWithMIMEType:RKMIMETypeJSON];
    [objectManager setAcceptHeaderWithMIMEType:nil];
    
    // Note: 指明服务器如果返回的是"text/plain"类型，那么使用那个类去反序列化.
    // [RKMIMETypeSerialization registerClass:[RKNSJSONSerialization class] forMIMEType:@"text/plain"];
    
    RKRequestProvider *requestProvider = objectManager.requestProvider;
    NSURLRequest *request = [requestProvider requestWithMethod:@"GET" path:getPath parameters:parameters];
    NSURLRequest *managerReqeust = [objectManager requestWithObject:nil method:RKRequestMethodGET path:getPath parameters:parameters];
    
    expect([request isEqual:operation.request]).to.equal(YES);
    expect([managerReqeust isEqual:operation.request]).to.equal(YES);
}

- (void)testJsonParametersForPostRequest {
    NSString *url = @"http://localhost:4567";
    NSURL *baseUrl = [[NSURL alloc] initWithString:url];
    NSDictionary *parameters = @{@"key":@"value", @"中文key":@"中文value"};
    NSString *postPath = @"upload";
    
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:baseUrl];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    AFHTTPRequestOperation *operation = [manager POST:postPath parameters:parameters success:nil failure:nil];
    
    RKObjectManager *objectManager = [RKObjectManager managerWithBaseURL:baseUrl];
    // Note: requestSerializationMIMEType指明以何种方式来序列化Request的参数.
    objectManager.requestSerializationMIMEType = RKMIMETypeJSON;
    
    // Note: 在request中标明服务器应该返回什么类型的数据，默认是JSON. 但问题是服务器不一定会按照指定的格式正确返回.
    // [objectManager setAcceptHeaderWithMIMEType:RKMIMETypeJSON];
    [objectManager setAcceptHeaderWithMIMEType:nil];
    
    // Note: 指明服务器如果返回的是"text/plain"类型，那么使用那个类去反序列化.
    // [RKMIMETypeSerialization registerClass:[RKNSJSONSerialization class] forMIMEType:@"text/plain"];
    
    RKRequestProvider *requestProvider = objectManager.requestProvider;
    NSURLRequest *request = [requestProvider requestWithMethod:@"POST" path:postPath parameters:parameters];
    NSURLRequest *managerReqeust = [objectManager requestWithObject:nil method:RKRequestMethodPOST path:postPath parameters:parameters];
    // TODO 文档记录: 该测试Case指明如下问题: RKRequestProvider在创建POST的request时，无法指明不同的序列化方式. RestKit可以通过不同的序列化方式实现对POST请求的支持.
    expect([request.HTTPBody isEqualToData:operation.request.HTTPBody]).to.equal(NO);
    expect([managerReqeust.HTTPBody isEqualToData:operation.request.HTTPBody]).to.equal(YES);
}

- (void)testCreatingGetRequestWithJsonAndCustomHeader {
    NSString *url = @"http://localhost:4567";
    NSURL *baseUrl = [[NSURL alloc] initWithString:url];
    NSDictionary *parameters = @{@"key":@"value"};
    
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:baseUrl];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"中文TestAgent" forHTTPHeaderField:@"User-Agent"];
    AFHTTPRequestOperation *operation = [manager GET:@"photolist" parameters:parameters success:nil failure:nil];
    
    RKObjectManager *objectManager = [RKObjectManager managerWithBaseURL:baseUrl];
    objectManager.requestSerializationMIMEType = RKMIMETypeJSON;
    [objectManager.requestProvider setDefaultHeader:@"User-Agent" value:@"中文TestAgent"];
    NSMutableURLRequest *request = [objectManager requestWithObject:nil method:RKRequestMethodGET path:@"photolist" parameters:parameters];
    
    // 设置了requestSerializationMIMEType后, RKObjectManager创建出来的Request会默认多设置头部Accept = "application/json";. 其他完全一样.
    [request setValue:nil forHTTPHeaderField:@"Accept"];
    expect([request isEqual:operation.request]).to.equal(YES);
}

- (void)testRegisterRKHttpRequestOperation {
    NSString *url = @"http://localhost:4567";
    NSURL *baseUrl = [[NSURL alloc] initWithString:url];
    
    RKObjectManager *manager = [RKObjectManager managerWithBaseURL:baseUrl];
    [manager registerRequestOperationClass:[HTHTTPRequestOperation class]];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"/test" relativeToURL:manager.baseURL]];
    RKObjectRequestOperation *operation = [manager objectRequestOperationWithRequest:request success:nil failure:nil];
    expect(operation.HTTPRequestOperation).to.beKindOf([HTHTTPRequestOperation class]);
}

@end
