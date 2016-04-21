//
//  HTConfigTest.m
//  HTHttp
//
//  Created by NetEase on 15/8/7.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "HTHttpTest.h"

// Test whether global config via RKRequestProvider works correctly for both RKObjectManager and RKRequestProvider.
@interface HTConfigTest : XCTestCase

@end

@implementation HTConfigTest

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

#pragma mark - Default Config

- (void)testGlobalDefaultConfig {
    // 测试RKRequestProvider的默认配置是否同设计相同.
    NSString *url = @"http://localhost:4567";
    NSURL *baseUrl = [[NSURL alloc] initWithString:url];
    
    RKObjectManager *objectManager = [RKObjectManager managerWithBaseURL:baseUrl];
    RKRequestProvider *requestProvider = objectManager.requestProvider;
    expect([requestProvider.baseURL isEqual:baseUrl]).to.equal(YES);
    expect(requestProvider.stringEncoding).to.equal(NSUTF8StringEncoding);
    expect(requestProvider.parameterEncoding).to.equal(RKFormURLParameterEncoding);
    expect(requestProvider.defaultTimeout).to.equal(0);
    expect(nil == requestProvider.defaultCredential).to.equal(YES);
    
    // Note: defaultHeaders默认就有设置 "Accept", @"Accept-Language"和@"User-Agent"三个Header.
    NSDictionary *defaultHeaders = requestProvider.defaultHeaders;
    expect(3 == defaultHeaders.count).to.equal(YES);
    expect([defaultHeaders objectForKey:@"Accept"]).to.equal(RKMIMETypeJSON);
    expect(nil != [defaultHeaders objectForKey:@"Accept-Language"]).to.equal(YES);
    expect(nil != [defaultHeaders objectForKey:@"User-Agent"]).to.equal(YES);
    
    expect(0 == [requestProvider.defaultParams count]).to.equal(YES);
}

- (void)testGlobalDefaultConfigForGetRequest {
    // 测试默认创建出来的Request的配置是否同设计相同.
    NSString *url = @"http://localhost:4567";
    NSURL *baseUrl = [[NSURL alloc] initWithString:url];
    NSDictionary *parameters = @{@"key":@"value", @"中文key":@"中文value"};
    NSString *getPath = @"photolist";
    
    RKObjectManager *objectManager = [RKObjectManager managerWithBaseURL:baseUrl];
    NSURLRequest *request = [objectManager.requestProvider requestWithMethod:@"GET" path:getPath parameters:parameters];
    expect([request timeoutInterval]).to.equal(60);
    expect([request.URL.absoluteString hasPrefix:url]).to.equal(YES);
    
    
    NSURLRequest *managerRequest = [objectManager requestWithObject:nil method:RKRequestMethodGET path:getPath parameters:parameters];
    expect([managerRequest timeoutInterval]).to.equal(60);
    expect([managerRequest.URL.absoluteString hasPrefix:url]).to.equal(YES);
    
    // 默认创建Request不改变RKRequestProvider的默认Header.
    NSDictionary *defaultHeaders = objectManager.requestProvider.defaultHeaders;
    expect(3 == defaultHeaders.count).to.equal(YES);
    expect([defaultHeaders objectForKey:@"Accept"]).to.equal(RKMIMETypeJSON);
    expect(nil != [defaultHeaders objectForKey:@"Accept-Language"]).to.equal(YES);
    expect(nil != [defaultHeaders objectForKey:@"User-Agent"]).to.equal(YES);
    
    // 默认创建的Request与RKRequestProvider的defaultHeaders相同.
    expect([request.allHTTPHeaderFields isEqualToDictionary:defaultHeaders]).to.equal(YES);
    expect([managerRequest.allHTTPHeaderFields isEqualToDictionary:defaultHeaders]).to.equal(YES);
    
    // 中文经过URL Encoding后不会直接在URL字符串中
    expect([request.URL.absoluteString rangeOfString:@"key=value"].length > 0).to.equal(YES);
    expect([managerRequest.URL.absoluteString rangeOfString:@"key=value"].length > 0).to.equal(YES);
    expect([request.URL.absoluteString rangeOfString:@"中文key=中文value"].length > 0).to.equal(NO);
    expect([managerRequest.URL.absoluteString rangeOfString:@"中文key=中文value"].length > 0).to.equal(NO);
}

- (void) testGlobalDefaultConfigForPostRequest {
    // 测试默认创建出来的Request的配置是否同设计相同.
    NSString *url = @"http://localhost:4567";
    NSURL *baseUrl = [[NSURL alloc] initWithString:url];
    NSDictionary *parameters = @{@"key":@"value", @"中文key":@"中文value"};
    NSString *postPath = @"upload";
    
    RKObjectManager *objectManager = [RKObjectManager managerWithBaseURL:baseUrl];
    NSURLRequest *request = [objectManager.requestProvider requestWithMethod:@"POST" path:postPath parameters:parameters];
    expect([request timeoutInterval]).to.equal(60);
    expect([request.URL.absoluteString hasPrefix:url]).to.equal(YES);
    
    NSURLRequest *managerRequest = [objectManager requestWithObject:nil method:RKRequestMethodPOST path:postPath parameters:parameters];
    expect([managerRequest timeoutInterval]).to.equal(60);
    expect([managerRequest.URL.absoluteString hasPrefix:url]).to.equal(YES);
    
    // 默认创建Request不改变RKRequestProvider的默认Header.
    NSDictionary *defaultHeaders = objectManager.requestProvider.defaultHeaders;
    expect(3 == defaultHeaders.count).to.equal(YES);
    expect([defaultHeaders objectForKey:@"Accept"]).to.equal(RKMIMETypeJSON);
    expect(nil != [defaultHeaders objectForKey:@"Accept-Language"]).to.equal(YES);
    expect(nil != [defaultHeaders objectForKey:@"User-Agent"]).to.equal(YES);
    
    // TODO: 需要文档记录. 创建的Post Request默认会加上 "Content-Type"的Header, 而且不受全局defaultHeaders的影响，但是也不会覆盖全局的defaultheaders.
    // 而且直接使用RKRequestProvider和使用RKObjectManager创建出来的Header有差异，一个加上了charset一个没有加.
    [defaultHeaders enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        expect([[request.allHTTPHeaderFields objectForKey:key] isEqual:obj]).to.equal(YES);
    }];
    
    [defaultHeaders enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        expect([[managerRequest.allHTTPHeaderFields objectForKey:key] isEqual:obj]).to.equal(YES);
    }];
    
    expect([[request.allHTTPHeaderFields objectForKey:@"Content-Type"] isEqual:@"application/x-www-form-urlencoded"]).to.equal(YES);
    expect([[managerRequest.allHTTPHeaderFields objectForKey:@"Content-Type"] isEqual:@"application/x-www-form-urlencoded; charset=utf-8"]).to.equal(YES);
    
    expect([request.HTTPBody isEqual:managerRequest.HTTPBody]).to.equal(YES);
    // 中文经过URL Encoding后不会直接在HTTP BODY解析出来的字符串中.
    // TODO: 如何通过单元测试校验解析出来的中文字符串是否是正确的, 和传入的参数对应的呢?
    NSString *string = [[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding];
    expect([string rangeOfString:@"中文key=中文value"].length > 0).to.equal(NO);
    expect([string rangeOfString:@"key=value"].length > 0).to.equal(YES);
    
    string = [[NSString alloc] initWithData:managerRequest.HTTPBody encoding:NSUTF8StringEncoding];
    expect([string rangeOfString:@"中文key=中文value"].length > 0).to.equal(NO);
    expect([string rangeOfString:@"key=value"].length > 0).to.equal(YES);
}

- (void)testGlobalDefaultConfigForMultiPartRequest {
    // 测试默认创建出来的Request的配置是否同设计相同.
    NSString *url = @"http://localhost:4567";
    NSURL *baseUrl = [[NSURL alloc] initWithString:url];
    NSDictionary *parameters = @{@"key":@"value", @"中文Key":@"中文value"};
    NSString *postPath = @"upload";
    
    RKObjectManager *objectManager = [RKObjectManager managerWithBaseURL:baseUrl];
    NSURLRequest *request = [objectManager.requestProvider multipartFormRequestWithMethod:@"POST" path:postPath parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFormData:[@"testing" dataUsingEncoding:NSUTF8StringEncoding] name:@"part"];
    }];
    expect([request timeoutInterval]).to.equal(60);
    expect([request.URL.absoluteString hasPrefix:url]).to.equal(YES);
    
    NSURLRequest *managerRequest = [objectManager multipartFormRequestWithObject:nil method:RKRequestMethodPOST path:postPath parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFormData:[@"testing" dataUsingEncoding:NSUTF8StringEncoding] name:@"part"];
    }];
    expect([managerRequest timeoutInterval]).to.equal(60);
    expect([managerRequest.URL.absoluteString hasPrefix:url]).to.equal(YES);


    // header相比RKRequestProvider的default Header增加了Content-Length和Content-Type两个. 默认创建Request不改变RKRequestProvider的默认Header.
    // TODO: 需要文档记录. 创建的Post Request默认会加上 "Content-Type"和"Content-Length"的Header, 而且不受全局defaultHeaders的影响，但是也不会覆盖全局的defaultheaders.
    // 而且直接使用RKRequestProvider和使用RKObjectManager创建出来的Header有差异，一个加上了charset一个没有加.
    NSDictionary *defaultHeaders = objectManager.requestProvider.defaultHeaders;
    expect(3 == defaultHeaders.count).to.equal(YES);
    expect([defaultHeaders objectForKey:@"Accept"]).to.equal(RKMIMETypeJSON);
    expect(nil != [defaultHeaders objectForKey:@"Accept-Language"]).to.equal(YES);
    expect(nil != [defaultHeaders objectForKey:@"User-Agent"]).to.equal(YES);
    [defaultHeaders enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        expect([[request.allHTTPHeaderFields objectForKey:key] isEqual:obj]).to.equal(YES);
    }];
    
    [defaultHeaders enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        expect([[managerRequest.allHTTPHeaderFields objectForKey:key] isEqual:obj]).to.equal(YES);
    }];
    
    // 默认Header一般为如下格式:
    //    {
    //        Accept = "application/json";
    //        "Accept-Language" = "en;q=1, fr;q=0.9, de;q=0.8, zh-Hans;q=0.7, zh-Hant;q=0.6, ja;q=0.5";
    //        "Content-Length" = 292;
    //        "Content-Type" = "multipart/form-data; boundary=Boundary+58B0C9689A4B21CE";
    //        "User-Agent" = "(null)/(null) (iPhone Simulator; iOS 8.3; Scale/2.00)";
    //    }
    expect([[request.allHTTPHeaderFields objectForKey:@"Content-Type"] hasPrefix:@"multipart/form-data"]).to.equal(YES);
    expect(nil != [request.allHTTPHeaderFields objectForKey:@"Content-Length"]).to.equal(YES);
    expect([[request.allHTTPHeaderFields objectForKey:@"Content-Length"] isEqual:[managerRequest.allHTTPHeaderFields objectForKey:@"Content-Length"]]).to.equal(YES);
    
    // default Params
    expect(request.HTTPBody).to.equal(nil);
    expect(managerRequest.HTTPBody).to.equal(nil);
    // TODO: 检查HTTPBODYStream是否正确.
}

#pragma mark - Test StringEncoding

- (void)testGlobalHTConfigStringEncodingForGetRequest {
    // 测试stringEncoding配置是否正确生效.
    NSString *url = @"http://localhost:4567";
    NSURL *baseUrl = [[NSURL alloc] initWithString:url];
    NSDictionary *parameters = @{@"key":@"中文字符串"};
    NSString *getPath = @"photolist";
    
    RKObjectManager *manager = [RKObjectManager managerWithBaseURL:baseUrl];
    // Default stringEncoding is NSUTF8StringEncoding.
    NSURLRequest *request = [manager requestWithObject:nil method:RKRequestMethodGET path:getPath parameters:parameters];
    
    manager.requestProvider.stringEncoding = NSASCIIStringEncoding;
    NSURLRequest *ascRequest = [manager requestWithObject:nil method:RKRequestMethodGET path:getPath parameters:parameters];
    // stringEncoding变化时, encode出来的完整Url会与默认不同.
    expect([request.URL.absoluteString isEqualToString:ascRequest.URL.absoluteString]).to.equal(NO);
    expect([request isEqual:ascRequest]).to.equal(NO);
}

- (void)testGlobalHTConfigStringEncodingForPostRequest {
    NSString *url = @"http://localhost:4567";
    NSURL *baseUrl = [[NSURL alloc] initWithString:url];
    NSDictionary *parameters = @{@"key":@"中文字符串"};
    NSString *postPath = @"upload";
    
    RKObjectManager *manager = [RKObjectManager managerWithBaseURL:baseUrl];
    // Default stringEncoding is NSUTF8StringEncoding.
    NSURLRequest *request = [manager requestWithObject:nil method:RKRequestMethodPOST path:postPath parameters:parameters];
    
    manager.requestProvider.stringEncoding = NSASCIIStringEncoding;
    NSURLRequest *ascRequest = [manager requestWithObject:nil method:RKRequestMethodPOST path:postPath parameters:parameters];
    expect([request.URL.absoluteString isEqualToString:ascRequest.URL.absoluteString]).to.equal(YES);
    
    expect([request.HTTPBody isEqualToData:ascRequest.HTTPBody]).to.equal(YES);
    // 对于POST请求，stringEncoding的改变仅仅对"Content-Type"有影响, 对于HTTPBody无影响.
    // 如果是由RKRequestProvider创建的请求，对"Content-Type"没有影响, 对于HTTPBody有影响.
    // "Content-Type" = "application/x-www-form-urlencoded; charset=utf-8";
    // "Content-Type" = "application/x-www-form-urlencoded; charset=us-ascii";
    expect([[request.allHTTPHeaderFields objectForKey:@"Content-Type"] isEqualToString:[ascRequest.allHTTPHeaderFields objectForKey:@"Content-Type"]]).to.equal(NO);
    
    NSMutableDictionary *requestHeaders = [NSMutableDictionary dictionaryWithDictionary:request.allHTTPHeaderFields];
    NSMutableDictionary *ascRequestHeaders = [NSMutableDictionary dictionaryWithDictionary:ascRequest.allHTTPHeaderFields];
    [requestHeaders setValue:nil forKey:@"Content-Type"];
    [ascRequestHeaders setValue:nil forKey:@"Content-Type"];
    expect([requestHeaders isEqualToDictionary:ascRequestHeaders]).to.equal(YES);
}

- (void)testGlobalHTConfigStringEncodingForMultiPartRequest {
    NSString *url = @"http://localhost:4567";
    NSURL *baseUrl = [[NSURL alloc] initWithString:url];
    NSDictionary *parameters = @{@"key":@"中文字符串"};
    NSString *postPath = @"upload";
    
    RKObjectManager *manager = [RKObjectManager managerWithBaseURL:baseUrl];
    // Default stringEncoding is NSUTF8StringEncoding.
    NSURLRequest *request = [manager multipartFormRequestWithObject:nil method:RKRequestMethodPOST path:postPath parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFormData:[@"testing" dataUsingEncoding:NSUTF8StringEncoding] name:@"part"];
    }];
    
    
    manager.requestProvider.stringEncoding = NSASCIIStringEncoding;
    NSURLRequest *ascRequest = [manager multipartFormRequestWithObject:nil method:RKRequestMethodPOST path:postPath parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFormData:[@"testing" dataUsingEncoding:NSUTF8StringEncoding] name:@"part"];
    }];

    expect([request.URL.absoluteString isEqualToString:ascRequest.URL.absoluteString]).to.equal(YES);
    
    NSMutableDictionary *requestHeaders = [NSMutableDictionary dictionaryWithDictionary:request.allHTTPHeaderFields];
    NSMutableDictionary *ascRequestHeaders = [NSMutableDictionary dictionaryWithDictionary:ascRequest.allHTTPHeaderFields];
    // 编码方式改变会影响HTTP BODY Stream以及Content-Length.
    expect([[requestHeaders objectForKey:@"Content-Length"] isEqual:[ascRequestHeaders objectForKey:@"Content-Length"]]).to.equal(NO);
    expect([request.HTTPBodyStream isEqual:ascRequest.HTTPBodyStream]).to.equal(NO);
}

#pragma mark - Test ParameterEncoding

- (void)testAFHttpCientParameterEncodingForGetRequest {
    // Test whether RKObjectManager get correct request after setting parameter encoding via RKRequestProvider.
    // parameterEncoding的设定不影响GET, HEAD, DELETE类型的request.
    NSString *url = @"http://localhost:4567";
    NSURL *baseUrl = [[NSURL alloc] initWithString:url];
    NSDictionary *parameters = @{@"key":@"中文字符串"};
    NSString *getPath = @"photolist";
    
    RKObjectManager *manager = [RKObjectManager managerWithBaseURL:baseUrl];
    // Default parameterEncoding is AFFormURLParameterEncoding.
    expect(manager.requestProvider.parameterEncoding == RKFormURLParameterEncoding).to.equal(YES);
    NSURLRequest *request = [manager requestWithObject:nil method:RKRequestMethodGET path:getPath parameters:parameters];
    
    manager.requestProvider.parameterEncoding = RKJSONParameterEncoding;
    NSURLRequest *ascRequest = [manager requestWithObject:nil method:RKRequestMethodGET path:getPath parameters:parameters];
    
    expect([request isEqual:ascRequest]).to.equal(YES);
    expect([request.URL.absoluteString isEqualToString:ascRequest.URL.absoluteString]).to.equal(YES);
}

- (void)testAFHttpCientParameterEncodingForPostRequest {
    // Test whether RKObjectManager get correct request after setting parameter encoding via RKRequestProvider.
    NSString *url = @"http://localhost:4567";
    NSURL *baseUrl = [[NSURL alloc] initWithString:url];
    NSDictionary *parameters = @{@"key":@"中文字符串"};
    NSString *postPath = @"upload";
    
    RKObjectManager *manager = [RKObjectManager managerWithBaseURL:baseUrl];
    // Default parameterEncoding is AFFormURLParameterEncoding.
    expect(manager.requestProvider.parameterEncoding == RKFormURLParameterEncoding).to.equal(YES);
    NSURLRequest *request = [manager requestWithObject:nil method:RKRequestMethodPOST path:postPath parameters:parameters];
    
    
    manager.requestProvider.parameterEncoding = RKJSONParameterEncoding;
    NSURLRequest *ascRequest = [manager requestWithObject:nil method:RKRequestMethodPOST path:postPath parameters:parameters];
    expect([request.URL.absoluteString isEqualToString:ascRequest.URL.absoluteString]).to.equal(YES);
    
    // HTTP body should be same as HTTP Body is built outside RKRequestProvider.
    // But HTTP Header is different as it is built inside RKRequestProvider.
    
    // TODO: 这里存在问题. 设置了parameterEncoding无效, 因为这里的处理是通过RestKit进行处理的.
    // 必须设置    manager.requestSerializationMIMEType = RKMIMETypeJSON;才有效.
    expect([request.HTTPBody isEqualToData:ascRequest.HTTPBody]).to.equal(YES);
//    expect([[request.allHTTPHeaderFields objectForKey:@"Content-Type"] isEqualToString:[ascRequest.allHTTPHeaderFields objectForKey:@"Content-Type"]]).to.equal(NO);
//    expect([request isEqual:ascRequest]).to.equal(NO);
}

#pragma mark - Test Base Request Configuration

- (void)testGlobalHTConfigTimeInterval {
    // 测试配置全局超时时间是否正确生效
    NSString *url = @"http://localhost:4567";
    NSURL *baseUrl = [[NSURL alloc] initWithString:url];
    NSDictionary *parameters = @{@"key":@"value"};
    NSString *getPath = @"photolist";
    
    RKObjectManager *objectManager = [RKObjectManager managerWithBaseURL:baseUrl];
    // 默认超时时间为60s
    NSURLRequest *request = [objectManager.requestProvider requestWithMethod:@"GET" path:getPath parameters:parameters];
    expect([request timeoutInterval]).to.equal(60);
    
    NSURLRequest *managerReqeust = [objectManager requestWithObject:nil method:RKRequestMethodGET path:getPath parameters:parameters];
    expect([managerReqeust timeoutInterval]).to.equal(60);

    objectManager.requestProvider.defaultTimeout = 100;
    expect(objectManager.requestProvider.defaultTimeout).to.equal(100);
    
    request = [objectManager.requestProvider requestWithMethod:@"GET" path:getPath parameters:parameters];
    expect([request timeoutInterval]).to.equal(100);
    
    objectManager.requestProvider.defaultTimeout = 120;
    managerReqeust = [objectManager requestWithObject:nil method:RKRequestMethodGET path:getPath parameters:parameters];
    expect([managerReqeust timeoutInterval]).to.equal(120);
}

- (void)testGlobalHTConfigBaseUrl {
    // 测试配置全局baseUrl是否正确生效
    NSString *url = @"http://localhost:4567";
    NSURL *baseUrl = [[NSURL alloc] initWithString:url];
    NSDictionary *parameters = @{@"key":@"value"};
    NSString *getPath = @"photolist";
    
    RKObjectManager *objectManager = [RKObjectManager managerWithBaseURL:baseUrl];
    objectManager.requestProvider.baseURL = [NSURL URLWithString:@"http://testAPI"];
    
    NSURLRequest *managerReqeust = [objectManager requestWithObject:nil method:RKRequestMethodGET path:getPath parameters:parameters];
    expect([managerReqeust.URL.host isEqualToString:@"testAPI"]).to.equal(YES);
}

#pragma mark - Test Config Default Headers

- (void)testGlobalHTConfigHeaderForGetRequest {
    // 测试配置全局默认Header是否正确生效
    NSString *url = @"http://localhost:4567";
    NSURL *baseUrl = [[NSURL alloc] initWithString:url];
    NSDictionary *parameters = @{@"key":@"value"};
    NSDictionary *header = @{@"TestHeaderKey":@"TestHeaderValue"};
    NSString *getPath = @"photolist";
    
    RKObjectManager *objectManager = [RKObjectManager managerWithBaseURL:baseUrl];
    objectManager.requestProvider.defaultHeaders = header;
    
    NSURLRequest *managerReqeust = [objectManager requestWithObject:nil method:RKRequestMethodGET path:getPath parameters:parameters];
    expect([[managerReqeust.allHTTPHeaderFields objectForKey:@"TestHeaderKey"] isEqualToString:@"TestHeaderValue"]).to.equal(YES);
    expect(nil == [managerReqeust.allHTTPHeaderFields objectForKey:@"Accept"]).to.equal(YES);
    expect([managerReqeust.allHTTPHeaderFields isEqualToDictionary:header]).to.equal(YES);
}

- (void)testGlobalHTConfigHeaderForPostRequest {
    // 测试配置全局默认Header是否正确生效.
    NSString *url = @"http://localhost:4567";
    NSURL *baseUrl = [[NSURL alloc] initWithString:url];
    NSDictionary *parameters = @{@"key":@"value"};
    NSDictionary *header = @{@"TestHeaderKey":@"TestHeaderValue"};
    NSString *postPath = @"upload";
    
    RKObjectManager *objectManager = [RKObjectManager managerWithBaseURL:baseUrl];
    objectManager.requestProvider.defaultHeaders = header;
    
    NSURLRequest *managerReqeust = [objectManager requestWithObject:nil method:RKRequestMethodPOST path:postPath parameters:parameters];
    expect([[managerReqeust.allHTTPHeaderFields objectForKey:@"TestHeaderKey"] isEqualToString:@"TestHeaderValue"]).to.equal(YES);
    expect(nil == [managerReqeust.allHTTPHeaderFields objectForKey:@"Accept"]).to.equal(YES);
    
    // TODO: 文档需要记录. 对于POST请求, "Content-Type"会由RestKit自己加上. 与全局配置的defaultHeaders无关.
    NSMutableDictionary *requestHeaders = [NSMutableDictionary dictionaryWithDictionary:managerReqeust.allHTTPHeaderFields];
    expect([requestHeaders isEqualToDictionary:header]).to.equal(NO);
    [requestHeaders setValue:nil forKey:@"Content-Type"];
    expect([requestHeaders isEqualToDictionary:header]).to.equal(YES);
}

- (void)testGlobalHTConfigSetHeaderForGetRequest {
    // 测试添加某一个default Header.
    NSString *url = @"http://localhost:4567";
    NSURL *baseUrl = [[NSURL alloc] initWithString:url];
    NSDictionary *parameters = @{@"key":@"value"};
    NSString *getPath = @"photolist";
    
    RKObjectManager *objectManager = [RKObjectManager managerWithBaseURL:baseUrl];
    NSURLRequest *defaultRequest = [objectManager requestWithObject:nil method:RKRequestMethodGET path:getPath parameters:parameters];
    NSDictionary *defaultHeaderFields = defaultRequest.allHTTPHeaderFields;
    
    [objectManager.requestProvider setDefaultHeader:@"TestHeaderKey" value:@"TestHeaderValue"];
    NSURLRequest *managerRequest = [objectManager requestWithObject:nil method:RKRequestMethodGET path:getPath parameters:parameters];
    NSDictionary *requestHeaderFields = managerRequest.allHTTPHeaderFields;
    expect([[requestHeaderFields objectForKey:@"TestHeaderKey"] isEqualToString:@"TestHeaderValue"]).to.equal(YES);
    
    // 原有的Header都保留了.
    [defaultHeaderFields enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        expect([[requestHeaderFields objectForKey:key] isEqual:obj]).to.equal(YES);
    }];
}

- (void)testGlobalHTConfigSetHeaderForPostRequest {
    // 测试添加某一个default header.
    NSString *url = @"http://localhost:4567";
    NSURL *baseUrl = [[NSURL alloc] initWithString:url];
    NSDictionary *parameters = @{@"key":@"value"};
    NSString *postPath = @"upload";
    
    RKObjectManager *objectManager = [RKObjectManager managerWithBaseURL:baseUrl];
    NSURLRequest *defaultRequest = [objectManager requestWithObject:nil method:RKRequestMethodPOST path:postPath parameters:parameters];
    NSDictionary *defaultHeaderFields = defaultRequest.allHTTPHeaderFields;
    
    [objectManager.requestProvider setDefaultHeader:@"TestHeaderKey" value:@"TestHeaderValue"];
    NSURLRequest *managerRequest = [objectManager requestWithObject:nil method:RKRequestMethodPOST path:postPath parameters:parameters];
    NSDictionary *requestHeaderFields = managerRequest.allHTTPHeaderFields;
    expect([[requestHeaderFields objectForKey:@"TestHeaderKey"] isEqualToString:@"TestHeaderValue"]).to.equal(YES);
    
    // 原有的Header都保留了.
    [defaultHeaderFields enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        expect([[requestHeaderFields objectForKey:key] isEqual:obj]).to.equal(YES);
    }];
}

- (void)testGlobalHTConfigAddHeadersForGetRequest {
    // 测试一次性添加多个default header.
    NSString *url = @"http://localhost:4567";
    NSURL *baseUrl = [[NSURL alloc] initWithString:url];
    NSDictionary *parameters = @{@"key":@"value"};
    NSString *getPath = @"photolist";
    NSDictionary *userDefaultHeaders = @{@"User-Agent":@"NeteaseAgent", @"UserName":@"lwang", @"TestHeaderKey":@"TestHeaderValue"};
    
    RKObjectManager *objectManager = [RKObjectManager managerWithBaseURL:baseUrl];
    NSURLRequest *defaultRequest = [objectManager requestWithObject:nil method:RKRequestMethodGET path:getPath parameters:parameters];
    NSDictionary *defaultHeaderFields = defaultRequest.allHTTPHeaderFields;
    
    [objectManager.requestProvider addDefaultHeaders:userDefaultHeaders];
    NSURLRequest *managerRequest = [objectManager requestWithObject:nil method:RKRequestMethodGET path:getPath parameters:parameters];
    NSDictionary *requestHeaderFields = managerRequest.allHTTPHeaderFields;
    
    // 新加的Header都已经生效.
    [userDefaultHeaders enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        expect([[requestHeaderFields objectForKey:key] isEqual:obj]).to.equal(YES);
    }];
    
    // 原有的Header都被保留或者更新.
    [defaultHeaderFields enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        id requestValue = [requestHeaderFields objectForKey:key];
        // 默认的Header一定存在.
        expect(nil != requestValue).to.equal(YES);
        if (nil != [userDefaultHeaders objectForKey:key]) {
            // 如果是新增的Header, 那么一般和原有的不同.
            expect([requestValue isEqual:obj]).to.equal(NO);
        }
    }];
}

- (void)testGlobalHTConfigAddHeadersForPostRequest {
    // 测试一次性添加多个default header.
    NSString *url = @"http://localhost:4567";
    NSURL *baseUrl = [[NSURL alloc] initWithString:url];
    NSDictionary *parameters = @{@"key":@"value"};
    NSString *postPath = @"upload";
    NSDictionary *userDefaultHeaders = @{@"User-Agent":@"NeteaseAgent", @"UserName":@"lwang", @"TestHeaderKey":@"TestHeaderValue"};
    
    RKObjectManager *objectManager = [RKObjectManager managerWithBaseURL:baseUrl];
    NSURLRequest *defaultRequest = [objectManager requestWithObject:nil method:RKRequestMethodPOST path:postPath parameters:parameters];
    NSDictionary *defaultHeaderFields = defaultRequest.allHTTPHeaderFields;
    
    [objectManager.requestProvider addDefaultHeaders:userDefaultHeaders];
    NSURLRequest *managerRequest = [objectManager requestWithObject:nil method:RKRequestMethodPOST path:postPath parameters:parameters];
    NSDictionary *requestHeaderFields = managerRequest.allHTTPHeaderFields;
    
    // 新加的Header都已经生效.
    [userDefaultHeaders enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        expect([[requestHeaderFields objectForKey:key] isEqual:obj]).to.equal(YES);
    }];
    
    // 原有的Header都被保留或者更新.
    [defaultHeaderFields enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        id requestValue = [requestHeaderFields objectForKey:key];
        // 默认的Header一定存在.
        expect(nil != requestValue).to.equal(YES);
        if (nil != [userDefaultHeaders objectForKey:key]) {
            // 如果是新增的Header, 那么一般和原有的不同.
            expect([requestValue isEqual:obj]).to.equal(NO);
        }
    }];
}

- (void)testGlobalHTConfigContentTypeHeaderForPostRequest {
    // 测试全局配置的"Content-Type" Header是否生效.
    NSString *url = @"http://localhost:4567";
    NSURL *baseUrl = [[NSURL alloc] initWithString:url];
    NSDictionary *parameters = @{@"key":@"value"};
    NSString *postPath = @"upload";
    NSDictionary *userDefaultHeaders = @{@"Content-Type":@"TestContentType"};
    
    RKObjectManager *objectManager = [RKObjectManager managerWithBaseURL:baseUrl];
    [objectManager.requestProvider addDefaultHeaders:userDefaultHeaders];

    NSURLRequest *request = [objectManager.requestProvider requestWithMethod:@"POST" path:postPath parameters:parameters];
    NSDictionary *requestHeaderFields = request.allHTTPHeaderFields;
    expect([requestHeaderFields objectForKey:@"Content-Type"]).to.equal(@"TestContentType");
    
    // TODO: 需要文档记录. 对于RKObjectManager创建的Post request, 用户设置的"Content-Type"无效.
    NSURLRequest *managerRequest = [objectManager requestWithObject:nil method:RKRequestMethodPOST path:postPath parameters:parameters];
    NSDictionary *managerRequestHeaderFields = managerRequest.allHTTPHeaderFields;
    expect([[managerRequestHeaderFields objectForKey:@"Content-Type"] isEqualToString:@"TestContentType"]).to.equal(NO);
}

#pragma mark - Test Config Delegate

- (void)testHTConfigDelegateIsCalled {
    // 测试通过delegate来配置是否正确生效
    NSString *url = @"http://localhost:4567";
    NSURL *baseUrl = [[NSURL alloc] initWithString:url];
    NSDictionary *parameters = @{@"key":@"value"};
    NSString *getPath = @"photolist";
    
    RKObjectManager *objectManager = [RKObjectManager managerWithBaseURL:baseUrl];
    objectManager.requestProvider.defaultTimeout = 100;
    
    NSURLRequest *managerReqeust = [objectManager requestWithObject:nil method:RKRequestMethodGET path:getPath parameters:parameters];
    expect([managerReqeust timeoutInterval] == 100).to.equal(YES);
    
    HTConfigDelegateObject *delegate = [[HTConfigDelegateObject alloc] init];
    objectManager.configDelegate = delegate;
    NSURLRequest *customRequest = [objectManager requestWithObject:nil method:RKRequestMethodGET path:getPath parameters:parameters];
    // Note: Custom Request不可以改变baseURL. 因为这个是request创建好之后再修改的.
    expect([customRequest timeoutInterval] == 120).to.equal(YES);
}

#pragma mark - Test Config Default Parameters

- (void)testGlobalHTConfigParametersForGetRequest {
    // 测试配置全局默认参数是否正确生效
    NSString *url = @"http://localhost:4567";
    NSURL *baseUrl = [[NSURL alloc] initWithString:url];
    NSDictionary *parameters = @{@"key":@"value"};
    NSDictionary *globalParameters = @{@"globalKey":@"globalValue"};
    NSString *getPath = @"photolist";
    
    RKObjectManager *objectManager = [RKObjectManager managerWithBaseURL:baseUrl];
    objectManager.requestProvider.defaultParams = globalParameters;
    
    NSURLRequest *managerReqeust = [objectManager requestWithObject:nil method:RKRequestMethodGET path:getPath parameters:parameters];
    NSRange range = [managerReqeust.URL.absoluteString rangeOfString:@"globalKey=globalValue"];
    expect(range.length > 0).to.equal(YES);
    
    range = [managerReqeust.URL.absoluteString rangeOfString:@"key=value"];
    expect(range.length > 0).to.equal(YES);
}

- (void)testGlobalHTConfigParametersForPostRequest {
    // 测试配置全局默认参数是否正确生效
    NSString *url = @"http://localhost:4567";
    NSURL *baseUrl = [[NSURL alloc] initWithString:url];
    NSDictionary *parameters = @{@"key":@"value"};
    NSDictionary *globalParameters = @{@"globalKey":@"globalValue"};
    NSString *postPath = @"upload";
    
    RKObjectManager *objectManager = [RKObjectManager managerWithBaseURL:baseUrl];
    objectManager.requestProvider.defaultParams = globalParameters;
    
    NSURLRequest *managerReqeust = [objectManager requestWithObject:nil method:RKRequestMethodPOST path:postPath parameters:parameters];
    NSString *string = [[NSString alloc] initWithData:managerReqeust.HTTPBody encoding:NSUTF8StringEncoding];
    NSRange range = [string rangeOfString:@"globalKey=globalValue"];
    expect(range.length > 0).to.equal(YES);
    
    range = [string rangeOfString:@"key=value"];
    expect(range.length > 0).to.equal(YES);
}

- (void)testGlobalHTConfigParametersForMultiPartRequest {
    // 测试配置全局默认参数是否正确生效
    NSString *url = @"http://localhost:4567";
    NSURL *baseUrl = [[NSURL alloc] initWithString:url];
    NSDictionary *parameters = @{@"key":@"value"};
    NSDictionary *globalParameters = @{@"globalKey":@"globalValue"};
    NSString *postPath = @"upload";
    
    RKObjectManager *objectManager = [RKObjectManager managerWithBaseURL:baseUrl];
    objectManager.requestProvider.defaultParams = globalParameters;
    
    NSURLRequest *managerRequest = [objectManager multipartFormRequestWithObject:nil method:RKRequestMethodPOST path:postPath parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFormData:[@"testing" dataUsingEncoding:NSUTF8StringEncoding] name:@"part"];
    }];
    
    // TODO: 需要测试managerRequest的HTTP STREAM BODY是否包含了全局的参数; 是否可以支持中文参数；是否可以支持XML格式的参数; 是否一定需要requestSerializer才可以支持.
    // 全局参数似乎是没有起作用.
}

#pragma mark - Test Config Security

- (void)testGlobalHTConfigSecurityPolicy {
    // 测试配置全局的SecurityPolicy是否正确设置到了HTTPRequestOperation中.
    NSString *url = @"http://localhost:4567";
    NSURL *baseUrl = [[NSURL alloc] initWithString:url];
    NSDictionary *parameters = @{@"key":@"value"};
    NSString *getPath = @"photolist";
    
    RKObjectManager *objectManager = [RKObjectManager managerWithBaseURL:baseUrl];
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy defaultPolicy];
    securityPolicy.allowInvalidCertificates = YES;
    objectManager.requestProvider.securityPolicy = securityPolicy;
    
    RKObjectRequestOperation *operation = [objectManager appropriateObjectRequestOperationWithObject:nil method:RKRequestMethodGET path:getPath parameters:parameters];
    expect(operation.HTTPRequestOperation.securityPolicy == securityPolicy).to.equal(YES);
}

- (void)testGlobalHTConfigDefaultCredential {
    NSString *url = @"http://localhost:4567";
    NSURL *baseUrl = [[NSURL alloc] initWithString:url];
    NSDictionary *parameters = @{@"key":@"value"};
    NSString *getPath = @"photolist";
    
    RKObjectManager *objectManager = [RKObjectManager managerWithBaseURL:baseUrl];
    NSURLCredential *credential = [NSURLCredential credentialWithUser:@"lwang" password:@"testPassword" persistence:NSURLCredentialPersistenceForSession];
    objectManager.requestProvider.defaultCredential = credential;
    
    RKObjectRequestOperation *operation = [objectManager appropriateObjectRequestOperationWithObject:nil method:RKRequestMethodGET path:getPath parameters:parameters];
    expect(operation.HTTPRequestOperation.credential == credential).to.equal(YES);
    expect([operation.HTTPRequestOperation.credential.user isEqualToString:@"lwang"]).to.equal(YES);
    expect([operation.HTTPRequestOperation.credential.password isEqualToString:@"testPassword"]).to.equal(YES);
    expect(NSURLCredentialPersistenceForSession == operation.HTTPRequestOperation.credential.persistence).to.equal(YES);
}

@end
