//
//  HTCacheTest.m
//  HTHttp
//
//  Created by NetEase on 15/8/13.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "HTHttpTest.h"
#import "HTCacheManager.h"
#import "HTCachePolicyManager.h"
#import "NSURLRequest+HTCache.h"
#import "NSURLResponse+HTCache.h"
#import "HTHuman.h"
#import "HTDefaultCachePolicy.h"
#import "HTWriteOnlyCachePolicy.h"
#import "HTHTTPRequestOperation.h"

@interface HTCacheTest : XCTestCase

@end

@implementation HTCacheTest

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

- (void)testCacheWorkflow {
    NSString *url = @"http://localhost:4567";
    NSURL *baseUrl = [[NSURL alloc] initWithString:url];
    
    RKObjectManager *manager = [RKObjectManager managerWithBaseURL:baseUrl];
    [manager registerRequestOperationClass:[HTHTTPRequestOperation class]];
    
    RKObjectMapping *mapping1 = [RKObjectMapping mappingForClass:[HTHuman class]];
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping1 method:RKRequestMethodGET pathPattern:@"/JSON/humans/1.json" keyPath:@"human" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [manager addResponseDescriptor:responseDescriptor];

    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"/JSON/humans/1.json" relativeToURL:manager.baseURL]];
    request.ht_cachePolicy = 1;
    
    RKObjectRequestOperation *operation = [manager objectRequestOperationWithRequest:request success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        NSLog(@"%@", mappingResult);
        
        CFRunLoopRef runLoopRef = CFRunLoopGetCurrent();
        CFRunLoopStop(runLoopRef);
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
        
        CFRunLoopRef runLoopRef = CFRunLoopGetCurrent();
        CFRunLoopStop(runLoopRef);
    }];
    expect(operation.HTTPRequestOperation).to.beKindOf([HTHTTPRequestOperation class]);
    
    [operation start];
    [operation waitUntilFinished];
    
    CFRunLoopRun();
}

- (void)testGetCacheCurSize {
    NSUInteger cacheSize = [[HTCacheManager sharedManager] getCurCacheSize];
    expect(cacheSize > 0).to.equal(YES);
}

- (void)testGetCacheSizeWithCompletion {
    [[HTCacheManager sharedManager] calculateSizeWithCompletionBlock:^(NSUInteger cacheSize) {
        NSLog(@"cacheSize is %@", @(cacheSize));
        expect(cacheSize > 0).to.equal(YES);
        
        CFRunLoopRef runLoopRef = CFRunLoopGetCurrent();
        CFRunLoopStop(runLoopRef);
    }];
    
    CFRunLoopRun();
}

- (void)testLoadResponseFromMemoryCache {
    NSURL *cachedURL = [[NSURL alloc] initWithString:@"http://localhost:4567/cacheTest"];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[[NSURL alloc] initWithString:@"http://localhost:4567/cacheTest"]];
    NSData *responseData = [[NSData alloc] initWithBase64Encoding:@"testlwang"];
    NSURLResponse *testResponse = [[NSHTTPURLResponse alloc] initWithURL:cachedURL statusCode:200 HTTPVersion:@"1.1" headerFields:@{@"testKey":@"testValue"}];
    NSCachedURLResponse *response = [[NSCachedURLResponse alloc] initWithResponse:testResponse data:responseData];
    
    NSDate *now = [NSDate date];
    HTCachedResponse *cachedResponse = [[HTCachedResponse alloc] init];
    cachedResponse.response = response;
    cachedResponse.createDate = now;
    cachedResponse.expireDate = [NSDate dateWithTimeInterval:86400 sinceDate:now];
    [[HTCacheManager sharedManager] storeCachedResponse:cachedResponse forRequest:request];
    
    HTCachedResponse *fetchedResponse = [[HTCacheManager sharedManager] cachedResponseForRequest:request];
    // 从Memory Cache中获取的是同一个对象.
    expect(fetchedResponse == cachedResponse).to.equal(YES);
}

- (void)testLoadResponseFromDiskCache {
    [[HTCacheManager sharedManager] removeAllCachedResponsesOnCompletion:^{
        NSURL *cachedURL = [[NSURL alloc] initWithString:@"http://localhost:4567/cacheTest"];
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[[NSURL alloc] initWithString:@"http://localhost:4567/cacheTest"]];
        const char *resonseContent = "testlwang";
        NSData *responseData = [[NSData alloc] initWithBytes:resonseContent length:strlen(resonseContent)];
        NSHTTPURLResponse *testResponse = [[NSHTTPURLResponse alloc] initWithURL:cachedURL statusCode:200 HTTPVersion:@"1.1" headerFields:@{@"testKey":@"testValue"}];
        NSCachedURLResponse *response = [[NSCachedURLResponse alloc] initWithResponse:testResponse data:responseData];
        
        NSDate *now = [NSDate date];
        HTCachedResponse *cachedResponse = [[HTCachedResponse alloc] init];
        cachedResponse.response = response;
        cachedResponse.createDate = now;
        cachedResponse.expireDate = [NSDate dateWithTimeInterval:86400 sinceDate:now];
        [[HTCacheManager sharedManager] storeCachedResponse:cachedResponse forRequest:request];
        
        [[HTCacheManager sharedManager] clearMemoryCache];
        HTCachedResponse *fetchedResponse = [[HTCacheManager sharedManager] cachedResponseForRequest:request];
        // Memory Cache已经清除，获取到的可能不是同一个对象.
        expect(fetchedResponse == cachedResponse).to.equal(NO);
        expect((long long)[fetchedResponse.createDate timeIntervalSince1970] == (long long)[cachedResponse.createDate timeIntervalSince1970]).to.equal(YES);
        expect((long long)[fetchedResponse.expireDate timeIntervalSince1970] == (long long)[cachedResponse.expireDate timeIntervalSince1970]).to.equal(YES);
        expect([fetchedResponse.requestKey isEqualToString:cachedResponse.requestKey]).to.equal(YES);
        NSURLResponse *fetchedURLResponse = fetchedResponse.response.response;
        expect([fetchedURLResponse isKindOfClass:[NSHTTPURLResponse class]]).to.equal(YES);
        expect([fetchedURLResponse.URL isEqual:testResponse.URL]).to.equal(YES);
        expect([((NSHTTPURLResponse*)fetchedURLResponse).allHeaderFields isEqualToDictionary:testResponse.allHeaderFields]).to.equal(YES);
        expect(((NSHTTPURLResponse*)fetchedURLResponse).statusCode == testResponse.statusCode).to.equal(YES);
        
        expect([fetchedResponse.response.data isEqual:cachedResponse.response.data]).to.equal(YES);
        
        CFRunLoopRef runLoopRef = CFRunLoopGetCurrent();
        CFRunLoopStop(runLoopRef);
    }];
    
    CFRunLoopRun();
}

- (void)testIsResponseFromCache {
    NSString *url = @"http://localhost:4567";
    NSURL *baseUrl = [[NSURL alloc] initWithString:url];
    
    RKObjectManager *manager = [RKObjectManager managerWithBaseURL:baseUrl];
    [manager registerRequestOperationClass:[HTHTTPRequestOperation class]];
    
    RKObjectMapping *mapping1 = [RKObjectMapping mappingForClass:[HTHuman class]];
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping1 method:RKRequestMethodGET pathPattern:@"/JSON/humans/1.json" keyPath:@"human" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [manager addResponseDescriptor:responseDescriptor];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"/JSON/humans/1.json" relativeToURL:manager.baseURL]];
    request.ht_cachePolicy = HTCachePolicyCacheFirst;
    
    RKObjectRequestOperation *noCacheOperation = [manager objectRequestOperationWithRequest:request success:nil failure:nil];
    expect(noCacheOperation.HTTPRequestOperation).to.beKindOf([HTHTTPRequestOperation class]);
    [noCacheOperation start];
    [noCacheOperation waitUntilFinished];
    
    // When operation is started twice, response of the second one must come from cache.
    RKObjectRequestOperation *cachedOperation = [manager objectRequestOperationWithRequest:request success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        BOOL isResponseFromCache = operation.HTTPRequestOperation.response.ht_isFromCache;
        expect(isResponseFromCache).to.equal(YES);
        NSLog(@"mappingResult: %@", mappingResult);
        CFRunLoopRef runLoopRef = CFRunLoopGetCurrent();
        CFRunLoopStop(runLoopRef);
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"mappingError: %@", error);
        BOOL isResponseFromCache = operation.HTTPRequestOperation.response.ht_isFromCache;
        expect(isResponseFromCache).to.equal(YES);
        CFRunLoopRef runLoopRef = CFRunLoopGetCurrent();
        CFRunLoopStop(runLoopRef);
    }];
    expect(cachedOperation.HTTPRequestOperation).to.beKindOf([HTHTTPRequestOperation class]);
    
    [cachedOperation start];
    [cachedOperation waitUntilFinished];
    
    
    CFRunLoopRun();
}

- (void)testNoResponseFromCache {
    [[HTCacheManager sharedManager] removeAllCachedResponsesOnCompletion:^{
        NSString *url = @"http://localhost:4567";
        NSURL *baseUrl = [[NSURL alloc] initWithString:url];
        
        RKObjectManager *manager = [RKObjectManager managerWithBaseURL:baseUrl];
        [manager registerRequestOperationClass:[HTHTTPRequestOperation class]];
        
        RKObjectMapping *mapping1 = [RKObjectMapping mappingForClass:[HTHuman class]];
        RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping1 method:RKRequestMethodGET pathPattern:@"/JSON/humans/1.json" keyPath:@"human" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
        [manager addResponseDescriptor:responseDescriptor];
        
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"/JSON/humans/1.json" relativeToURL:manager.baseURL]];
        request.ht_cachePolicy = 1;
        
        RKObjectRequestOperation *operation = [manager objectRequestOperationWithRequest:request success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            BOOL isResponseFromCache = operation.HTTPRequestOperation.response.ht_isFromCache;
            expect(isResponseFromCache).to.equal(NO);
            NSLog(@"mappingResult: %@", mappingResult);
            CFRunLoopRef runLoopRef = CFRunLoopGetCurrent();
            CFRunLoopStop(runLoopRef);
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            NSLog(@"mappingError: %@", error);
            BOOL isResponseFromCache = operation.HTTPRequestOperation.response.ht_isFromCache;
            expect(isResponseFromCache).to.equal(NO);
            CFRunLoopRef runLoopRef = CFRunLoopGetCurrent();
            CFRunLoopStop(runLoopRef);
        }];
        expect(operation.HTTPRequestOperation).to.beKindOf([HTHTTPRequestOperation class]);
        
        [operation start];
        [operation waitUntilFinished];
    }];
    
    CFRunLoopRun();
}

- (void)testSetDefaultExpireTime {
    HTCacheManager *cacheManager = [HTCacheManager sharedManager];
    [cacheManager setDefaultExpireTime:10000];
    
    [cacheManager removeAllCachedResponsesOnCompletion:^{
        NSString *url = @"http://localhost:4567";
        NSURL *baseUrl = [[NSURL alloc] initWithString:url];
        
        RKObjectManager *manager = [RKObjectManager managerWithBaseURL:baseUrl];
        [manager registerRequestOperationClass:[HTHTTPRequestOperation class]];
        
        RKObjectMapping *mapping1 = [RKObjectMapping mappingForClass:[HTHuman class]];
        RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping1 method:RKRequestMethodGET pathPattern:@"/JSON/humans/1.json" keyPath:@"human" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
        [manager addResponseDescriptor:responseDescriptor];
        
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"/JSON/humans/1.json" relativeToURL:manager.baseURL]];
        request.ht_cachePolicy = 1;
        
        RKObjectRequestOperation *operation = [manager objectRequestOperationWithRequest:request success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            BOOL isResponseFromCache = operation.HTTPRequestOperation.response.ht_isFromCache;
            expect(isResponseFromCache).to.equal(NO);
            NSLog(@"mappingResult: %@", mappingResult);
            
            HTCachedResponse *response = [cacheManager cachedResponseForRequest:request];
            expect((long long)[response.expireDate timeIntervalSinceDate:response.createDate]).to.equal(10000);
            
            CFRunLoopRef runLoopRef = CFRunLoopGetCurrent();
            CFRunLoopStop(runLoopRef);
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            NSLog(@"mappingError: %@", error);
            BOOL isResponseFromCache = operation.HTTPRequestOperation.response.ht_isFromCache;
            expect(isResponseFromCache).to.equal(NO);
            CFRunLoopRef runLoopRef = CFRunLoopGetCurrent();
            CFRunLoopStop(runLoopRef);
        }];
        expect(operation.HTTPRequestOperation).to.beKindOf([HTHTTPRequestOperation class]);
        
        [operation start];
        [operation waitUntilFinished];
    }];
    
    CFRunLoopRun();
}

- (void)testCacheResponseMaxAge {
    HTCacheManager *cacheManager = [HTCacheManager sharedManager];
    [cacheManager setDefaultExpireTime:86400 * 10];
    [cacheManager setMaxCacheAge:86400 * 5];
    
    [cacheManager removeAllCachedResponsesOnCompletion:^{
        NSString *url = @"http://localhost:4567";
        NSURL *baseUrl = [[NSURL alloc] initWithString:url];
        
        RKObjectManager *manager = [RKObjectManager managerWithBaseURL:baseUrl];
        [manager registerRequestOperationClass:[HTHTTPRequestOperation class]];
        
        RKObjectMapping *mapping1 = [RKObjectMapping mappingForClass:[HTHuman class]];
        RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping1 method:RKRequestMethodGET pathPattern:@"/JSON/humans/1.json" keyPath:@"human" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
        [manager addResponseDescriptor:responseDescriptor];
        
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"/JSON/humans/1.json" relativeToURL:manager.baseURL]];
        request.ht_cachePolicy = HTCachePolicyCacheFirst;
        
        RKObjectRequestOperation *operation = [manager objectRequestOperationWithRequest:request success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            BOOL isResponseFromCache = operation.HTTPRequestOperation.response.ht_isFromCache;
            expect(isResponseFromCache).to.equal(NO);
            NSLog(@"mappingResult: %@", mappingResult);
            
            HTCachedResponse *response = [cacheManager cachedResponseForRequest:request];
            expect((long long)[response.expireDate timeIntervalSinceDate:response.createDate]).to.equal(86400 * 5);
            
            CFRunLoopRef runLoopRef = CFRunLoopGetCurrent();
            CFRunLoopStop(runLoopRef);
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            NSLog(@"mappingError: %@", error);
            BOOL isResponseFromCache = operation.HTTPRequestOperation.response.ht_isFromCache;
            expect(isResponseFromCache).to.equal(NO);
            CFRunLoopRef runLoopRef = CFRunLoopGetCurrent();
            CFRunLoopStop(runLoopRef);
        }];
        expect(operation.HTTPRequestOperation).to.beKindOf([HTHTTPRequestOperation class]);
        
        [operation start];
        [operation waitUntilFinished];
    }];
    
    CFRunLoopRun();
}

#pragma mark - Test Cache Manager

- (void)testMaxDiskCacheSize {
    HTCacheManager *cacheManager = [[HTCacheManager alloc] initWithDiskCapacity:2 * 1024 * 1024];
    [HTCacheManager setSharedManager:cacheManager];
    
    [cacheManager removeAllCachedResponsesOnCompletion:^{
        for (int i = 0; i < 1000; i++) {
            NSMutableString *urlString = [NSMutableString stringWithString:@"http://localhost:4567/cacheTest"];
            [urlString appendFormat:@"%@", @(i)];
            NSURL *cachedURL = [[NSURL alloc] initWithString:urlString];
            NSURLRequest *request = [[NSURLRequest alloc] initWithURL:cachedURL];
            const char *resonseContent = "testlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwangtestlwang";
            NSData *responseData = [[NSData alloc] initWithBytes:resonseContent length:strlen(resonseContent)];
            NSHTTPURLResponse *testResponse = [[NSHTTPURLResponse alloc] initWithURL:cachedURL statusCode:200 HTTPVersion:@"1.1" headerFields:@{@"testKey":@"testValue"}];
            NSCachedURLResponse *response = [[NSCachedURLResponse alloc] initWithResponse:testResponse data:responseData];
            
            NSDate *now = [NSDate date];
            HTCachedResponse *cachedResponse = [[HTCachedResponse alloc] init];
            cachedResponse.response = response;
            cachedResponse.createDate = now;
            cachedResponse.expireDate = [NSDate dateWithTimeInterval:86400 sinceDate:now];
            [[HTCacheManager sharedManager] storeCachedResponse:cachedResponse forRequest:request];
        }
        
        CFRunLoopRef runLoopRef = CFRunLoopGetCurrent();
        CFRunLoopStop(runLoopRef);
    }];
    
    CFRunLoopRun();
}

- (void)testReduceDiskCacheSize {
    NSUInteger curDiskCacheSize = [[HTCacheManager sharedManager] getCurCacheSize];
    [[HTCacheManager sharedManager] removeAllCachedResponsesOnCompletion:^{
        NSUInteger removedDiskCacheSize = [[HTCacheManager sharedManager] getCurCacheSize];
        // If there is nothing to remove, current disk cache size won't be reduct but it should be a very small value, less than 30 KB. (During test, it is 20 KB).
        expect(removedDiskCacheSize < curDiskCacheSize || (removedDiskCacheSize == curDiskCacheSize && removedDiskCacheSize < 30 * 1024)).to.equal(YES);
        
        CFRunLoopRef runLoopRef = CFRunLoopGetCurrent();
        CFRunLoopStop(runLoopRef);
    }];
    
    CFRunLoopRun();
}

- (void)testIfHasCacheForRequestAfterNoCacheRequest {
    // 测试: 如果请求没有被缓存，那么查询出来hasCacheForRequest一定是NO.
    HTCacheManager *cacheManager = [HTCacheManager sharedManager];
    [cacheManager setDefaultExpireTime:86400 * 10];
    [cacheManager setMaxCacheAge:86400 * 5];
    
    [cacheManager removeAllCachedResponsesOnCompletion:^{
        NSString *url = @"http://localhost:4567";
        NSURL *baseUrl = [[NSURL alloc] initWithString:url];
        
        RKObjectManager *manager = [RKObjectManager managerWithBaseURL:baseUrl];
        [manager registerRequestOperationClass:[HTHTTPRequestOperation class]];
        
        RKObjectMapping *mapping1 = [RKObjectMapping mappingForClass:[HTHuman class]];
        RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping1 method:RKRequestMethodGET pathPattern:@"/JSON/humans/1.json" keyPath:@"human" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
        [manager addResponseDescriptor:responseDescriptor];
        
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"/JSON/humans/1.json" relativeToURL:manager.baseURL]];
        BOOL hasCacheForRequest = [cacheManager hasCacheForRequest:request];
        expect(hasCacheForRequest).to.equal(NO);
        
        RKObjectRequestOperation *operation = [manager objectRequestOperationWithRequest:request success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            
            BOOL hasCacheForRequest = [cacheManager hasCacheForRequest:request];
            expect(hasCacheForRequest).to.equal(NO);
            expect([HTDefaultCachePolicy hasCacheForRequest:(HTHTTPRequestOperation *)operation.HTTPRequestOperation]).to.equal(NO);
            // Write Only只写不读.
            expect([HTWriteOnlyCachePolicy hasCacheForRequest:(HTHTTPRequestOperation *)operation.HTTPRequestOperation]).to.equal(NO);
            
            CFRunLoopRef runLoopRef = CFRunLoopGetCurrent();
            CFRunLoopStop(runLoopRef);
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            CFRunLoopRef runLoopRef = CFRunLoopGetCurrent();
            CFRunLoopStop(runLoopRef);
        }];
        expect(operation.HTTPRequestOperation).to.beKindOf([HTHTTPRequestOperation class]);
        
        [operation start];
        [operation waitUntilFinished];
    }];
    
    CFRunLoopRun();
}

- (void)testIfHasCacheForRequestAfterCacheFirstRequest {
    // 测试: 如果请求的Cache Id为HTCachePolicyCacheFirst，那么查询出来hasCacheForRequest一定是YES.
    HTCacheManager *cacheManager = [HTCacheManager sharedManager];
    [cacheManager setDefaultExpireTime:86400 * 10];
    [cacheManager setMaxCacheAge:86400 * 5];
    
    [cacheManager removeAllCachedResponsesOnCompletion:^{
        NSString *url = @"http://localhost:4567";
        NSURL *baseUrl = [[NSURL alloc] initWithString:url];
        
        RKObjectManager *manager = [RKObjectManager managerWithBaseURL:baseUrl];
        [manager registerRequestOperationClass:[HTHTTPRequestOperation class]];
        
        RKObjectMapping *mapping1 = [RKObjectMapping mappingForClass:[HTHuman class]];
        RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping1 method:RKRequestMethodGET pathPattern:@"/JSON/humans/1.json" keyPath:@"human" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
        [manager addResponseDescriptor:responseDescriptor];
        
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"/JSON/humans/1.json" relativeToURL:manager.baseURL]];
        request.ht_cachePolicy = HTCachePolicyCacheFirst;
        
        RKObjectRequestOperation *operation = [manager objectRequestOperationWithRequest:request success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            
            BOOL hasCacheForRequest = [cacheManager hasCacheForRequest:request];
            expect(hasCacheForRequest).to.equal(YES);
            expect([HTDefaultCachePolicy hasCacheForRequest:(HTHTTPRequestOperation *)operation.HTTPRequestOperation]).to.equal(YES);
            // Write Only只写不读.
            expect([HTWriteOnlyCachePolicy hasCacheForRequest:(HTHTTPRequestOperation *)operation.HTTPRequestOperation]).to.equal(NO);
            
            // HTCachePolicy只返回默认值.
            expect([HTCachePolicy hasCacheForRequest:(HTHTTPRequestOperation *)operation.HTTPRequestOperation]).to.equal(NO);
            expect([HTCachePolicy cachedResponseForRequest:(HTHTTPRequestOperation *)operation.HTTPRequestOperation]).to.equal(nil);
            
            CFRunLoopRef runLoopRef = CFRunLoopGetCurrent();
            CFRunLoopStop(runLoopRef);
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            CFRunLoopRef runLoopRef = CFRunLoopGetCurrent();
            CFRunLoopStop(runLoopRef);
        }];
        expect(operation.HTTPRequestOperation).to.beKindOf([HTHTTPRequestOperation class]);
        
        [operation start];
        [operation waitUntilFinished];
    }];
    
    CFRunLoopRun();
}

- (void)testIfHasCacheForRequestAfterWriteOnlyRequest {
    // 测试: 如果请求的Cache Id为HTCachePolicyWriteOnly，那么查询出来hasCacheForRequest一定是YES.
    HTCacheManager *cacheManager = [HTCacheManager sharedManager];
    [cacheManager setDefaultExpireTime:86400 * 10];
    [cacheManager setMaxCacheAge:86400 * 5];
    
    [cacheManager removeAllCachedResponsesOnCompletion:^{
        NSString *url = @"http://localhost:4567";
        NSURL *baseUrl = [[NSURL alloc] initWithString:url];
        
        RKObjectManager *manager = [RKObjectManager managerWithBaseURL:baseUrl];
        [manager registerRequestOperationClass:[HTHTTPRequestOperation class]];
        
        RKObjectMapping *mapping1 = [RKObjectMapping mappingForClass:[HTHuman class]];
        RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping1 method:RKRequestMethodGET pathPattern:@"/JSON/humans/1.json" keyPath:@"human" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
        [manager addResponseDescriptor:responseDescriptor];
        
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"/JSON/humans/1.json" relativeToURL:manager.baseURL]];
        request.ht_cachePolicy = HTCachePolicyWriteOnly;
        
        RKObjectRequestOperation *operation = [manager objectRequestOperationWithRequest:request success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            
            BOOL hasCacheForRequest = [cacheManager hasCacheForRequest:request];
            expect(hasCacheForRequest).to.equal(YES);
            expect([HTDefaultCachePolicy hasCacheForRequest:(HTHTTPRequestOperation *)operation.HTTPRequestOperation]).to.equal(YES);
            // Write Only只写不读.
            expect([HTWriteOnlyCachePolicy hasCacheForRequest:(HTHTTPRequestOperation *)operation.HTTPRequestOperation]).to.equal(NO);
            
            CFRunLoopRef runLoopRef = CFRunLoopGetCurrent();
            CFRunLoopStop(runLoopRef);
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            CFRunLoopRef runLoopRef = CFRunLoopGetCurrent();
            CFRunLoopStop(runLoopRef);
        }];
        expect(operation.HTTPRequestOperation).to.beKindOf([HTHTTPRequestOperation class]);
        
        [operation start];
        [operation waitUntilFinished];
    }];
    
    CFRunLoopRun();
}

- (void)testRemoveCachedResponseForRequest {
    // 测试对单个Request删除Cached Response.
    HTCacheManager *cacheManager = [HTCacheManager sharedManager];
    [cacheManager setDefaultExpireTime:86400 * 10];
    [cacheManager setMaxCacheAge:86400 * 5];
    
    [cacheManager removeAllCachedResponsesOnCompletion:^{
        NSString *url = @"http://localhost:4567";
        NSURL *baseUrl = [[NSURL alloc] initWithString:url];
        
        RKObjectManager *manager = [RKObjectManager managerWithBaseURL:baseUrl];
        [manager registerRequestOperationClass:[HTHTTPRequestOperation class]];
        
        RKObjectMapping *mapping1 = [RKObjectMapping mappingForClass:[HTHuman class]];
        RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping1 method:RKRequestMethodGET pathPattern:@"/JSON/humans/1.json" keyPath:@"human" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
        [manager addResponseDescriptor:responseDescriptor];
        
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"/JSON/humans/1.json" relativeToURL:manager.baseURL]];
        request.ht_cachePolicy = HTCachePolicyWriteOnly;
        
        RKObjectRequestOperation *operation = [manager objectRequestOperationWithRequest:request success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            
            BOOL hasCacheForRequest = [cacheManager hasCacheForRequest:request];
            expect(hasCacheForRequest).to.equal(YES);
            
            [cacheManager removeCachedResponseForRequest:request completion:^{
                // 删除后不再能查询到cached response.
                expect([cacheManager hasCacheForRequest:request]).to.equal(NO);
            }];
            
            
            CFRunLoopRef runLoopRef = CFRunLoopGetCurrent();
            CFRunLoopStop(runLoopRef);
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            CFRunLoopRef runLoopRef = CFRunLoopGetCurrent();
            CFRunLoopStop(runLoopRef);
        }];
        expect(operation.HTTPRequestOperation).to.beKindOf([HTHTTPRequestOperation class]);
        
        [operation start];
        [operation waitUntilFinished];
    }];
    
    CFRunLoopRun();
}

- (void)testCacheManagerCapacity {
    HTCacheManager *cacheManager = [HTCacheManager sharedManager];
    [cacheManager setDefaultExpireTime:86400 * 10];
    [cacheManager setMaxCacheAge:86400 * 5];
    cacheManager.memoryCacheCountLimit = 100;
    cacheManager.memoryCacheCapacity = 10 * 1024 * 1024;
    expect(cacheManager.memoryCacheCapacity == 10 * 1024 * 1024).to.equal(YES);
    expect(cacheManager.memoryCacheCountLimit == 100).to.equal(YES);
}

- (void)testRemoveResponsesByDate {
    HTCacheManager *cacheManager = [HTCacheManager sharedManager];
    [cacheManager setDefaultExpireTime:86400 * 10];
    [cacheManager setMaxCacheAge:86400 * 5];
    [cacheManager removeCachedResponsesSinceDate:[NSDate dateWithTimeIntervalSinceNow:-(86400 * 365)] completion:^{
        NSString *url = @"http://localhost:4567";
        NSURL *baseUrl = [[NSURL alloc] initWithString:url];
        
        RKObjectManager *manager = [RKObjectManager managerWithBaseURL:baseUrl];
        [manager registerRequestOperationClass:[HTHTTPRequestOperation class]];
        
        RKObjectMapping *mapping1 = [RKObjectMapping mappingForClass:[HTHuman class]];
        RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping1 method:RKRequestMethodGET pathPattern:@"/JSON/humans/1.json" keyPath:@"human" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
        [manager addResponseDescriptor:responseDescriptor];

        // TODO: HTCacheManager并不提供查询多少请求的接口，所以只能通过下面这种方式验证整个流程是通的以及代码没有Crash等严重问题.
        // removeAllExpiredResponse未对外开放，暂不需测试.
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"/JSON/humans/1.json" relativeToURL:manager.baseURL]];
        BOOL hasCacheForRequest = [cacheManager hasCacheForRequest:request];
        expect(hasCacheForRequest).to.equal(NO);
    }];
}

- (void)testCachePolicyManager {
    HTCachePolicyManager *policyManager = [HTCachePolicyManager sharedInstance];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.163.com"]];
    request.ht_cachePolicy = HTCachePolicyCacheFirst;
    HTHTTPRequestOperation *operation = [[HTHTTPRequestOperation alloc] initWithRequest:request];
    Class<HTCachePolicyProtocol> policyClass = [policyManager cachePolicyClassForRequest:operation];
    expect(policyClass).notTo.equal(nil);
    [policyManager removeCachePolicy:HTCachePolicyCacheFirst];
    policyClass = [policyManager cachePolicyClassForRequest:operation];
    expect(policyClass).to.equal(nil);

    request.ht_cachePolicy = HTCachePolicyWriteOnly;
    policyClass = [policyManager cachePolicyClassForRequest:operation];
    expect(policyClass).notTo.equal(nil);
    [policyManager removeCahcePolicyClass:policyClass];
    policyClass = [policyManager cachePolicyClassForRequest:operation];
    expect(policyClass).to.equal(nil);
}

@end
