//
//  HTHttpModelTestController.m
//  HTHttpDemo
//
//  Created by Wangliping on 15/11/19.
//  Copyright © 2015年 NetEase. All rights reserved.
//

#import "HTHttpModelTestController.h"
#import "HTNetworking.h"
#import <Foundation/Foundation.h>
#import <objc/runtime.h>

#import "RKObjectMappingOperationDataSource.h"
#import "RKWikiPage.h"
#import "HTHTTPModel+Validate.h"
#import "HTDemoPerson.h"
#import "HTDemoArticle.h"
#import "HTDemoAuthor.h"
#import "HTDemoSubscriber.h"
#import "HTDemoAddress.h"
#import "HTDerivedArticle.h"
#import "HTDemoArticle+HTYYTest.h"
#import "HTCommentRequest.h"
#import "HTArticleRequest.h"
#import "HTAuthorRequest.h"
#import "HTArticle.h"
#import "HTAuthor.h"
#import "HTComment.h"
#import "HTDemoHelper.h"
#import "HTDemoPhotoInfo.h"
#import "HTDemoGetUserPhotoListRequest.h"
#import "HTModels.h"
#import "HTRequests.h"
#import "HTPostArticleRequest.h"
#import "HTSpecialModel.h"
#import "HTSimpleAddress.h"
#import "NSObject+YYModel.h"

@implementation HTHttpModelTestController

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(back:)];
    self.navigationItem.title = @"Model Test";
    
    [RKMIMETypeSerialization registerClass:[RKNSJSONSerialization class] forMIMEType:@"text/plain"];
    NSURL *baseURL = [NSURL URLWithString:@"http://localhost:3000"];
    HTNetworkingInit(baseURL);
}

- (IBAction)back:(id)sender {
     [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Load Data

- (NSArray *)generateMethodNameList {
    // 测试Server参见 https://git.hz.netease.com/hzwangliping/TrainingServer
    return @[@"testYYModel",
             @"testYYModelPerformance",
             @"testYYModelUnsupportType",
             @"testDerivedModel",
             @"testCategoryModel",
             @"testWithOldResponseDescriptor",
             @"testRequestWithNewDescriptor",
             @"testUndefinedKey",
             @"testRequestToJSON",
             @"testRequestParams",
             @"testRequestParamsPerformance",
             @"testModelWithRestKit",
             @"testModelWrapperWithRestKit",
             @"testSpecialModel",
             @"testInvalidRequestDescriptor",
             @"testInvalidModel",
             @"testMaxUndefined"];
}

#pragma mark - Test Methods

- (void)testYYModel {
    HTDemoArticle *article = [self demoArticle];
    HTDemoArticle *anotherArticle = [article copy];
    NSAssert([article isEqual:anotherArticle], @"copy出来的对象应该相等");
    NSLog(@"hash Value of article is %@ while hash value of another Article is %@", @(article.hash), @(article.hash));
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:article];
    HTDemoArticle *decodeArticle = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    NSAssert([article isEqual:decodeArticle], @"Archive出来的对象应该相等");
    
    NSData *jsonData = [article modelToJSONData];
    NSString *jsonString = [article modelToJSONString];
    id jsonObject = [article modelToJSONObject];
    HTDemoArticle *jsonArticle = [HTDemoArticle modelWithDictionary:jsonObject];
    HTDemoArticle *jsonObjectArticle = [HTDemoArticle modelWithJSON:jsonObject];
    HTDemoArticle *jsonDataArticle = [HTDemoArticle modelWithJSON:jsonData];
    HTDemoArticle *jsonStringArticle = [HTDemoArticle modelWithJSON:jsonString];
    
    // TODO: 这里存在问题. jsonArticle的subsrcibers没有正确解析出每个Item的类型来.
//    NSAssert([article isEqual:jsonArticle], @"应该相等");
    NSArray *subsrcibers = [article.subscribers sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        if (![obj1 isKindOfClass:[HTDemoSubscriber class]] || ![obj2 isKindOfClass:[HTDemoSubscriber class]]) {
            return NSOrderedSame;
        }
        
        return [((HTDemoSubscriber *)obj1).name compare:((HTDemoSubscriber *)obj2).name];
    }];

    NSArray *jsonSubsrcibers = [jsonArticle.subscribers sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        if (![obj1 isKindOfClass:[HTDemoSubscriber class]] || ![obj2 isKindOfClass:[HTDemoSubscriber class]]) {
            return NSOrderedSame;
        }
        
        return [((HTDemoSubscriber *)obj1).name compare:((HTDemoSubscriber *)obj2).name];
    }];
    
    NSAssert([subsrcibers isEqualToArray:jsonSubsrcibers], @"应该相等");
    NSAssert([subsrcibers isEqual:jsonSubsrcibers], @"应该相等");
    NSAssert([article.subscribers isEqual:jsonArticle.subscribers], @"应该相等");
    
    // TODO: NSDate转出来不相等了. 这个似乎是没办法的，涉及到精度的问题.
//    NSAssert([article.subscribers isEqual:jsonArticle.subscribers], @"应该相等");
    
    NSAssert([jsonArticle isEqual:jsonObjectArticle], @"应该相等");
    NSAssert([jsonArticle isEqual:jsonDataArticle], @"应该相等");
    NSAssert([jsonArticle isEqual:jsonStringArticle], @"应该相等");
}

- (void)testYYModelUnsupportType {
    // 理论上来说，只要不是基本类型就可以继续往下.
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.baidu.com"]];
    NSString *jsonString = [request yy_modelToJSONString];
    NSLog(@"%@", jsonString);
}

- (void)testDerivedModel {
    HTDerivedArticle *article = [self derivedArticle];
    HTDerivedArticle *anotherArticle = [article copy];
    NSAssert([article isEqual:anotherArticle], @"copy出来的对象应该相等");
    NSLog(@"hash Value of article is %@ while hash value of another Article is %@", @(article.hash), @(article.hash));
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:article];
    HTDemoArticle *decodeArticle = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    NSAssert([article isEqual:decodeArticle], @"Archive出来的对象应该相等");
    
    NSData *jsonData = [article modelToJSONData];
    NSString *jsonString = [article modelToJSONString];
    id jsonObject = [article modelToJSONObject];
    HTDerivedArticle *jsonArticle = [HTDerivedArticle modelWithDictionary:jsonObject];
    HTDerivedArticle *jsonObjectArticle = [HTDerivedArticle modelWithJSON:jsonObject];
    HTDerivedArticle *jsonDataArticle = [HTDerivedArticle modelWithJSON:jsonData];
    HTDerivedArticle *jsonStringArticle = [HTDerivedArticle modelWithJSON:jsonString];
    
    // TODO: 这里存在问题. jsonArticle的subsrcibers没有正确解析出每个Item的类型来.
    //    NSAssert([article isEqual:jsonArticle], @"应该相等");
    NSArray *subsrcibers = [article.subscribers sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        if (![obj1 isKindOfClass:[HTDemoSubscriber class]] || ![obj2 isKindOfClass:[HTDemoSubscriber class]]) {
            return NSOrderedSame;
        }
        
        return [((HTDemoSubscriber *)obj1).name compare:((HTDemoSubscriber *)obj2).name];
    }];
    
    NSArray *jsonSubsrcibers = [jsonArticle.subscribers sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        if (![obj1 isKindOfClass:[HTDemoSubscriber class]] || ![obj2 isKindOfClass:[HTDemoSubscriber class]]) {
            return NSOrderedSame;
        }
        
        return [((HTDemoSubscriber *)obj1).name compare:((HTDemoSubscriber *)obj2).name];
    }];
    
    NSAssert([subsrcibers isEqualToArray:jsonSubsrcibers], @"应该相等");
    NSAssert([subsrcibers isEqual:jsonSubsrcibers], @"应该相等");
    NSAssert([article.subscribers isEqual:jsonArticle.subscribers], @"应该相等");
    
    // TODO: NSDate转出来不相等了. 这个似乎是没办法的，涉及到精度的问题.
    //    NSAssert([article.subscribers isEqual:jsonArticle.subscribers], @"应该相等");
    
    NSAssert([jsonArticle isEqual:jsonObjectArticle], @"应该相等");
    NSAssert([jsonArticle isEqual:jsonDataArticle], @"应该相等");
    NSAssert([jsonArticle isEqual:jsonStringArticle], @"应该相等");
}

- (void)testCategoryModel {
    HTDerivedArticle *article = [self derivedArticle];
    article.ht_version = @"1.1.1";
    
    HTDerivedArticle *anotherArticle = [article copy];
    NSAssert([article isEqual:anotherArticle], @"copy出来的对象应该相等");
    NSLog(@"hash Value of article is %@ while hash value of another Article is %@", @(article.hash), @(article.hash));
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:article];
    HTDemoArticle *decodeArticle = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    NSAssert([article isEqual:decodeArticle], @"Archive出来的对象应该相等");
    
    NSData *jsonData = [article modelToJSONData];
    NSString *jsonString = [article modelToJSONString];
    id jsonObject = [article modelToJSONObject];
    HTDerivedArticle *jsonArticle = [HTDerivedArticle modelWithDictionary:jsonObject];
    HTDerivedArticle *jsonObjectArticle = [HTDerivedArticle modelWithJSON:jsonObject];
    HTDerivedArticle *jsonDataArticle = [HTDerivedArticle modelWithJSON:jsonData];
    HTDerivedArticle *jsonStringArticle = [HTDerivedArticle modelWithJSON:jsonString];
    
    // TODO: 这里存在问题. jsonArticle的subsrcibers没有正确解析出每个Item的类型来.
    //    NSAssert([article isEqual:jsonArticle], @"应该相等");
    NSArray *subsrcibers = [article.subscribers sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        if (![obj1 isKindOfClass:[HTDemoSubscriber class]] || ![obj2 isKindOfClass:[HTDemoSubscriber class]]) {
            return NSOrderedSame;
        }
        
        return [((HTDemoSubscriber *)obj1).name compare:((HTDemoSubscriber *)obj2).name];
    }];
    
    NSArray *jsonSubsrcibers = [jsonArticle.subscribers sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        if (![obj1 isKindOfClass:[HTDemoSubscriber class]] || ![obj2 isKindOfClass:[HTDemoSubscriber class]]) {
            return NSOrderedSame;
        }
        
        return [((HTDemoSubscriber *)obj1).name compare:((HTDemoSubscriber *)obj2).name];
    }];
    
    NSAssert([subsrcibers isEqualToArray:jsonSubsrcibers], @"应该相等");
    NSAssert([subsrcibers isEqual:jsonSubsrcibers], @"应该相等");
    NSAssert([article.subscribers isEqual:jsonArticle.subscribers], @"应该相等");
    
    // TODO: NSDate转出来不相等了. 这个似乎是没办法的，涉及到精度的问题.
    //    NSAssert([article.subscribers isEqual:jsonArticle.subscribers], @"应该相等");
    
    NSAssert([jsonArticle isEqual:jsonObjectArticle], @"应该相等");
    NSAssert([jsonArticle isEqual:jsonDataArticle], @"应该相等");
    NSAssert([jsonArticle isEqual:jsonStringArticle], @"应该相等");
}

- (void)testWithOldResponseDescriptor {
    RKResponseDescriptor *commentResponseDescriptor = [HTCommentRequest responseDescriptor];
    RKResponseDescriptor *articleResponseDescriptor = [HTArticleRequest responseDescriptor];
    RKResponseDescriptor *authorRepsonseDescriptor = [HTAuthorRequest responseDescriptor];
    RKResponseDescriptor *postResponseDescriptor = [HTDemoGetUserPhotoListRequest responseDescriptor];
    
    RKResponseDescriptor *oldCommentResponseDescriptor = [self oldCommentResponseDescriptor];
    RKResponseDescriptor *oldArticleResponseDescriptor = [self oldArticleResponseDescriptor];
    RKResponseDescriptor *oldAuthorRepsonseDescriptor = [self oldAuthorResponseDescriptor];
    RKResponseDescriptor *oldPostResponseDescriptor = [self oldGetPostInfoResponseDescriptor];
    
    NSAssert([commentResponseDescriptor isEqualToResponseDescriptor:oldCommentResponseDescriptor], @"生成的ResponseDescriptor和之前的等价");
    NSAssert([articleResponseDescriptor isEqualToResponseDescriptor:oldArticleResponseDescriptor], @"生成的ResponseDescriptor和之前的等价");
    NSAssert([authorRepsonseDescriptor isEqualToResponseDescriptor:oldAuthorRepsonseDescriptor], @"生成的ResponseDescriptor和之前的等价");
    NSAssert([postResponseDescriptor isEqualToResponseDescriptor:oldPostResponseDescriptor], @"生成的ResponseDescriptor和之前的等价");
}



- (void)testRequestWithNewDescriptor {
    HTDemoGetUserPhotoListRequest *request = [[HTDemoGetUserPhotoListRequest alloc] init];
    [request startWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self showResultSilently:YES operation:operation result:mappingResult error:nil];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self showResultSilently:NO operation:operation result:nil error:error];
    }];
}

- (void)testUndefinedKey {
    HTDemoArticle *article = [[HTDemoArticle alloc] init];
    article.title = @"这是一篇用于测试的文章";
    article.body = @"静夜思 窗前明月光 疑是地上霜 举头望明月 低头思故乡";
    article.author = [self authorLibai];
    article.publicationDate = [NSDate date];
    article.comments = @[@"好诗，支持", @"测试测试测试"];
    article.subscribers = [self subsrcibers:5];
    
    article.ht_version = @"1";
    
    NSString *propertyValue = @"1";
    
    NSError *error = nil;
    // Note LWANG: ValidateValue只是为了确定类型，主要是具体的类型，而不是为了确定undefined key. 即使是undefinedKey, 也会返回YES.
    BOOL isValidate = [article validateValue:&propertyValue forKey:@"ht_version" error:&error];
    if (nil != error) {
        NSLog(@"error: %@ isValidate: %@", error, @(isValidate));
    }
    
    isValidate = [article validateValue:&propertyValue forKey:@"ht_version1" error:&error];
    if (nil != error) {
        NSLog(@"error: %@ isValidate: %@", error, @(isValidate));
    }
    
    if (isValidate) {
        [article setValue:propertyValue forKey:@"ht_version1"];
    }
    
    if (nil != error) {
        NSLog(@"error: %@ isValidate: %@", error, @(isValidate));
    }
    
    
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://baidu.com"]];
    [request setValue:@"It is a cacheKey" forKey:@"ht_cacheKey"];
    
    @try {
        [request setValue:@"It is a cacheKey" forKey:@"ht_cacheKey1"];
    } @catch (NSException *ex) {
        NSLog(@"*** Caught exception setting key \"%@\" : %@", @"ht_cacheKey", ex);
    }
    
    NSLog(@"%@", request);
}

- (void)testRequestToJSON {
    NSLog(@"start testRequestToJSON");
    
    HTPostArticleRequest *request = [[HTPostArticleRequest alloc] init];
    request.cacheId = HTCachePolicyCacheFirst;
    request.name = @"lwang";
    request.length = 12333;
    request.allowComment = YES;
    
    HTArticle *article = [[HTArticle alloc] init];
    article.title = @"这是一篇文章";
    article.body = @"这是文章正文";
    article.author = nil;
    article.comments = [NSMutableArray array];
    request.article = article;
    
    HTAuthor *testAuthor = [[HTAuthor alloc] init];
    testAuthor.name = @"作者是李白";
    request.testDic = @{@"hehe":@"value"};
    request.authors = @[testAuthor];

    NSLog(@"JSON Object: %@", [request yy_modelToJSONObject]);
    NSLog(@"JSON String: %@", [request yy_modelToJSONString]);
    
    NSDictionary *params = [request requestParams];
    NSAssert([params isEqual:[request yy_modelToJSONObject]], @"request params实际就是JSON数据");
    NSLog(@"request params: %@", params);
}

- (void)testRequestParams {
//    NSLog(@"start testRequestToJSON");
//    
//    HTPostArticleRequest *request = [[HTPostArticleRequest alloc] init];
//    request.cacheId = HTCachePolicyCacheFirst;
//    request.name = @"lwang";
//    request.length = 12333;
//    request.allowComment = YES;
//    
//    HTArticle *article = [[HTArticle alloc] init];
//    article.title = @"这是一篇文章";
//    article.body = @"这是文章正文";
//    article.author = nil;
//    article.comments = [NSMutableArray array];
//    request.article = article;
//    
//    HTAuthor *testAuthor = [[HTAuthor alloc] init];
//    testAuthor.name = @"作者是李白";
//    request.testDic = @{@"hehe":@"value"};
//    request.authors = @[testAuthor];
//    
//    NSDictionary *params = [request requestParams];
//    NSAssert([params isEqual:[request yy_modelToJSONObject]], @"request params实际就是JSON数据");
//    NSLog(@"request params: %@", params);
//    
//    
//    HTCommentRequest *commentRequest = [[HTCommentRequest alloc] init];
//    {
//        NSDictionary *newParams = [commentRequest requestParams];
//        NSDictionary *oldParams = [self oldRequestParamsOfCommentRequest:commentRequest];
//        NSAssert(nil == newParams || [newParams isEqualToDictionary:oldParams], @"自动生成的Request Params与Old Params等价");
//    }
//
//    {
//        commentRequest.userName = @"这是用户名";
//        NSDictionary *newParams = [commentRequest requestParams];
//        NSDictionary *oldParams = [self oldRequestParamsOfCommentRequest:commentRequest];
//        NSAssert(nil == newParams || [newParams isEqualToDictionary:oldParams], @"自动生成的Request Params与Old Params等价");
//    }
//    
//    {
//        commentRequest.password = @"这是密码";
//        NSDictionary *newParams = [commentRequest requestParams];
//        NSDictionary *oldParams = [self oldRequestParamsOfCommentRequest:commentRequest];
//        NSAssert(nil == newParams || [newParams isEqualToDictionary:oldParams], @"自动生成的Request Params与Old Params等价");
//        NSLog(@"request Params: %@", newParams);
//    }
}

- (NSDictionary *)oldRequestParamsOfCommentRequest:(HTCommentRequest *)commentRequest {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    if (nil != commentRequest.userName) {
        [dic setObject:commentRequest.userName forKey:@"userName"];
    }

    if (nil != commentRequest.password) {
        [dic setObject:commentRequest.password forKey:@"password"];
    }
    
    return dic;
}

- (void)testRequestParamsPerformance {
    HTPostArticleRequest *request = [[HTPostArticleRequest alloc] init];
    request.cacheId = HTCachePolicyCacheFirst;
    request.name = @"lwang";
    request.length = 12333;
    request.allowComment = YES;
    
    HTArticle *article = [[HTArticle alloc] init];
    article.title = @"这是一篇文章";
    article.body = @"这是文章正文";
    article.author = nil;
    article.comments = [NSMutableArray array];
    request.article = article;
    
    HTAuthor *testAuthor = [[HTAuthor alloc] init];
    testAuthor.name = @"作者是李白";
    request.testDic = @{@"hehe":@"value"};
    request.authors = @[testAuthor];
    
    NSTimeInterval begin, end;
    begin = CACurrentMediaTime();
    NSLog(@"start testRequestParamsPerformance");
    @autoreleasepool {
        for (int i = 0; i < 10000; i ++) {
            NSDictionary *params = [request requestParams];
            if ([params count] > 0) {
                
            }
        }
    }
    end = CACurrentMediaTime();
    printf("HTPostArticleRequest:        %8.2f   \n", (end - begin) * 1000);
    NSLog(@"finish testRequestParamsPerformance");
    
    HTCommentRequest *commentRequest = [[HTCommentRequest alloc] init];
    commentRequest.userName = @"这是用户名";
    commentRequest.password = @"这是密码";
    NSLog(@"start testRequestParamsPerformance HTCommentRequest");
    @autoreleasepool {
        for (int i = 0; i < 10000; i ++) {
            NSDictionary *params = [commentRequest requestParams];
            if ([params count] > 0) {
                
            }
        }
    }
    end = CACurrentMediaTime();
    printf("HTCommentRequest:        %8.2f   \n", (end - begin) * 1000);
    NSLog(@"finish testRequestParamsPerformance HTCommentRequest");
    
    NSLog(@"start testRequestParamsPerformance HTCommentRequest");
    @autoreleasepool {
        for (int i = 0; i < 10000; i ++) {
            NSDictionary *params = [self oldRequestParamsOfCommentRequest:commentRequest];
            if ([params count] > 0) {
                
            }
        }
    }
    end = CACurrentMediaTime();
    printf("HTCommentRequest:        %8.2f   \n", (end - begin) * 1000);
    NSLog(@"finish testRequestParamsPerformance HTCommentRequest Manually");
}

- (void)testModelWithRestKit {
    HTDemoPerson *person = [self demoJsonPerson];
 
    RKObjectMapping *addressObjectMapping = [RKObjectMapping mappingForClass:[NSMutableDictionary class]];
    [addressObjectMapping addAttributeMappingsFromArray:[HTDemoPerson baseTypePropertyList]];
    
    RKRequestDescriptor *requestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:addressObjectMapping objectClass:[HTDemoPerson class] rootKeyPath:nil method:RKRequestMethodAny];
    
    NSError *error = nil;
    NSDictionary *parameters = [RKObjectParameterization parametersWithObject:person requestDescriptor:requestDescriptor error:&error];
    NSLog(@"%@", parameters);

    {
        RKMapping *mapping = [HTDemoPerson defaultResponseMapping];
        RKMapping *inverseMapping = [(RKObjectMapping *)mapping inverseMapping];
        
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
        RKMappingOperation *operation = [[RKMappingOperation alloc] initWithSourceObject:person destinationObject:dictionary mapping:inverseMapping];
        RKObjectMappingOperationDataSource *dataSource = [RKObjectMappingOperationDataSource new];
        operation.dataSource = dataSource;
        [operation start];
        if (operation.error) {
            return;
        }
        
        NSLog(@"%@", dictionary);
//        NSAssert([dictionary isEqualToDictionary:[person yy_modelToJSONObject]], @"生成结果应该相同");
        
        // Optionally enclose the serialized object within a container...
        //    return self.rootKeyPath ? [NSMutableDictionary dictionaryWithObject:dictionary forKey:self.rootKeyPath] : dictionary;
        
    }
    
    {
        // TODO: Mapping存在这样一个问题，多重递归描述不清楚何时截止，因为描述是类信息. 而YYModel会根据对象信息递归，为nil那么就不会继续往下，否则会继续往下.
        HTDerivedArticle *article = [self derivedArticle];
        RKMapping *mapping = [HTDerivedArticle defaultResponseMapping];
        RKMapping *inverseMapping = [(RKObjectMapping *)mapping inverseMapping];
        
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
        RKMappingOperation *operation = [[RKMappingOperation alloc] initWithSourceObject:article destinationObject:dictionary mapping:inverseMapping];
        RKObjectMappingOperationDataSource *dataSource = [RKObjectMappingOperationDataSource new];
        operation.dataSource = dataSource;
        [operation start];
        if (operation.error) {
            return;
        }
        
        NSLog(@"%@", dictionary);
//        NSAssert([dictionary isEqualToDictionary:[article yy_modelToJSONObject]], @"生成结果应该相同");
        
        // Optionally enclose the serialized object within a container...
        //    return self.rootKeyPath ? [NSMutableDictionary dictionaryWithObject:dictionary forKey:self.rootKeyPath] : dictionary;
        
    }
    
    {
        NSDictionary *propertyInspection = [[RKPropertyInspector sharedInspector] propertyInspectionForClass:[HTDemoPerson class]];
        NSLog(@"%@", propertyInspection);
    }
}

- (void)testModelWrapperWithRestKit {
//    NSLog(@"start testRequestToJSON");
//    
//    HTPostArticleRequest *request = [[HTPostArticleRequest alloc] init];
//    request.cacheId = HTCachePolicyCacheFirst;
//    request.name = @"lwang";
//    request.length = 12333;
//    request.allowComment = YES;
//    
//    HTArticle *article = [[HTArticle alloc] init];
//    article.title = @"这是一篇文章";
//    article.body = @"这是文章正文";
//    article.author = nil;
//    article.comments = [NSMutableArray array];
//    request.article = article;
//    
//    HTAuthor *testAuthor = [[HTAuthor alloc] init];
//    testAuthor.name = @"作者是李白";
//    NSLog(@"%@", [testAuthor yy_modelToJSONString]);
//    request.testDic = @{@"hehe":@"value"};
//    request.authors = @[testAuthor];
//    
//    // TODO: 这里为什么YYModel会出错了？
//    NSLog(@"JSON String: %@", [request yy_modelToJSONString]);
//    
//    NSLog(@"JSON Object: %@", [request ht_modelToJSONObject]);
//    NSLog(@"JSON Data: %@", [request ht_modelToJSONData]);
//    NSLog(@"JSON String: %@", [request ht_modelToJSONString]);
}

- (void)testSpecialModel {
    // 性能测试的结果比Mantle要稍差.
    NSString *methodName = NSStringFromSelector(_cmd);
    
    {
        NSDictionary *propertyInspection = [[RKPropertyInspector sharedInspector] propertyInspectionForClass:[HTSpecialModel class]];
        NSLog(@"%@", propertyInspection);
    }
    
    HTSpecialModel *model = [[HTSpecialModel alloc] init];
    {
        model.name = @"MyName";
        NSLog(@"%@ : %@", methodName, [model yy_modelToJSONString]);
        NSLog(@"%@ : %@", methodName, [model ht_modelToJSONString]);
        
        HTSpecialModel *anotherModel = [HTSpecialModel ht_modelWithJSON:[model yy_modelToJSONString]];
        HTSpecialModel *anotherModel2 = [HTSpecialModel ht_modelWithJSON:[model ht_modelToJSONObject]];
        NSLog(@"Model: %@", anotherModel);
        NSLog(@"Model2: %@", anotherModel2);
    }

    {
        model.count = 5;
        [model updateCount];
        NSLog(@"%@ : %@", methodName, [model yy_modelToJSONString]);
        NSLog(@"%@ : %@", methodName, [model ht_modelToJSONString]);
        
        HTSpecialModel *yymodel = [HTSpecialModel yy_modelWithJSON:[model yy_modelToJSONString]];
        HTSpecialModel *anotherModel = [HTSpecialModel ht_modelWithJSON:[model yy_modelToJSONString]];
        HTSpecialModel *anotherModel2 = [HTSpecialModel ht_modelWithJSON:[model ht_modelToJSONObject]];
        NSLog(@"yymodel: %@", yymodel);
        NSLog(@"Model: %@", anotherModel);
        NSLog(@"Model2: %@", anotherModel2);
    }

    {
        HTSimpleAddress *simpleAddress = [[HTSimpleAddress alloc] init];
        simpleAddress.province = @"湖北";
        simpleAddress.city = @"公安县";
        model.simpleAddress = simpleAddress;
        NSLog(@"%@ : %@", methodName, [model yy_modelToJSONString]);
        NSLog(@"%@ : %@", methodName, [model ht_modelToJSONString]);
        
        HTSpecialModel *yymodel = [HTSpecialModel yy_modelWithJSON:[model yy_modelToJSONString]];
        HTSpecialModel *anotherModel = [HTSpecialModel ht_modelWithJSON:[model yy_modelToJSONString]];
        HTSpecialModel *anotherModel2 = [HTSpecialModel ht_modelWithJSON:[model ht_modelToJSONObject]];
        NSLog(@"yymodel: %@", yymodel);
        NSLog(@"Model: %@", anotherModel);
        NSLog(@"Model2: %@", anotherModel2);
    }
    
    {
        model.comments = @[@"评论", @"好职位戏", @"非常好"];
        NSLog(@"%@ : %@", methodName, [model yy_modelToJSONString]);
        NSLog(@"%@ : %@", methodName, [model ht_modelToJSONString]);
        
        HTSpecialModel *yymodel = [HTSpecialModel yy_modelWithJSON:[model yy_modelToJSONString]];
        HTSpecialModel *anotherModel = [HTSpecialModel ht_modelWithJSON:[model yy_modelToJSONString]];
        HTSpecialModel *anotherModel2 = [HTSpecialModel ht_modelWithJSON:[model ht_modelToJSONObject]];
        NSLog(@"yymodel: %@", yymodel);
        NSLog(@"Model: %@", anotherModel);
        NSLog(@"Model2: %@", anotherModel2);
    }
    
    {
        NSMutableArray *array = [NSMutableArray array];
        HTSimpleAddress *simpleAddress = [[HTSimpleAddress alloc] init];
        simpleAddress.province = @"湖北";
        simpleAddress.city = @"荆州";
        [array addObject:simpleAddress];
        
        simpleAddress = [[HTSimpleAddress alloc] init];
        simpleAddress.province = @"浙江";
        simpleAddress.city = @"杭州";
        [array addObject:simpleAddress];
        
        model.addressList = array;
        NSLog(@"%@ : %@", methodName, [model yy_modelToJSONString]);
        NSLog(@"%@ : %@", methodName, [model ht_modelToJSONString]);
        
        HTSpecialModel *yymodel = [HTSpecialModel yy_modelWithJSON:[model yy_modelToJSONString]];
        HTSpecialModel *anotherModel = [HTSpecialModel ht_modelWithJSON:[model yy_modelToJSONString]];
        HTSpecialModel *anotherModel2 = [HTSpecialModel ht_modelWithJSON:[model ht_modelToJSONObject]];
        NSLog(@"yymodel: %@", yymodel);
        NSLog(@"Model: %@", anotherModel);
        NSLog(@"Model2: %@", anotherModel2);
    }
    
    {
        NSMutableArray *array = [NSMutableArray array];
        HTSimpleAddress *simpleAddress = [[HTSimpleAddress alloc] init];
        simpleAddress.province = @"湖北";
        simpleAddress.city = @"荆州";
        NSData *addressData = [simpleAddress.province dataUsingEncoding:NSUTF8StringEncoding];
        [array addObject:addressData];
        
        simpleAddress = [[HTSimpleAddress alloc] init];
        simpleAddress.province = @"浙江";
        simpleAddress.city = @"杭州";
        addressData = [simpleAddress.province dataUsingEncoding:NSUTF8StringEncoding];
        [array addObject:addressData];
        
        model.commentData = array;
        NSLog(@"%@ : %@", methodName, [model yy_modelToJSONString]);
        NSLog(@"%@ : %@", methodName, [model ht_modelToJSONString]);
        
        HTSpecialModel *yymodel = [HTSpecialModel yy_modelWithJSON:[model yy_modelToJSONString]];
        HTSpecialModel *anotherModel = [HTSpecialModel ht_modelWithJSON:[model yy_modelToJSONString]];
        HTSpecialModel *anotherModel2 = [HTSpecialModel ht_modelWithJSON:[model ht_modelToJSONObject]];
        NSLog(@"yymodel: %@", yymodel);
        NSLog(@"Model: %@", anotherModel);
        NSLog(@"Model2: %@", anotherModel2);
    }
    
    {
        model.comments = @[@"评论", @"好职位戏", @"非常好"];
        NSLog(@"%@ : %@", methodName, [model yy_modelToJSONString]);
        NSLog(@"%@ : %@", methodName, [model ht_modelToJSONString]);
        
        HTSpecialModel *yymodel = [HTSpecialModel yy_modelWithJSON:[model yy_modelToJSONString]];
        HTSpecialModel *anotherModel = [HTSpecialModel ht_modelWithJSON:[model yy_modelToJSONString]];
        HTSpecialModel *anotherModel2 = [HTSpecialModel ht_modelWithJSON:[model ht_modelToJSONObject]];
        NSLog(@"yymodel: %@", yymodel);
        NSLog(@"Model: %@", anotherModel);
        NSLog(@"Model2: %@", anotherModel2);
    }
    
    
    {
        model.isSpecial = YES;
        NSLog(@"%@ : %@", methodName, [model yy_modelToJSONString]);
        NSLog(@"%@ : %@", methodName, [model ht_modelToJSONString]);
        
        HTSpecialModel *anotherModel = [HTSpecialModel ht_modelWithJSON:[model yy_modelToJSONString]];
        HTSpecialModel *anotherModel2 = [HTSpecialModel ht_modelWithJSON:[model ht_modelToJSONObject]];
        NSLog(@"Model: %@", anotherModel);
        NSLog(@"Model2: %@", anotherModel2);
    }
    
    {
        NSInteger value = 1024;
        model.data = [NSData dataWithBytes:&value length:sizeof(NSInteger)];
        NSLog(@"%@ : %@", methodName, [model yy_modelToJSONString]);
        NSLog(@"%@ : %@", methodName, [model ht_modelToJSONString]);
        
        HTSpecialModel *anotherModel = [HTSpecialModel ht_modelWithJSON:[model yy_modelToJSONString]];
        HTSpecialModel *anotherModel2 = [HTSpecialModel ht_modelWithJSON:[model ht_modelToJSONObject]];
        NSLog(@"Model: %@", anotherModel);
        NSLog(@"Model2: %@", anotherModel2);
    }
    
    {
        model.url = [NSURL URLWithString:@"http://www.163.com"];
        NSLog(@"%@ : %@", methodName, [model yy_modelToJSONString]);
        // TODO: 含有NSURL不可以转成JSON字符串.
        // TODO: 可以在转字符串的地方去修改.
        NSLog(@"%@ : %@", methodName, [model ht_modelToJSONString]);
        
        HTSpecialModel *anotherModel = [HTSpecialModel ht_modelWithJSON:[model yy_modelToJSONString]];
        HTSpecialModel *anotherModel2 = [HTSpecialModel ht_modelWithJSON:[model ht_modelToJSONObject]];
        NSLog(@"Model: %@", anotherModel);
        NSLog(@"Model2: %@", anotherModel2);
    }
    
    {
        model.request = [NSURLRequest requestWithURL:model.url];
        NSLog(@"%@ : %@", methodName, [model yy_modelToJSONString]);
        // TODO: 含有NSURL不可以转成JSON字符串.
        NSLog(@"%@ : %@", methodName, [model ht_modelToJSONString]);
        
        [model ht_modelCopy];
        NSUInteger hash = [model ht_modelHash];
        NSLog(@"hash value is %@", @(hash));
        
//        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:model];
//        HTSpecialModel *decodeModel = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        
        // this class is not key value coding-compliant for the key cachePolicy.'
//        HTSpecialModel *yymodel = [HTSpecialModel yy_modelWithJSON:[model yy_modelToJSONString]];
        HTSpecialModel *anotherModel = [HTSpecialModel ht_modelWithJSON:[model yy_modelToJSONString]];
        HTSpecialModel *anotherModel2 = [HTSpecialModel ht_modelWithJSON:[model ht_modelToJSONObject]];
        NSLog(@"Model: %@", anotherModel);
        NSLog(@"Model2: %@", anotherModel2);
    }
    
    {
        model.testSelector = _cmd;
        NSLog(@"%@ : %@", methodName, [model yy_modelToJSONString]);
        // testSelector未转换，问题不大.
        NSLog(@"%@ : %@", methodName, [model ht_modelToJSONString]);
        
//        [model ht_modelCopy];
//        NSUInteger hash = [model ht_modelHash];
//        
//        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:model];
//        HTSpecialModel *decodeModel = [NSKeyedUnarchiver unarchiveObjectWithData:data];
//        
//        HTSpecialModel *anotherModel = [HTSpecialModel ht_modelWithJSON:[model yy_modelToJSONString]];
//        HTSpecialModel *anotherModel2 = [HTSpecialModel ht_modelWithJSON:[model ht_modelToJSONObject]];
//        NSLog(@"Model: %@", anotherModel);
//        NSLog(@"Model2: %@", anotherModel2);
    }
    
    {
//        model.testImplementation = imp_implementationWithBlock(nil);
//        NSLog(@"%@ : %@", methodName, [model yy_modelToJSONString]);
//        NSLog(@"%@ : %@", methodName, [model ht_modelToJSONString]);
        
//        [model ht_modelCopy];
//        NSUInteger hash = [model ht_modelHash];
//        
//        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:model];
//        HTSpecialModel *decodeModel = [NSKeyedUnarchiver unarchiveObjectWithData:data];
//        
//        HTSpecialModel *anotherModel = [HTSpecialModel ht_modelWithJSON:[model yy_modelToJSONString]];
//        HTSpecialModel *anotherModel2 = [HTSpecialModel ht_modelWithJSON:[model ht_modelToJSONObject]];
//        NSLog(@"Model: %@", anotherModel);
//        NSLog(@"Model2: %@", anotherModel2);
    }
    
    {
        model.stringRef = CFStringCreateWithCString(NULL, "test", kCFStringEncodingASCII);
        // TODO: stringRef都未转换，问题不大.
        NSLog(@"%@ : %@", methodName, [model yy_modelToJSONString]);
        NSLog(@"%@ : %@", methodName, [model ht_modelToJSONString]);
        
//        HTSpecialModel *anotherModel = [HTSpecialModel ht_modelWithJSON:[model yy_modelToJSONString]];
//        HTSpecialModel *anotherModel2 = [HTSpecialModel ht_modelWithJSON:[model ht_modelToJSONObject]];
//        NSLog(@"Model: %@", anotherModel);
//        NSLog(@"Model2: %@", anotherModel2);
    }

    {
        model.myName = @"myName";
        // 可正确转换.
        NSLog(@"%@ : %@", methodName, [model yy_modelToJSONString]);
        NSLog(@"%@ : %@", methodName, [model ht_modelToJSONString]);
        
//        HTSpecialModel *anotherModel = [HTSpecialModel ht_modelWithJSON:[model yy_modelToJSONString]];
//        HTSpecialModel *anotherModel2 = [HTSpecialModel ht_modelWithJSON:[model ht_modelToJSONObject]];
//        NSLog(@"Model: %@", anotherModel);
//        NSLog(@"Model2: %@", anotherModel2);
    }
    //@property (nonatomic, assign, setter=specialNameSet:, getter=specialNameGet) NSString *myName;
    
}


- (void)testInvalidRequestDescriptor {
    RKObjectMapping *requestMapping = [RKObjectMapping requestMapping];
    [requestMapping addAttributeMappingsFromDictionary:@{ @"title": @"title", @"body": @"body", @"data" : @"data" }];
    
    // We wish to generate parameters of the format:
    // @{ @"page": @{ @"title": @"An Example Page", @"body": @"Some example content" } }
    RKRequestDescriptor *requestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:requestMapping
                                                                                   objectClass:[RKWikiPage class]
                                                                                   rootKeyPath:@"page"
                                                                                        method:RKRequestMethodAny];
    
    // Construct an object mapping for the response
    // We are expecting JSON in the format:
    // {"page": {"title": "<title value>", "body": "<body value>"}
    RKObjectMapping *responseMapping = [RKObjectMapping mappingForClass:[RKWikiPage class]];
    [responseMapping addAttributeMappingsFromArray:@[ @"title", @"body" ]];
    
    // Construct a response descriptor that matches any URL (the pathPattern is nil), when the response payload
    // contains content nested under the `@"page"` key path, if the response status code is 200 (OK)
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:responseMapping
                                                                                            method:RKRequestMethodAny
                                                                                       pathPattern:nil
                                                                                           keyPath:@"page"
                                                                                       statusCodes:[NSIndexSet indexSetWithIndex:200]];
    
    // Register our descriptors with a manager
    RKObjectManager *manager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:@"http://restkit.org/"]];
    [manager addRequestDescriptor:requestDescriptor];
    [manager addResponseDescriptor:responseDescriptor];
    manager.requestSerializationMIMEType = RKMIMETypeJSON;
    
    // Work with the object
    RKWikiPage *page = [RKWikiPage new];
    page.title = @"An Example Page";
    page.body  = @"Some example content";
    NSInteger count = 1025;
    page.data = [NSData dataWithBytes:&count length:sizeof(count)];
    
    // POST the parameterized representation of the `page` object to `/posts` and map the response
    [manager postObject:page path:@"/pages" parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        NSLog(@"We object mapped the response with the following result: %@", result);
    } failure:nil];
}

- (void)testInvalidModel {
    HTDemoAddress *address = [self demoAddress];
    address.city = nil;
    NSError *error = nil;
    BOOL isValid = [address validate:&error crashIfInvalid:NO];
    
    HTDerivedArticle *article = [self derivedArticle];
    isValid = [article validate:&error crashIfInvalid:NO];

}

//
//+ (NSArray *)subclassesOfClass:(Class)baseClass {
//    int numClasses;
//    Class *classes = NULL;
//    numClasses = objc_getClassList(NULL, 0);
//    
//    NSMutableArray *classNameList = [NSMutableArray array];
//    if (numClasses > 0) {
//        classes = (__unsafe_unretained Class *)malloc(sizeof(Class) * numClasses);
//        numClasses = objc_getClassList(classes, numClasses);
//        for (int i = 0; i < numClasses; i++) {
//            Class iterClass = classes[i];
//            if (nil == iterClass) {
//                continue;
//            }
//            
//            Class superClass = class_getSuperclass(iterClass);
//            while (nil != superClass) {
//                if (superClass == baseClass){
//                    [classNameList addObject:iterClass];
//                    break;
//                }
//                
//                superClass = class_getSuperclass(superClass);
//            }
//        }
//        
//        free(classes);
//    }
//    
//    return classNameList;
//}

#pragma mark - Test Methods 

- (HTDemoPerson *)demoPerson {
    HTDemoPerson *person = [[HTDemoPerson alloc] init];
    person.name = @"王利平";
    person.son = [[HTDemoPerson alloc] init];
    person.son.name = @"测试";
    
    return person;
}

- (HTDemoPerson *)demoJsonPerson {
    HTDemoPerson *person = [[HTDemoPerson alloc] init];
    person.name = @"王利平";
    person.son = [[HTDemoPerson alloc] init];
    person.son.name = @"测试son";
    person.son.son = [[HTDemoPerson alloc] init];
    person.son.son.name = @"测试sonson";
    person.son.son.son = [[HTDemoPerson alloc] init];
    person.son.son.son.name = @"测试sonsonson";
    
    return person;
}

- (HTDemoArticle *)demoArticle {
    HTDemoArticle *article = [[HTDemoArticle alloc] init];
    article.title = @"这是一篇用于测试的文章";
    article.body = @"静夜思 窗前明月光 疑是地上霜 举头望明月 低头思故乡";
    article.author = [self authorLibai];
    article.publicationDate = [NSDate date];
    article.comments = @[@"好诗，支持", @"测试测试测试"];
    article.subscribers = [self subsrcibers:5];
    
    return article;
}

- (HTDerivedArticle *)derivedArticle {
    HTDerivedArticle *article = [[HTDerivedArticle alloc] init];
    article.title = @"这是一篇用于测试的文章";
    article.body = @"静夜思 窗前明月光 疑是地上霜 举头望明月 低头思故乡";
    article.author = [self authorLibai];
    article.publicationDate = [NSDate date];
    article.comments = @[@"好诗，支持", @"测试测试测试"];
    article.subscribers = [self subsrcibers:5];
    article.subTitle = @"testSubtitle";
    
    return article;
}

- (HTDemoAuthor *)authorLibai {
    HTDemoAuthor *libai = [[HTDemoAuthor alloc] init];
    libai.name = @"李白";
    
    return libai;
}

- (HTDemoSubscriber *)generateSubscriber {
    HTDemoSubscriber *subsriber = [[HTDemoSubscriber alloc] init];
    NSUUID *UUID = [NSUUID UUID];
    NSString *UUIDString = [UUID UUIDString];
    subsriber.name = [NSString stringWithFormat:@"name: %@ no: %@", @"杜甫", UUIDString];
    subsriber.email = @"dufu@163.com";
    subsriber.address = [self demoAddress];
    subsriber.favoriteAuthors = @[[self authorLibai]];
    
    return subsriber;
}

- (HTDemoAddress *)demoAddress {
    HTDemoAddress *address = [[HTDemoAddress alloc] init];
    address.province = @"Zhejiang";
    address.city = @"Hangzhou";
    
    return address;
}

- (NSArray *)subsrcibers:(NSInteger)count {
    NSMutableArray *subscribers = [NSMutableArray array];
    for (int i = 0; i < count; i ++) {
        [subscribers addObject:[self generateSubscriber]];
    }
    
    return subscribers;
}

#pragma mark - Old Response Descriptors 

- (RKResponseDescriptor *)oldCommentResponseDescriptor {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[HTComment class]];
    [mapping addAttributeMappingsFromArray:@[@"skuInfo", @"content", @"frontUserName", @"createTime"]];

    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping method:[HTCommentRequest requestMethod] pathPattern:[HTCommentRequest requestUrl] keyPath:@"data" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];

    return responseDescriptor;
}

- (RKResponseDescriptor *)oldArticleResponseDescriptor {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[HTArticle class]];
    [mapping addAttributeMappingsFromArray:@[@"title", @"body", @"publicationDate"]];

    RKObjectMapping *relationShipMapping = [RKObjectMapping mappingForClass:[HTAuthor class]];
    [relationShipMapping addAttributeMappingsFromArray:@[@"name", @"email"]];

    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"author"
                                                                            toKeyPath:@"author"
                                                                          withMapping:relationShipMapping]];

    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping method:[HTArticleRequest requestMethod] pathPattern:[HTArticleRequest requestUrl] keyPath:@"data" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];

    return responseDescriptor;
}

- (RKResponseDescriptor *)oldAuthorResponseDescriptor {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[HTAuthor class]];
    [mapping addAttributeMappingsFromArray:[HTDemoHelper getPropertyList:[HTAuthor class]]];
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping method:RKRequestMethodGET pathPattern:[HTAuthorRequest requestUrl] keyPath:@"data" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    return responseDescriptor;
}

- (RKResponseDescriptor *)oldGetPostInfoResponseDescriptor {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[HTDemoPhotoInfo class]];
    [mapping addAttributeMappingsFromArray:[HTDemoHelper getPropertyList:[HTDemoPhotoInfo class]]];
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping method:RKRequestMethodPOST pathPattern:[HTDemoGetUserPhotoListRequest requestUrl] keyPath:@"photolist" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    return responseDescriptor;
}

- (void)showResultSilently:(BOOL)isSuccess operation:(RKObjectRequestOperation *)operation result:(RKMappingResult *)result error:(NSError *)error {
    NSString *title = isSuccess ? @"请求成功" : @"请求失败";
    RKErrorMessage *errorMessage =  [[error.userInfo objectForKey:RKObjectMapperErrorObjectsKey] firstObject];
    NSString *message = isSuccess ? [NSString stringWithFormat:@"请求成功的结果信息: %@", result] : [NSString stringWithFormat:@"错误信息: %@, error Message信息: %@", [error localizedDescription], errorMessage];
    
    NSLog(@"title: %@ error Message: %@", title, message);
}

@end
