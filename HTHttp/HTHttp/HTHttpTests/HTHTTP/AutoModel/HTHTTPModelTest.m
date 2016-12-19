//
//  HTHTTPModelTest.m
//  HTHttp
//
//  Created by Wangliping on 16/1/5.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "HTHttpTest.h"
#import "HTHTTPTestModel.h"
#import "HTHTTPTestCollectionModel.h"
#import "HTHTTPPhotoInfo.h"
#import "HTHTTPAddress.h"
#import "HTHTTPArticle.h"
#import "HTHTTPAuthor.h"
#import "HTHTTPFamousAuthor.h"
#import "HTHTTPReader.h"

@interface HTHTTPModelTest : XCTestCase

@end

@implementation HTHTTPModelTest

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


- (void)testModelMapping {
    {
        RKMapping *mapping = [HTHTTPPhotoInfo defaultResponseMapping];
        RKMapping *manuallyMapping = [HTHTTPPhotoInfo manuallyMapping];
        expect(mapping).to.beKindOf([RKObjectMapping class]);
        expect([mapping isEqualToMapping:manuallyMapping]).to.equal(YES);
    }
    
    {
        RKMapping *mapping = [HTHTTPArticle defaultResponseMapping];
        RKMapping *manuallyMapping = [HTHTTPArticle manuallyMapping];
        expect(mapping).to.beKindOf([RKObjectMapping class]);
        expect([mapping isEqualToMapping:manuallyMapping]).to.equal(YES);
    }
    
    {
        RKMapping *mapping = [HTHTTPAuthor defaultResponseMapping];
        RKMapping *manuallyMapping = [HTHTTPAuthor manuallyMapping];
        expect(mapping).to.beKindOf([RKObjectMapping class]);
        expect([mapping isEqualToMapping:manuallyMapping]).to.equal(YES);
    }
    
    {
        RKMapping *mapping = [HTHTTPFamousAuthor defaultResponseMapping];
        RKMapping *manuallyMapping = [HTHTTPFamousAuthor manuallyMapping];
        expect(mapping).to.beKindOf([RKObjectMapping class]);
        expect([mapping isEqualToMapping:manuallyMapping]).to.equal(YES);
    }
    
    {
        RKMapping *mapping = [HTHTTPReader defaultResponseMapping];
        RKMapping *manuallyMapping = [HTHTTPReader manuallyMapping];
        expect(mapping).to.beKindOf([RKObjectMapping class]);
        expect([mapping isEqualToMapping:manuallyMapping]).to.equal(YES);
    }
    
    {
        RKMapping *mapping = [HTHTTPTestModel defaultResponseMapping];
        RKMapping *manuallyMapping = [HTHTTPTestModel manuallyMapping];
        expect(mapping).to.beKindOf([RKObjectMapping class]);
        expect([mapping isEqualToMapping:manuallyMapping]).to.equal(YES);
    }
}

- (void)testModel2Json {
    HTHTTPTestModel *model = [[HTHTTPTestModel alloc] init];
    {
        model.name = @"lwangTest";
        NSDictionary *dic = [model modelToJSONObject];
        expect([[dic objectForKey:@"name"] isEqualToString:@"lwangTest"]).to.equal(YES);
        NSString *string = [model modelToJSONString];
        expect([string rangeOfString:@"lwangTest"].length > 0).to.equal(YES);
        
        HTHTTPTestModel *convertedModel = [HTHTTPTestModel modelWithJSON:dic];
        expect([model isEqual:convertedModel]).to.equal(YES);
    }
    
    {
        model.count = 5;
        NSDictionary *dic = [model modelToJSONObject];
        expect([[dic objectForKey:@"count"] isEqual:@(5)]).to.equal(YES);
        NSString *string = [model modelToJSONString];
        expect([string rangeOfString:@"5"].length > 0).to.equal(YES);
        
        HTHTTPTestModel *convertedModel = [HTHTTPTestModel modelWithJSON:dic];
        expect([model isEqual:convertedModel]).to.equal(YES);
    }
    
    {
        HTHTTPAddress *simpleAddress = [[HTHTTPAddress alloc] init];
        simpleAddress.province = @"湖北";
        simpleAddress.city = @"公安县";
        model.simpleAddress = simpleAddress;
        
        NSDictionary *dic = [model modelToJSONObject];
        expect([dic objectForKey:@"simpleAddress"] != nil).to.equal(YES);
        NSString *string = [model modelToJSONString];
        expect([string rangeOfString:@"湖北"].length > 0).to.equal(YES);
        
        HTHTTPTestModel *convertedModel = [HTHTTPTestModel modelWithJSON:dic];
        expect([model isEqual:convertedModel]).to.equal(YES);
    }
    
    {
        model.comments = @[@"评论", @"好职位", @"非常好"];
        NSDictionary *dic = [model modelToJSONObject];
        expect([dic objectForKey:@"comments"] != nil).to.equal(YES);
        NSString *string = [model modelToJSONString];
        expect([string rangeOfString:@"非常好"].length > 0).to.equal(YES);
        
        HTHTTPTestModel *convertedModel = [HTHTTPTestModel modelWithJSON:dic];
        expect([model isEqual:convertedModel]).to.equal(YES);
    }
    
    {
        model.isSpecial = YES;
        NSDictionary *dic = [model modelToJSONObject];
        NSObject *isSpecial = [dic objectForKey:@"isSpecial"];
        expect([isSpecial isEqual:@(YES)]).to.equal(YES);
        
        HTHTTPTestModel *convertedModel = [HTHTTPTestModel modelWithJSON:dic];
        expect(convertedModel.isSpecial).to.equal(YES);
        expect([model isEqual:convertedModel]).to.equal(YES);
        
        convertedModel = [HTHTTPTestModel modelWithDictionary:dic];
        expect([model isEqual:convertedModel]).to.equal(YES);
    }
    
    {
        NSData *jsonData = [model modelToJSONData];
        NSString *jsonString = [model modelToJSONString];

        HTHTTPTestModel *convertedModel = [HTHTTPTestModel modelWithJSON:jsonData];
        expect([model isEqual:convertedModel]).to.equal(YES);
        
        convertedModel = [HTHTTPTestModel modelWithJSON:jsonString];
        expect([model isEqual:convertedModel]).to.equal(YES);
    }
}

- (void)testModelCopy {
    HTHTTPTestModel *model = [self modelForNormalTest];
    HTHTTPTestModel *copiedObject = [model copy];
    expect([copiedObject isEqual:model]).to.equal(YES);
    expect(copiedObject.htVersion).to.equal(12);
}

- (void)testModelArchive {
    HTHTTPTestModel *model = [self modelForNormalTest];
    // Archive
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:model];
    HTHTTPTestModel *decodeObject = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    expect([decodeObject isEqual:model]).to.equal(YES);
    expect(decodeObject.htVersion).to.equal(12);
}

- (HTHTTPTestModel *)modelForNormalTest {
    HTHTTPTestModel *model = [[HTHTTPTestModel alloc] init];
    model.name = @"lwangTest";
    model.count = 5;
    model.comments = @[@"评论", @"好职位", @"非常好"];
    model.isSpecial = YES;
    
    HTHTTPAddress *address = [[HTHTTPAddress alloc] init];
    address.province = @"湖北省";
    address.city = @"荆州市";
    model.simpleAddress = address;
    
    model.htVersion = 12;
    
    return model;
}

#pragma mark - Test Nested With Model Collection such as NSArray<HTHTTPAddress *> *addressList;

- (void)testModelMappingWithNestedModelCollection {
    RKMapping *defaultMapping = [HTHTTPTestCollectionModel defaultResponseMapping];
    RKMapping *manuallyMapping = [HTHTTPTestCollectionModel manuallyMapping];
    expect([defaultMapping isEqualToMapping:manuallyMapping]).to.equal(YES);
}

- (void)testModel2JsonWithNestedModelCollection {
    HTHTTPTestCollectionModel *model = [self modelWithNestedModelCollection];
    
    NSDictionary *dic = [model modelToJSONObject];
    NSData *jsonData = [model modelToJSONData];
    NSString *jsonString = [model modelToJSONString];
    
    HTHTTPTestCollectionModel *convertedModel = [HTHTTPTestCollectionModel modelWithDictionary:dic];
    expect([model isEqual:convertedModel]).to.equal(YES);
    
    convertedModel = [HTHTTPTestCollectionModel modelWithJSON:jsonData];
    expect([model isEqual:convertedModel]).to.equal(YES);
    
    convertedModel = [HTHTTPTestCollectionModel modelWithJSON:jsonString];
    expect([model isEqual:convertedModel]).to.equal(YES);
    
    HTHTTPTestCollectionModel *emptyModel = [[HTHTTPTestCollectionModel alloc] init];
    [emptyModel modelSetWithDictionary:dic];
    expect([model isEqual:emptyModel]).to.equal(YES);
    
    emptyModel = [[HTHTTPTestCollectionModel alloc] init];
    [emptyModel modelSetWithJSON:jsonData];
    expect([model isEqual:emptyModel]).to.equal(YES);
}

- (void)testModelCopyWithNestedModelCollection {
    HTHTTPTestCollectionModel *model = [self modelWithNestedModelCollection];
    HTHTTPTestCollectionModel *copiedObject = [model copy];
    expect([copiedObject isEqual:model]).to.equal(YES);
    expect(copiedObject.htVersion).to.equal(model.htVersion);
}

- (void)testModelArchiveWithNestedModelCollection {
    HTHTTPTestCollectionModel *model = [self modelWithNestedModelCollection];
    
    // Archive
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:model];
    HTHTTPTestModel *decodeObject = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    expect([decodeObject isEqual:model]).to.equal(YES);
    expect(decodeObject.htVersion).to.equal(model.htVersion);
}

- (HTHTTPTestCollectionModel *)modelWithNestedModelCollection {
    HTHTTPTestCollectionModel *model = [[HTHTTPTestCollectionModel alloc] init];
    model.name = @"lwangTest";
    model.count = 5;
    model.comments = @[@"评论", @"好职位", @"非常好"];
    model.isSpecial = YES;
    
    HTHTTPAddress *address = [[HTHTTPAddress alloc] init];
    address.province = @"湖北省";
    address.city = @"荆州市";
    model.simpleAddress = address;
    
    NSMutableArray<HTHTTPArticle *> *articles = [NSMutableArray array];
    for (int i = 0; i< 3; i ++) {
        HTHTTPArticle *article = [[HTHTTPArticle alloc] init];
        article.title = [NSString stringWithFormat:@"标题%@", @(i)];
        article.content = [NSString stringWithFormat:@"内容%@", @(i)];
        article.isNovel = YES;
        article.chapters = @[@"Chapter 1", @"Chapter 2"];
        [articles addObject:article];
    }
    
    model.articles = articles;
    
    model.htVersion = 12;
    
    return model;
}

#pragma mark -

// 测试复杂的嵌套Model. TODO: 后续从实际项目中挑选例子进行测试.
- (void)testNestedModelMapping {
    
}

- (void)testNestedModel2Json {
    
}

- (void)testNestedModelCopy {
    
}

- (void)testNestedModelArchive {
    
}

@end
