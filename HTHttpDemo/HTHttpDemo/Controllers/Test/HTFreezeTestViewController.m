//
//  HTFreezeRequestViewController.m
//  HTHttpDemo
//
//  Created by Wangliping on 16/02/04.
//  Copyright © 2015年 NetEase. All rights reserved.
//

#import "HTFreezeTestViewController.h"
#import "RKDemoUserInfo.h"
#import "HTNetworking.h"
#import <HTNetworking/Freeze/HTFrozenRequest.h>
#import <HTNetworking/Core/HTHTTPRequestOperation.h>
#import "HTDemoResponse.h"
#import "HTDemoHelper.h"
#import <HTNetworking/Freeze/HTFreezeRequestHelper.h>
#import <HTNetworking/Cache/HTDatabaseHelper.h>
#import <HTNetworking/Cache/HTCacheDBHelper.h>
#import <HTNetworking/RestKit/Network/NSURLRequest+RKRequest.h>

@interface HTFreezeTestViewController () <HTFreezeManagerProtocol>

@property (nonatomic, strong) RKObjectManager *manager;

@end

@implementation HTFreezeTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Freeze Request Demo";
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onFrozenRequestSuccessful:) name:kHTResendFrozenRequestSuccessfulNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onFrozenRequestFailure:) name:kHTResendFrozenRequestFailureNotification object:nil];
    
    //    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(back:)];
    
    [self enableFreezeFeature];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)enableFreezeFeature {
    RKObjectMapping *mapping1 = [RKObjectMapping mappingForClass:[RKDemoUserInfo class]];
    [mapping1 addAttributeMappingsFromArray:@[@"userId", @"balance"]];
    
    [mapping1 addAttributeMappingsFromDictionary:@{@"version":@"name", @"status":@"password"}];
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping1 method:RKRequestMethodGET pathPattern:@"/user" keyPath:@"data" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    RKObjectMapping *errorMapping = [RKObjectMapping mappingForClass:[RKErrorMessage class]];
    [errorMapping addPropertyMapping:[RKAttributeMapping attributeMappingFromKeyPath:nil toKeyPath:@"errorMessage"]];
    RKResponseDescriptor *errorResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:errorMapping method:RKRequestMethodGET pathPattern:nil keyPath:@"code" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassClientError)];
    
    // 添加ResponseDescriptor.
#if TARGET_IPHONE_SIMULATOR
    RKObjectManager *manager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:@"http://localhost:3000"]];
    
#elif TARGET_OS_IPHONE
    // TbaseURL不可以是http://10.240.153.132:3000/ 也就是后面的"/"需要去掉
    RKObjectManager *manager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:@"http://10.240.153.132:3000"]];
#endif
    
    [manager addResponseDescriptor:responseDescriptor];
    [manager addResponseDescriptor:errorResponseDescriptor];
    
    // 注册对@"text/plain"的解析
    [RKMIMETypeSerialization registerClass:[RKNSJSONSerialization class] forMIMEType:@"text/plain"];
    
    // Note: 同时开启Cache测试数据库是否存在冲突.
    [manager registerRequestOperationClass:[HTHTTPRequestOperation class]];
    [HTCacheManager sharedManager];
    
    self.manager = manager;
    [HTFreezeManager setupWithDelegate:self isStartMonitoring:YES];
}

#pragma mark - Notifications

- (void)onFrozenRequestSuccessful:(NSNotification *)notify {
    NSDictionary *userInfo = [notify userInfo];
    
    RKObjectRequestOperation *operation = [userInfo objectForKey:kHTResendFrozenNotificationOperationItem];
    RKMappingResult *result = [userInfo objectForKey:kHTResendFrozenNotificationResultItem];
    
    [self showResult:YES operation:operation result:result error:nil];
}

- (void)onFrozenRequestFailure:(NSNotification *)notify {
    NSDictionary *userInfo = [notify userInfo];
    
    RKObjectRequestOperation *operation = [userInfo objectForKey:kHTResendFrozenNotificationOperationItem];
    NSError *error = [userInfo objectForKey:kHTResendFrozenNotificationErrorItem];
    
    [self showResult:NO operation:operation result:nil error:error];
}

#pragma mark - Load Data

- (NSArray *)generateMethodNameList {
    return @[@"getUserInfoFromServer",
             @"testFreezeRequest",
             @"restoreRequestManually",
             @"testSaveAndLoadFrozenRequest",
             @"testSaveAndLoadCachedRequest"];
}

#pragma mark - HTFreezeManagerProtocol

- (RKObjectManager *)objectManagerForRequest:(NSURLRequest *)request {
    return _manager;
}

#pragma mark - Test

- (void)getUserInfoFromServer {
    // 获取数据.
    [_manager getObject:nil path:@"/user" parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        NSLog(@"success : %@", mappingResult);
        [self showResult:YES operation:operation result:mappingResult error:nil];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        // You can access the model object used to construct the `NSError` via the `userInfo`
        RKErrorMessage *errorMessage =  [[error.userInfo objectForKey:RKObjectMapperErrorObjectsKey] firstObject];
        NSLog(@"errorMessage: %@", errorMessage);
        
        [self showResult:NO operation:operation result:nil error:error];
    }];
}

- (void)testFreezeRequest {
    NSMutableURLRequest *request = [_manager requestWithObject:nil method:RKRequestMethodGET path:@"/user" parameters:nil];
    
    // Note: 这里可以对Request进行配置.
    request.ht_freezeId = [request ht_defaultFreezeId];
    request.ht_canFreeze = YES;
    request.ht_freezePolicyId = HTFreezePolicySendFreezeAutomatically;
    
    RKObjectRequestOperation *operation = [_manager objectRequestOperationWithRequest:request success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        NSLog(@"success");
        
        [self showResult:YES operation:operation result:mappingResult error:nil];
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        // You can access the model object used to construct the `NSError` via the `userInfo`
        RKErrorMessage *errorMessage =  [[error.userInfo objectForKey:RKObjectMapperErrorObjectsKey] firstObject];
        NSLog(@"%@", errorMessage);
        
        [self showResult:NO operation:operation result:nil error:error];
    }];
    [_manager enqueueObjectRequestOperation:operation];
}


- (void)testFreezeRequestEx {
    // 添加ObjectMapping
    RKObjectMapping *mapping1 = [RKObjectMapping mappingForClass:[RKDemoUserInfo class]];
    [mapping1 addAttributeMappingsFromArray:@[@"userId", @"balance"]];
    
    [mapping1 addAttributeMappingsFromDictionary:@{@"version":@"name", @"status":@"password"}];
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping1 method:RKRequestMethodGET pathPattern:@"/user" keyPath:@"data" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    RKObjectMapping *errorMapping = [RKObjectMapping mappingForClass:[RKErrorMessage class]];
    [errorMapping addPropertyMapping:[RKAttributeMapping attributeMappingFromKeyPath:nil toKeyPath:@"errorMessage"]];
    RKResponseDescriptor *errorResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:errorMapping method:RKRequestMethodGET pathPattern:nil keyPath:@"code" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassClientError)];
    
    // 添加ResponseDescriptor.
    RKObjectManager *manager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:@"http://localhost:3000"]];
    [manager addResponseDescriptor:responseDescriptor];
    [manager addResponseDescriptor:errorResponseDescriptor];
    
    // 注册对@"text/plain"的解析
    [RKMIMETypeSerialization registerClass:[RKNSJSONSerialization class] forMIMEType:@"text/plain"];
    
    NSMutableURLRequest *request = [manager requestWithObject:nil method:RKRequestMethodGET path:@"/user" parameters:nil];
    
    // Note: 这里可以对Request进行配置, 例如进行freeze相关的控制.
    request.ht_freezeId = @"lwang";
    request.ht_canFreeze = YES;
    request.ht_freezePolicyId = HTFreezePolicySendFreezeAutomatically;
    
    RKObjectRequestOperation *operation = [manager objectRequestOperationWithRequest:request success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        NSLog(@"success");
        
        [self showResult:YES operation:operation result:mappingResult error:nil];
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        BOOL isFrozen = operation.HTTPRequestOperation.request.ht_isFrozen;
        if (isFrozen) {
            NSLog(@"Request is frozen: %@", @(isFrozen));
        }
        
        // You can access the model object used to construct the `NSError` via the `userInfo`
        RKErrorMessage *errorMessage =  [[error.userInfo objectForKey:RKObjectMapperErrorObjectsKey] firstObject];
        NSLog(@"%@", errorMessage);
        
        [self showResult:NO operation:operation result:nil error:error];
    }];
    [manager enqueueObjectRequestOperation:operation];
}

- (void)restoreRequestManually {
    
}

- (void)testSaveAndLoadFrozenRequest {
    // Note: Category中的数据不会通过NSKeyedArchiver保存, 因为NSKeyArchiver应该是只会根据属性列表来存取数据的.
    //例如，我们在NSURLRequest的Category中定义了一些新的属性, 那么这个是保存不了的，必须通过一些额外的方法来获取所有动态添加的property.
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://localhost:3000"]];
    request.ht_freezeId = @"It is a test freezeId";
    request.ht_canFreeze = YES;
    request.rk_requestTypeName = @"RequestOperationNotExist";
    request.ht_cacheKey = @"It is a test cache Key";
    
    HTFrozenRequest *htRequest = [[HTFrozenRequest alloc] init];
    htRequest.requestKey = request.ht_freezeId;
    htRequest.request = request;
    [htRequest save];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        HTFrozenRequest *queriedRequest = [[HTFreezeManager sharedInstance] queryByFreezeId:request.ht_freezeId];
        NSURLRequest *httpRequest = queriedRequest.request;
        
        NSString *requestOperationClassName = httpRequest.rk_requestTypeName;
        NSLog(@"%@", requestOperationClassName);
        
        
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:request];
        NSURLRequest *unArchiveRequest =  [NSKeyedUnarchiver unarchiveObjectWithData:data];
        NSLog(@"%@", unArchiveRequest.ht_freezeId);
        
        // Note: 通过这种方法可以获取到Category相关的属性. 但是分辨不出哪个是Category的属性，哪个不是.
        NSArray *propertyList = [HTDemoHelper getPropertyList:[NSURLRequest class]];
        for (NSString *propertyName in propertyList) {
            NSLog(@"propertyValue: %@", propertyName);
            
            NSObject *value = [request valueForKey:propertyName];
            NSLog(@"propertyValue: %@", value);
        }
        
        // 这里获取到的属性不包括Category中的属性，但我不明白为什么. 按道理和获取[NSURLRequest class]应该是一样的.
        // Note: 解释上面一行注释中提到的原因，首先，class_copyPropertyList一定可以获取到Category中定义的属性；其次，这里传对象的时候，实际上取的是NSMutableRequest的类.
        // 也就是说，当NSURLRequest存在Category定义的属性时，NSMutableRequest的property list中并不包含这些. (原因需要继续查.)
        // 按照官方文档的说法，Any properties declared by superclasses are not included.
        // 但奇怪的是，除了那些Category外，其余的Property还是都包含在获取到的属性列表中.
        // 原因是NSMutableRequest比较特殊，基类定义的property全部都包含在子类NSMutableRequest中了.
        NSDictionary *propertyValueList = [HTDemoHelper propertiesOf:request];
        for (NSString *propertyName in propertyValueList) {
            NSLog(@"propertyName: %@", propertyName);
        }
        
        
        NSDictionary *categoryPropertyList = [HTFreezeRequestHelper categoryPropertiesOf:request];
        NSLog(@"%@", categoryPropertyList);
    });
}

- (void)testSaveAndLoadCachedRequest {
    // 经过测试发现，如果保存的是NSURLResponse的子类，例如HTWZP那样自定义的一个子类，从持久化存储中可以获取到正确的数据, 仍然获取到子类的对象，不会有任何错误.
    NSURL *url = [NSURL URLWithString:@"http://localhost:3000"];
    HTDemoResponse *httpResponse = [[HTDemoResponse alloc] initWithURL:url statusCode:200 HTTPVersion:@"HTTP/1.1" headerFields:@{@"testHeaderKey":@"testHeaderValue"}];
    NSData *responseData = [self testBody];
    
    HTCachedResponse *cachedResponse = [[HTCachedResponse alloc] init];
    cachedResponse.response = [[NSCachedURLResponse alloc] initWithResponse:httpResponse data:responseData];
    cachedResponse.requestKey = @"SpecialRequestKey";
    [cachedResponse save];
    
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ where %@ = '%@'", HTCacheTable, HTCacheColumnRequestKey, cachedResponse.requestKey];
    HTCachedResponse *queriedResponse = [[HTCachedResponse alloc] init];
    [HT_HTTP_DB executeQuery:sql result:^(FMResultSet *rs, BOOL *end) {
        [queriedResponse updateFromCursor:rs];
    }];
    
    HTDemoResponse *response = (HTDemoResponse *)queriedResponse.response.response;
    BOOL isResponseType = [response isKindOfClass:[HTDemoResponse class]];
    NSString *mimeType = [response MIMEType];
    NSLog(@"MIMEType: %@, isCurrentResponseType: %@", mimeType, @(isResponseType));
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:cachedResponse.response];
    NSCachedURLResponse *unArchiveResponse =  [NSKeyedUnarchiver unarchiveObjectWithData:data];
    NSLog(@"%@", [unArchiveResponse.response MIMEType]);
}

- (NSData *)testBody {
    NSMutableDictionary* dictionary = [NSMutableDictionary dictionary];
    [dictionary setObject:@(300) forKey:@"itemId"];
    
    NSError* error = nil;
    NSData* body = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:&error];
    if (error) {
        NSLog(@"%s error %@", __func__, error);
        return nil;
    }
    
    return body;
}


#pragma mark - Helper Methods

- (void)showResult:(BOOL)isSuccess operation:(RKObjectRequestOperation *)operation result:(RKMappingResult *)result error:(NSError *)error {
    NSString *title = isSuccess ? @"请求成功" : @"请求失败";
    RKErrorMessage *errorMessage =  [[error.userInfo objectForKey:RKObjectMapperErrorObjectsKey] firstObject];
    NSString *message = isSuccess ? [NSString stringWithFormat:@"请求成功的结果信息: %@", result] : [NSString stringWithFormat:@"错误信息: %@, error Message信息: %@", [error localizedDescription], errorMessage];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alertView show];
}

@end
