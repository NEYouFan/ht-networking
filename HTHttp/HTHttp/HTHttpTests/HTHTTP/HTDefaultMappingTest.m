//
//  HTDefaultMappingTest.m
//  HTHttp
//
//  Created by Wangliping on 16/1/4.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "HTHttpTest.h"
#import "HTRuntimeHelper.h"
#import "HTPhotoInfo.h"
#import "NSObject+HTMapping.h"
#import "NSObject+HTModel.h"
#import "HTArticle.h"
#import "HTAuthor.h"
#import "HTFamousAuthor.h"
#import "HTReader.h"

@interface HTDefaultMappingTest : XCTestCase

@end

@implementation HTDefaultMappingTest

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

- (void)testPropertyListWithHTRuntimeHelper {
    NSArray *propertyList = [HTPhotoInfo propertyList];
    NSArray *runtimeHelperPropertyList = [HTRuntimeHelper getPropertyList:[HTPhotoInfo class]];
    expect([propertyList isEqualToArray:runtimeHelperPropertyList]).to.equal(YES);
}

// 测试对于没有自定义Property的Model Mapping是否正确.
- (void)testModelMappingForClassWithoutCustomProperty {
    // HTPhotoInfo中仅有基本类型，无数组.
    {
        RKMapping *mapping = [HTPhotoInfo ht_modelMapping];
        RKMapping *manuallyMapping = [HTPhotoInfo manuallyMapping];
        expect(mapping).to.beKindOf([RKObjectMapping class]);
        expect([mapping isEqualToMapping:manuallyMapping]).to.equal(YES);
    }
    
    {
        RKMapping *mapping = [HTArticle ht_modelMapping];
        RKMapping *manuallyMapping = [HTArticle manuallyMapping];
        expect(mapping).to.beKindOf([RKObjectMapping class]);
        expect([mapping isEqualToMapping:manuallyMapping]).to.equal(YES);
    }
}

// 测试对于自定义Property的Model Mapping是否正确.
- (void)testModelMappingForClassWithCustomProperty {
    {
        RKMapping *mapping = [HTAuthor ht_modelMapping];
        RKMapping *manuallyMapping = [HTAuthor manuallyMapping];
        expect(mapping).to.beKindOf([RKObjectMapping class]);
        expect([mapping isEqualToMapping:manuallyMapping]).to.equal(YES);
    }
    
    {
        RKMapping *mapping = [HTFamousAuthor ht_modelMapping];
        RKMapping *manuallyMapping = [HTFamousAuthor manuallyMapping];
        expect(mapping).to.beKindOf([RKObjectMapping class]);
        expect([mapping isEqualToMapping:manuallyMapping]).to.equal(YES);
    }
}

// 测试对于自定义Property的Model Mapping是否正确.
- (void)testModelMappingForClassWithCustomArrayProperty {
    {
        RKMapping *mapping = [HTReader ht_modelMapping];
        RKMapping *manuallyMapping = [HTReader manuallyMapping];
        expect(mapping).to.beKindOf([RKObjectMapping class]);
        expect([mapping isEqualToMapping:manuallyMapping]).to.equal(YES);
    }
}

// 测试指定了排除属性是否正确
- (void)testModelMappingWithBlackPropertyList {
    {
        RKMapping *mapping = [HTReader ht_modelMappingWithBlackList:@[@"name"]];
        RKMapping *manuallyMapping = [HTReader manuallyMappingWithBlackPropertyList:@[@"name"]];
        expect(mapping).to.beKindOf([RKObjectMapping class]);
        expect([mapping isEqualToMapping:manuallyMapping]).to.equal(YES);
    }
    
    {
        RKMapping *mapping = [HTReader ht_modelMappingWithBlackList:@[@"articles"]];
        RKMapping *manuallyMapping = [HTReader manuallyMappingWithBlackPropertyList:@[@"articles"]];
        expect(mapping).to.beKindOf([RKObjectMapping class]);
        expect([mapping isEqualToMapping:manuallyMapping]).to.equal(YES);
    }
}

- (void)testPropertyList {
    NSDictionary *propertyDic = [HTFamousAuthor ht_propertyInfoDic];
    NSDictionary *allPropertyDic = [HTFamousAuthor ht_allPropertyInfoDic];
    expect([propertyDic isEqualToDictionary:[HTFamousAuthor manualPropertyDic]]).to.equal(YES);
    expect([allPropertyDic isEqualToDictionary:[HTFamousAuthor manualAllPropertyDic]]).to.equal(YES);
}

@end
