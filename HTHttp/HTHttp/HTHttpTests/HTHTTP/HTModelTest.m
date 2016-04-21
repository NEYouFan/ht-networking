//
//  HTModelTest.m
//  HTHttp
//
//  Created by Wangliping on 16/1/4.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "HTHttpTest.h"
#import "NSObject+HTModel.h"
#import "HTTestModel.h"
#import "HTTestModelArchive.h"
#import "HTAddress.h"
#import "NSArray+HTModel.h"
#import "NSDictionary+HTModel.h"

@interface HTModelTest : XCTestCase

@end

@implementation HTModelTest

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

// 测试普通的Model对象.
- (void)testNormalModel {
    HTTestModel *model = [[HTTestModel alloc] init];
    {
        model.name = @"lwangTest";
        NSDictionary *dic = [model ht_modelToJSONObject];
        expect([[dic objectForKey:@"name"] isEqualToString:@"lwangTest"]).to.equal(YES);
        NSString *string = [model ht_modelToJSONString];
        expect([string rangeOfString:@"lwangTest"].length > 0).to.equal(YES);
        
        HTTestModel *convertedModel = [HTTestModel ht_modelWithJSON:dic];
        expect([model isEqual:convertedModel]).to.equal(YES);
    }
    
    {
        model.count = 5;
        NSDictionary *dic = [model ht_modelToJSONObject];
        expect([[dic objectForKey:@"count"] isEqual:@(5)]).to.equal(YES);
        NSString *string = [model ht_modelToJSONString];
        expect([string rangeOfString:@"5"].length > 0).to.equal(YES);
        
        HTTestModel *convertedModel = [HTTestModel ht_modelWithJSON:dic];
        expect([model isEqual:convertedModel]).to.equal(YES);
    }
    
    {
        HTAddress *simpleAddress = [[HTAddress alloc] init];
        simpleAddress.province = @"湖北";
        simpleAddress.city = @"公安县";
        model.simpleAddress = simpleAddress;
        
        NSDictionary *dic = [model ht_modelToJSONObject];
        expect([dic objectForKey:@"simpleAddress"] != nil).to.equal(YES);
        NSString *string = [model ht_modelToJSONString];
        expect([string rangeOfString:@"湖北"].length > 0).to.equal(YES);
        
        HTTestModel *convertedModel = [HTTestModel ht_modelWithJSON:dic];
        expect([model isEqual:convertedModel]).to.equal(YES);
    }
    
    {
        model.comments = @[@"评论", @"好职位", @"非常好"];
        NSDictionary *dic = [model ht_modelToJSONObject];
        expect([dic objectForKey:@"comments"] != nil).to.equal(YES);
        NSString *string = [model ht_modelToJSONString];
        expect([string rangeOfString:@"非常好"].length > 0).to.equal(YES);
        
        HTTestModel *convertedModel = [HTTestModel ht_modelWithJSON:dic];
        expect([model isEqual:convertedModel]).to.equal(YES);
    }
    
    {
        model.isSpecial = YES;
        NSDictionary *dic = [model ht_modelToJSONObject];
        NSObject *isSpecial = [dic objectForKey:@"isSpecial"];
        expect([isSpecial isEqual:@(YES)]).to.equal(YES);
        
        HTTestModel *convertedModel = [HTTestModel ht_modelWithJSON:dic];
        expect(convertedModel.isSpecial).to.equal(YES);
        expect([model isEqual:convertedModel]).to.equal(YES);
    }
    
    {
        NSInteger value = 1024;
        model.data = [NSData dataWithBytes:&value length:sizeof(NSInteger)];
        NSDictionary *dic = [model ht_modelToJSONObject];
        HTTestModel *convertedModel = [HTTestModel ht_modelWithJSON:dic];
#warning NSData默认情况下无法正确转换.
        convertedModel.data = model.data;
        expect([model isEqual:convertedModel]).to.equal(YES);
    }
    
    {
        NSMutableArray *array = [NSMutableArray array];
        HTAddress *simpleAddress = [[HTAddress alloc] init];
        simpleAddress.province = @"湖北";
        simpleAddress.city = @"荆州";
        NSData *addressData = [simpleAddress.province dataUsingEncoding:NSUTF8StringEncoding];
        [array addObject:addressData];
        
        simpleAddress = [[HTAddress alloc] init];
        simpleAddress.province = @"浙江";
        simpleAddress.city = @"杭州";
        addressData = [simpleAddress.province dataUsingEncoding:NSUTF8StringEncoding];
        [array addObject:addressData];
        
        model.commentData = array;
        
        NSDictionary *dic = [model ht_modelToJSONObject];
        expect([[dic objectForKey:@"commentData"] isKindOfClass:[NSArray class]]).to.equal(YES);
        NSString *string = [model ht_modelToJSONString];
        // 包含NSData则无法转字符串.
        expect(string).to.equal(nil);
        
        HTTestModel *convertedModel = [HTTestModel ht_modelWithJSON:dic];
        convertedModel.data = model.data;
        convertedModel.commentData = model.commentData;
        expect([model isEqual:convertedModel]).to.equal(YES);
    }
    
    {
        // TODO: 含有NSURL不可以转成JSON字符串.
        model.url = [NSURL URLWithString:@"http://www.163.com"];
        NSDictionary *dic = [model ht_modelToJSONObject];
        expect(nil != [dic objectForKey:@"url"]).to.equal(YES);
        
        HTTestModel *convertedModel = [HTTestModel ht_modelWithJSON:dic];
        HTTestModel *convertedModelFromDic = [HTTestModel ht_modelWithDictionary:dic];
        expect([convertedModel isEqual:convertedModelFromDic]).to.equal(YES);
        
#warning NSURL默认情况下无法正确转换.
        convertedModel.url = model.url;
        convertedModel.data = model.data;
        convertedModel.commentData = model.commentData;
        expect([model isEqual:convertedModel]).to.equal(YES);
    }
    
    {
        // Copy
        HTTestModel *copidedModel = [model ht_modelCopy];
        expect([copidedModel isEqual:model]).to.equal(YES);
    }
}

- (void)testArchiveModel {
    HTTestModelArchive *model = [[HTTestModelArchive alloc] init];
    model.name = @"lwangTest";
    model.count = 5;
    model.comments = @[@"评论", @"好职位", @"非常好"];
    model.isSpecial = YES;
    
    NSInteger value = 1024;
    model.data = [NSData dataWithBytes:&value length:sizeof(NSInteger)];

    NSMutableArray *array = [NSMutableArray array];
    HTAddress *simpleAddress = [[HTAddress alloc] init];
    simpleAddress.province = @"湖北";
    simpleAddress.city = @"荆州";
    NSData *addressData = [simpleAddress.province dataUsingEncoding:NSUTF8StringEncoding];
    [array addObject:addressData];
    simpleAddress = [[HTAddress alloc] init];
    simpleAddress.province = @"浙江";
    simpleAddress.city = @"杭州";
    addressData = [simpleAddress.province dataUsingEncoding:NSUTF8StringEncoding];
    [array addObject:addressData];
    model.commentData = array;

    model.url = [NSURL URLWithString:@"http://www.163.com"];
    
    // Archive
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:model];
    HTTestModel *decodeObject = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    expect([decodeObject isEqual:model]).to.equal(YES);
}

#pragma mark - Test Nested With Model Collection such as NSArray<HTHTTPAddress *> *addressList;

- (void)testModel2JsonWithNestedModelCollection {
    
}

- (void)testModelCopyWithNestedModelCollection {
    
}

#pragma mark -

- (void)testNestedModel {
    
}

- (void)testArchiveNestedModel {
    
}

- (void)testHTModelProtocol {
    
}

- (void)testModelArray {
    NSMutableArray *arrayJson = [NSMutableArray array];
    NSMutableArray *modelArray = [NSMutableArray array];
    for (int i = 1; i < 5; i ++) {
        HTTestModelArchive *model = [[HTTestModelArchive alloc] init];
        model.name = [NSString stringWithFormat:@"lwangName: %@", @(i)];
        model.count = i;
        model.comments = @[@"评论", @"好职位", @"非常好"];
        model.isSpecial = YES;
        // TODO 写入文档: NSData在转换为JSON时默认会丢失.
        model.url = [NSURL URLWithString:@"http://www.163.com"];
        
        NSObject *json = [model ht_modelToJSONObject];
        expect(json).notTo.equal(nil);
        if (nil != json) {
            [arrayJson addObject:json];
        }
        
        [modelArray addObject:model];
    }
    
    NSArray *arrayFromJson = [NSArray ht_modelArrayWithClass:[HTTestModelArchive class] json:arrayJson];
    expect([modelArray isEqualToArray:arrayFromJson]).to.equal(YES);
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:arrayJson options:NSJSONWritingPrettyPrinted error:nil];
    arrayFromJson = [NSArray ht_modelArrayWithClass:[HTTestModelArchive class] json:data];
    expect([modelArray isEqualToArray:arrayFromJson]).to.equal(YES);
    
    NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    arrayFromJson = [NSArray ht_modelArrayWithClass:[HTTestModelArchive class] json:jsonString];
    expect([modelArray isEqualToArray:arrayFromJson]).to.equal(YES);
}

- (void)testModelDic {
    NSMutableDictionary *dicJson = [NSMutableDictionary dictionary];
    NSMutableDictionary *modelDic = [NSMutableDictionary dictionary];
    for (int i = 1; i < 5; i ++) {
        HTTestModelArchive *model = [[HTTestModelArchive alloc] init];
        model.name = [NSString stringWithFormat:@"lwangName: %@", @(i)];
        model.count = i;
        model.comments = @[@"评论", @"好职位", @"非常好"];
        model.isSpecial = YES;
        // TODO 写入文档: NSData在转换为JSON时默认会丢失.
        model.url = [NSURL URLWithString:@"http://www.163.com"];
        
        dicJson[model.name] = [model ht_modelToJSONObject];
        modelDic[model.name] = model;
    }
    
    NSDictionary *dicFromJason = [NSDictionary ht_modelDictionaryWithClass:[HTTestModelArchive class] json:dicJson];
    expect([modelDic isEqualToDictionary:dicFromJason]).to.equal(YES);
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:dicJson options:NSJSONWritingPrettyPrinted error:nil];
    dicFromJason = [NSDictionary ht_modelDictionaryWithClass:[HTTestModelArchive class] json:data];
    expect([modelDic isEqualToDictionary:dicFromJason]).to.equal(YES);
    
    NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    dicFromJason = [NSDictionary ht_modelDictionaryWithClass:[HTTestModelArchive class] json:jsonString];
    expect([modelDic isEqualToDictionary:dicFromJason]).to.equal(YES);
}

@end
