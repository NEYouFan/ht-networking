//
//  HTSendRKRequestTest.m
//  HTHttp
//
//  Created by Wangliping on 16/1/5.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "HTHttpTest.h"
#import "HTUserInfo.h"

/**
 *  直接使用RestKit的接口来发送请求. 一般不需要添加一般的测试请求，因为RestKit中已经包含了相应的单元测试case.
 */
@interface HTSendRKRequestTest : XCTestCase

@end

@implementation HTSendRKRequestTest

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
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

- (void)testSendRKRequest {
    RKMapping *mapping = [HTUserInfo manuallyMapping];
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping method:RKRequestMethodGET pathPattern:@"/user" keyPath:@"data" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    // 创建RKObjectManager对象.
    RKObjectManager *manager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:@"http://localhost:3000"]];
    
    // 添加ResponseDescriptor.
    [manager addResponseDescriptor:responseDescriptor];
    
    // 注册对@"text/plain"的解析. 如果MIMEType本身就是RKMIMETypeJSON，那么不需要额外注册解析类.
    [RKMIMETypeSerialization registerClass:[RKNSJSONSerialization class] forMIMEType:@"text/plain"];
    
    // 发请求获取数据并输出结果.
    // 本例中不需要任何参数，如果需要传递参数，则指定parameters参数即可.
    // getObject参数一般传nil, 仅当通过RKRequestDescriptor描述请求参数时才需要赋值，可以参见后续的例子或者RestKit的Demo.
    [manager getObject:nil path:@"/user" parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        HTUserInfo *userInfo = [mappingResult.dictionary objectForKey:@"data"];
        expect([userInfo isKindOfClass:[HTUserInfo class]]).to.equal(YES);
        expect([userInfo.name length] > 0).to.equal(YES);
        
        CFRunLoopRef runLoopRef = CFRunLoopGetCurrent();
        CFRunLoopStop(runLoopRef);
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        expect(nil == error).to.equal(YES);
        
        CFRunLoopRef runLoopRef = CFRunLoopGetCurrent();
        CFRunLoopStop(runLoopRef);
    }];
    
    CFRunLoopRun();
}

@end
