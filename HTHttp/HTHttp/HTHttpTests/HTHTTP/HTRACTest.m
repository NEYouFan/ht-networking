//
//  HTRACTest.m
//  HTHttp
//
//  Created by Wang Liping on 15/9/8.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "RKObjectManager+HTRAC.h"
#import "RKObjectRequestOperation+HTRAC.h"
#import "HTHttpTest.h"
#import "HTTestUser.h"
#import "HTPhotoInfo.h"
#import "HTOperationHelper.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface HTRACTest : XCTestCase

@end

@implementation HTRACTest

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

#pragma mark - Operaions

- (RKObjectManager *)managerForTestingRAC {
    // 初始化RKObjectManager.
    RKObjectManager *manager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:@"http://localhost:3000"]];
    
    // 添加ResponseDescriptor.
    // UserInfo
    {
        RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[HTTestUser class]];
        [mapping addAttributeMappingsFromArray:@[@"userId", @"balance"]];
        [mapping addAttributeMappingsFromDictionary:@{@"version":@"name", @"status":@"password"}];
        
        RKResponseDescriptor *responseDescriptor1 = [RKResponseDescriptor responseDescriptorWithMapping:mapping method:RKRequestMethodGET pathPattern:@"/user" keyPath:@"data" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
        
        [manager addResponseDescriptor:responseDescriptor1];
    }
    
    // Get Photo List with User Info
    {
        RKMapping *mapping = [HTPhotoInfo manuallyMapping];
        RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping method:RKRequestMethodAny pathPattern:@"/collection" keyPath:@"photolist" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
        [manager addResponseDescriptor:responseDescriptor];
    }
    
    // Get Photo List
    {
        RKMapping *mapping = [HTPhotoInfo manuallyMapping];
        RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping method:RKRequestMethodAny pathPattern:@"/photolist" keyPath:@"photolist" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
        [manager addResponseDescriptor:responseDescriptor];
    }
    
    // ErrorMsg
    {
        RKObjectMapping *errorMapping = [RKObjectMapping mappingForClass:[RKErrorMessage class]];
        [errorMapping addPropertyMapping:[RKAttributeMapping attributeMappingFromKeyPath:nil toKeyPath:@"errorMessage"]];
        RKResponseDescriptor *errorResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:errorMapping method:RKRequestMethodGET pathPattern:nil keyPath:@"code" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassClientError)];
        [manager addResponseDescriptor:errorResponseDescriptor];
    }

    return manager;
}

- (RKObjectRequestOperation *)getUserInfoOperationWith:(RKObjectManager *)objectMananger {
    NSURLRequest *request = [objectMananger requestWithObject:nil method:RKRequestMethodGET path:@"/user" parameters:nil];
    return [self operationWithRequest:request withMananger:objectMananger];
}

- (RKObjectRequestOperation *)getPhotoListInfoOperationWith:(RKObjectManager *)objectMananger {
    NSURLRequest *request = [objectMananger requestWithObject:nil method:RKRequestMethodGET path:@"/photolist?limit=20&offset=0" parameters:nil];
    return [self operationWithRequest:request withMananger:objectMananger];
}

- (RKObjectRequestOperation *)getUserPhotoListInfoOperationWith:(RKObjectManager *)objectMananger  {
    NSDictionary *parameters = @{@"name":@"lwang", @"password":@"test", @"type":@"photolist"};
    NSURLRequest *request = [objectMananger requestWithObject:nil method:RKRequestMethodPOST path:@"/collection" parameters:parameters];
    return [self operationWithRequest:request withMananger:objectMananger];
}

- (RKObjectRequestOperation *)operationWithRequest:(NSURLRequest *)request withMananger:(RKObjectManager *)objectManager {
    RKObjectRequestOperation *operation = [objectManager objectRequestOperationWithRequest:request success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        expect([mappingResult count] > 0).to.equal(YES);
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        // If any error happens then this test case failed.
        expect(error).to.equal(nil);
    }];
    
    return operation;
}

#pragma mark - Test Methods

- (void)testBasicSignalsOfRKObjectMananger {
    NSString *url = @"http://localhost:4567";
    NSURL *baseUrl = [[NSURL alloc] initWithString:url];
    NSString *getPath1 = @"/user";
    NSString *getPath2 = @"/users";
    
    RKObjectManager *manager = [RKObjectManager managerWithBaseURL:baseUrl];
    RACSignal *signal1 = [manager rac_getObject:nil path:getPath1 parameters:nil];
    
    RACSignal *signal2 = [manager rac_getObjectsAtPath:getPath2 parameters:nil];
    
    NSMutableArray *signalList = [NSMutableArray arrayWithObjects:signal1, signal2, nil];
    RACSignal *mergedSignal = [RACSignal merge:signalList];
    [mergedSignal subscribeNext:^(id x) {
        expect([x isKindOfClass:[RKObjectRequestOperation class]]).to.equal(YES);
    } error:^(NSError *error) {
        // If any error happens then this test case failed.
        expect(error).to.equal(nil);
        
        CFRunLoopRef runLoopRef = CFRunLoopGetCurrent();
        CFRunLoopStop(runLoopRef);
    } completed:^{
        CFRunLoopRef runLoopRef = CFRunLoopGetCurrent();
        CFRunLoopStop(runLoopRef);
    }];
    
    CFRunLoopRun();
}

- (void)testBasicSignalsOfRKObjectRequestOperation {
    NSString *url = @"http://localhost:4567";
    NSURL *baseUrl = [[NSURL alloc] initWithString:url];
    NSString *getPath1 = @"/user";
    RKObjectManager *manager = [RKObjectManager managerWithBaseURL:baseUrl];
    NSURLRequest *request = [manager requestWithObject:nil method:RKRequestMethodGET path:getPath1 parameters:nil];
    RKObjectRequestOperation *operation = [[RKObjectRequestOperation alloc] initWithRequest:request responseDescriptors:manager.responseDescriptors];
    void (^originalSuccess)(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) = ^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        NSLog(@"originalSuccess");
        
        CFRunLoopRef runLoopRef = CFRunLoopGetCurrent();
        CFRunLoopStop(runLoopRef);
    };
    
    void (^originalFailure)(RKObjectRequestOperation *operation, NSError *error) = ^(RKObjectRequestOperation *operation, NSError *error) {
        // If any error happens then this test case failed.
        expect(error).to.equal(nil);
        
        CFRunLoopRef runLoopRef = CFRunLoopGetCurrent();
        CFRunLoopStop(runLoopRef);
    };
    
    [operation setCompletionBlockWithSuccess:originalSuccess failure:originalFailure];
    
    RACSignal *signal = [operation rac_enqueueInManager:manager];
    [signal subscribeNext:^(id x) {
        expect([x isKindOfClass:[RKObjectRequestOperation class]]).to.equal(YES);
    } error:^(NSError *error) {
        // If any error happens then this test case failed.
        expect(error).to.equal(nil);
    } completed:^{
        NSLog(@"%@", @"completed");
    }];
    
    [signal subscribeNext:^(id x) {
        expect([x isKindOfClass:[RKObjectRequestOperation class]]).to.equal(YES);
    } error:^(NSError *error) {
        // If any error happens then this test case failed.
        expect(error).to.equal(nil);
    } completed:^{
        NSLog(@"%@3", @"completed");
    }];
    
    [signal subscribeNext:^(id x) {
        expect([x isKindOfClass:[RKObjectRequestOperation class]]).to.equal(YES);
    } error:^(NSError *error) {
        // If any error happens then this test case failed.
        expect(error).to.equal(nil);
    } completed:^{
        NSLog(@"%@33", @"completed");
    }];
    
    CFRunLoopRun();
}

- (void)testRKObjectRequestOperatonSignalSubsribeMultiTimes {
    RKObjectManager *manager = [self managerForTestingRAC];
    NSString *getPath = @"/user";
    NSURLRequest *request = [manager requestWithObject:nil method:RKRequestMethodGET path:getPath parameters:nil];
    
    RKObjectRequestOperation *operation = [[RKObjectRequestOperation alloc] initWithRequest:request responseDescriptors:manager.responseDescriptors];
    void (^originalSuccess)(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) = ^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        NSLog(@"originalSuccess, original Maping Result: %@", mappingResult);
        CFRunLoopRef runLoopRef = CFRunLoopGetCurrent();
        CFRunLoopStop(runLoopRef);
    };
    
    void (^originalFailure)(RKObjectRequestOperation *operation, NSError *error) = ^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"originalFailure");
        CFRunLoopRef runLoopRef = CFRunLoopGetCurrent();
        CFRunLoopStop(runLoopRef);
    };
    
    [operation setCompletionBlockWithSuccess:originalSuccess failure:originalFailure];
    
    RACSignal *signal = [operation rac_enqueueInManager:manager];
    for (int i = 100; i < 150; i ++) {
        [signal subscribeNext:^(id x) {
            expect([x isKindOfClass:[RKObjectRequestOperation class]]).to.equal(YES);
            if ([x isKindOfClass:[RKObjectRequestOperation class]]) {
                RKObjectRequestOperation *operation = x;
                NSLog(@"Mapping Result %d : %@", i, operation.mappingResult);
            }
        } error:^(NSError *error) {
            // If any error happens then this test case failed.
            expect(error).to.equal(nil);
        } completed:^{
            NSLog(@"%@ %d", @"completed", i);
        }];
    }
    
    for (int i = 100; i < 150; i ++) {
        RACSignal *anotherSignal = [operation rac_enqueueInManager:manager];
        [anotherSignal subscribeNext:^(id x) {
            expect([x isKindOfClass:[RKObjectRequestOperation class]]).to.equal(YES);
            if ([x isKindOfClass:[RKObjectRequestOperation class]]) {
                RKObjectRequestOperation *operation = x;
                NSLog(@"anotherSignal Mapping Result %d : %@", i, operation.mappingResult);
            }
        } error:^(NSError *error) {
            // If any error happens then this test case failed.
            expect(error).to.equal(nil);
        } completed:^{
            NSLog(@"%@ anotherSignal i", @"completed");
        }];
    }
    
    CFRunLoopRun();
}

- (void)testBatchSignals {
    RKObjectManager *testMananger = [self managerForTestingRAC];
    
    NSMutableArray *batchedOperations = [NSMutableArray array];
    for (int i = 0; i < 3; i ++) {
        [batchedOperations addObject:[self getUserInfoOperationWith:testMananger]];
    }
    
    for (int i = 0; i < 3; i ++) {
        [batchedOperations addObject:[self getPhotoListInfoOperationWith:testMananger]];
    }
    
    for (int i = 0; i < 3; i ++) {
        [batchedOperations addObject:[self getUserPhotoListInfoOperationWith:testMananger]];
    }
    
    RACSignal *batchedSignal = [HTOperationHelper batchedSignalWith:batchedOperations inManager:testMananger];
    [batchedSignal subscribeNext:^(id x) {
        expect([x isKindOfClass:[RKObjectRequestOperation class]]).to.equal(YES);
    } error:^(NSError *error) {
        // If any error happens then this test case failed.
        expect(error).to.equal(nil);
        
        CFRunLoopRef runLoopRef = CFRunLoopGetCurrent();
        CFRunLoopStop(runLoopRef);
    } completed:^{
        CFRunLoopRef runLoopRef = CFRunLoopGetCurrent();
        CFRunLoopStop(runLoopRef);
    }];
    
    CFRunLoopRun();
}

- (void)testIfOperationAScucessfulThenBElseC {
    RKObjectManager *manager = [self managerForTestingRAC];
    
    RKObjectRequestOperation *operationA = [self getUserInfoOperationWith:manager];
    RKObjectRequestOperation *operationB = [self getUserPhotoListInfoOperationWith:manager];
    RKObjectRequestOperation *operationC = [self getPhotoListInfoOperationWith:manager];
    RACSignal *signal = [HTOperationHelper if:operationA then:operationB else:operationC inManager:manager validResultBlock:nil];
    [signal subscribeNext:^(id x) {
        expect([x isKindOfClass:[RKObjectRequestOperation class]]).to.equal(YES);
    } error:^(NSError *error) {
        // If any error happens then this test case failed.
        expect(error).to.equal(nil);
        
        CFRunLoopRef runLoopRef = CFRunLoopGetCurrent();
        CFRunLoopStop(runLoopRef);
    } completed:^{
        CFRunLoopRef runLoopRef = CFRunLoopGetCurrent();
        CFRunLoopStop(runLoopRef);
    }];
    
    CFRunLoopRun();
}

@end
