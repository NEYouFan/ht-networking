//
//  FirstViewController.m
//  HTHttpDemo
//
//  Created by NetEase on 15/7/23.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import "HTRKDemoViewController.h"
#import "RKDemoUserInfo.h"
#import "HTNetworking.h"
#import <HTNetworking/HTHttp/Core/HTMockHTTPRequestOperation.h>
#import "HTMockUserInfo.h"
#import "HTMainFreezeDemoViewController.h"
#import "HTCacheDemoViewController.h"
#import "HTAdvanceFeatureDemoViewController.h"

@interface HTRKDemoViewController ()

@end

@implementation HTRKDemoViewController

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.navigationItem.title = @"RKObjectManager Demo";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Load Data 

- (NSArray *)generateMethodNameList {
    // 测试Server参见 https://git.hz.netease.com/hzwangliping/TrainingServer
    return @[@"demoGetUserInfoWithRKObjectMananger",
             @"demoCustomRequestWithRKObjectMananger",
             @"demoSendRequestSynchronously",
             @"demoSendRequestWithAbsoluteUrl",
             @"demoSendRequestWithValidBlock",
             @"demoSendHttpsRequest",
             @"demoSendRequestWithMockData",
             @"demoSendRequestWithCache",
             @"demoSendRequestWithFreezeEnabled",
             @"gotoFreezeDemo",
             @"gotoCacheDemo",
             @"gotoAdvanceFeatureDemo"];
}

#pragma mark - Demo Methods

/**
 *  展示通过RKObjectManager发起请求的基本步骤与工作流程.
 *  示例Server与设置方法参见: https://git.hz.netease.com/hzwangliping/TrainingServer
 *  请求信息: Method: GET URL: http://localhost:3000/user. 返回数据: MIMEType:@"text/plain" 
 *  正确返回时JSON数据为: {"data":{"userId":1854002,"balance":500,"updateTime":1429515081463,"version":26,"status":0,"blockBalance":600},"code":200}
 *  错误返回时JSON数据为: {"errorMessage":"It is a test error msg", "code":200}
 *  可以统一JSON格式为: {errorMessage:"asdfadfsa", "data":{...}, code=404}
 */
- (void)demoGetUserInfoWithRKObjectMananger {
    // 创建RKObjectMapping与RKResponseDescriptor.
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[RKDemoUserInfo class]];
    // 同名的Key直接通过addAttributeMappingsFromArray添加.
    [mapping addAttributeMappingsFromArray:@[@"userId", @"balance"]];
    // Key不对应时通过addAttributeMappingsFromDictionary添加，参数Dictionary中的key与返回的JSON Key对应，value与Model中的property名字对应.
    [mapping addAttributeMappingsFromDictionary:@{@"version":@"name", @"status":@"password"}];
    // 创建RKResponseDescriptor时，指明pathPattern(即对应的URL Relative Path), 请求的Method(本例为GET), keyPath(即待映射的JSON内容对应的key)和status code.
    // POST请求类似.
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping method:RKRequestMethodGET pathPattern:@"/user" keyPath:@"data" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    // 如果希望对错误码进行映射，则可以创建并添加一个errorResponseDescriptor.
    RKObjectMapping *errorMapping = [RKObjectMapping mappingForClass:[RKErrorMessage class]];
    [errorMapping addPropertyMapping:[RKAttributeMapping attributeMappingFromKeyPath:nil toKeyPath:@"errorMessage"]];
    RKResponseDescriptor *errorResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:errorMapping method:RKRequestMethodGET pathPattern:nil keyPath:@"code" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassClientError)];
    
    // 创建RKObjectManager对象.
    RKObjectManager *manager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:@"http://localhost:3000"]];

    // 添加ResponseDescriptor.
    [manager addResponseDescriptor:responseDescriptor];
    [manager addResponseDescriptor:errorResponseDescriptor];
    
    // 注册对@"text/plain"的解析. 如果MIMEType本身就是RKMIMETypeJSON，那么不需要额外注册解析类.
    [RKMIMETypeSerialization registerClass:[RKNSJSONSerialization class] forMIMEType:@"text/plain"];
    
    // 发请求获取数据并输出结果.
    // 本例中不需要任何参数，如果需要传递参数，则指定parameters参数即可.
    // getObject参数一般传nil, 仅当通过RKRequestDescriptor描述请求参数时才需要赋值，可以参见后续的例子或者RestKit的Demo.
    [manager getObject:nil path:@"/user" parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self showResult:YES operation:operation result:mappingResult error:nil];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self showResult:NO operation:operation result:nil error:error];
    }];
}

/**
 *  展示通过RKObjectManager发起请求之前对请求进行定制的基本步骤与工作流程.
 *  请求的API同demoGetUserInfoWithRKObjectMananger.
 */
- (void)demoCustomRequestWithRKObjectMananger {
    // 创建RKObjectMapping与RKResponseDescriptor.
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[RKDemoUserInfo class]];
    // 同名的Key直接通过addAttributeMappingsFromArray添加.
    [mapping addAttributeMappingsFromArray:@[@"userId", @"balance"]];
    // Key不对应时通过addAttributeMappingsFromDictionary添加，参数Dictionary中的key与返回的JSON Key对应，value与Model中的property名字对应.
    [mapping addAttributeMappingsFromDictionary:@{@"version":@"name", @"status":@"password"}];
    // 创建RKResponseDescriptor时，指明pathPattern(即对应的URL Relative Path), 请求的Method(本例为GET), keyPath(即待映射的JSON内容对应的key)和status code.
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping method:RKRequestMethodGET pathPattern:@"/user" keyPath:@"data" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    // 如果希望对错误码进行映射，则可以创建并添加一个errorResponseDescriptor.
    RKObjectMapping *errorMapping = [RKObjectMapping mappingForClass:[RKErrorMessage class]];
    [errorMapping addPropertyMapping:[RKAttributeMapping attributeMappingFromKeyPath:nil toKeyPath:@"errorMessage"]];
    RKResponseDescriptor *errorResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:errorMapping method:RKRequestMethodGET pathPattern:nil keyPath:@"code" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassClientError)];
    
    // 创建RKObjectManager对象.
    RKObjectManager *manager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:@"http://localhost:3000"]];
    
    // 添加ResponseDescriptor.
    [manager addResponseDescriptor:responseDescriptor];
    [manager addResponseDescriptor:errorResponseDescriptor];
    
    // 注册对@"text/plain"的解析. 如果MIMEType本身就是RKMIMETypeJSON，那么不需要额外注册解析类.
    [RKMIMETypeSerialization registerClass:[RKNSJSONSerialization class] forMIMEType:@"text/plain"];

    // Note: 创建NSURLRequest对象.
    // 此处可以创建任意自定义的NSURLRequest对象，通常建议通过RKObjectMananger的requestWithObject方法来创建, 也可以通过别的方法自行创建任意有效的请求.
    NSMutableURLRequest *request = [manager requestWithObject:nil method:RKRequestMethodGET path:@"/user" parameters:nil];
    
    // 创建请求后可以对该请求进行自定义. 例如下面设置request的超时时间.
    request.timeoutInterval = 120;
    // 也可以通过HTHTTP开放出来的Category设置cache等一系列相关属性.
    request.ht_cacheExpireTimeInterval = 3600;
    
    // 创建RKObjectRequestOperation.
    RKObjectRequestOperation *operation = [manager objectRequestOperationWithRequest:request success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self showResult:YES operation:operation result:mappingResult error:nil];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self showResult:NO operation:operation result:nil error:error];
    }];
    
    // 让Mananger调度operation, 则会开始请求的发送.
    [manager enqueueObjectRequestOperation:operation];
}

/**
 *  展示通过RKObjectManager同步发送请求的过程.
 *  请求的API同demoGetUserInfoWithRKObjectMananger.
 */
- (void)demoSendRequestSynchronously {
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
    
    // 通过Manager创建RKObjectRequestOperation对象.
    RKObjectRequestOperation *operation = [manager appropriateObjectRequestOperationWithObject:nil method:RKRequestMethodGET path:@"/user" parameters:nil];
    [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self showResult:YES operation:operation result:mappingResult error:nil];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self showResult:NO operation:operation result:nil error:error];
    }];
    
    // Start Operation并且等待请求结束.
    // Note: 这仅仅是一个Demo, 正常情况下不允许阻塞主线程进行请求的发送.
    [operation start];
    [operation waitUntilFinished];
}

/**
 *  展示当请求的baseURL与RKObjectMananger的baseURL不同时如何发送请求.
 *  请求的API同demoGetUserInfoWithRKObjectMananger.
 *
 *  主要的区别在于，创建RKResponseDescriptor和使用RKObjectManager发请求的地方都需要使用完整的Url Path.
 */
- (void)demoSendRequestWithAbsoluteUrl {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[RKDemoUserInfo class]];
    [mapping addAttributeMappingsFromArray:@[@"userId", @"balance"]];
    [mapping addAttributeMappingsFromDictionary:@{@"version":@"name", @"status":@"password"}];
    
    // RKObjectMananger的baseURL为:http://baidu:3000.
    RKObjectManager *manager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:@"http://baidu:3000"]];
    [RKMIMETypeSerialization registerClass:[RKNSJSONSerialization class] forMIMEType:@"text/plain"];
    
    // Path Pattern传递全路径http://localhost:3000/user.
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping method:RKRequestMethodGET pathPattern:@"http://localhost:3000/user" keyPath:@"data" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [manager addResponseDescriptor:responseDescriptor];
    
    // 参数path也必须传递全路径@"http://localhost:3000/user".
    [manager getObject:nil path:@"http://localhost:3000/user" parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self showResult:YES operation:operation result:mappingResult error:nil];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self showResult:NO operation:operation result:nil error:error];
    }];
}

/**
 *  展示如何通过设置validResultBlock来满足如下需求: 请求返回的结果非法时从failure block中回调.
 *  请求的API同demoGetUserInfoWithRKObjectMananger.
 *
 *  通常情况下，只有status code < 200 或者 status code > 400时，才会从failure block中回调；其余情况都会从success block回调.
 */
- (void)demoSendRequestWithValidBlock {
#warning 整理测试Case：具体哪些情况下会默认走failure block回调; 哪些情况下会走success block回调但是mapping result为空.
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[RKDemoUserInfo class]];
    [mapping addAttributeMappingsFromDictionary:@{@"version":@"name", @"status":@"password"}];
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping method:RKRequestMethodGET pathPattern:@"/user" keyPath:@"data" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    RKObjectMapping *errorMapping = [RKObjectMapping mappingForClass:[RKErrorMessage class]];
    [errorMapping addPropertyMapping:[RKAttributeMapping attributeMappingFromKeyPath:nil toKeyPath:@"errorMessage"]];
    RKResponseDescriptor *errorResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:errorMapping method:RKRequestMethodGET pathPattern:nil keyPath:@"code" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassClientError)];
    
    RKObjectManager *manager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:@"http://localhost:3000"]];
    [RKMIMETypeSerialization registerClass:[RKNSJSONSerialization class] forMIMEType:@"text/plain"];
    [manager addResponseDescriptor:responseDescriptor];
    [manager addResponseDescriptor:errorResponseDescriptor];
    
    // 示例：设置validResultBlock. 当该block被调用并且返回NO的时候，请求的发送会走failure分支的回调.
    // mananger中设置的validResultBlock对整个manager都有效，这里演示的是，如果mappingResult中没有结果或者仅仅有error Message, 则视为无效结果，会从failure block回调.
    manager.validResultBlock = ^(RKObjectRequestOperation *operation) {
        RKMappingResult *mappingResult = operation.mappingResult;
        if ([mappingResult count] == 0) {
            return NO;
        }
        
        // Mapping Result仅仅有Error Message, 无效.
        if (1 == [mappingResult count] && [[mappingResult firstObject] isKindOfClass:[RKErrorMessage class]]) {
            return NO;
        }
        
        return YES;
    };
    
    // 如果仅仅希望对某个RequestOperation设置validResultBlock, 则可以创建RKObjectRequestOperation对象后设置其validResultBlock属性.
    // 利用RKObjectRequestOperation直接发送请求的方式可以参见本类中方法`demoCustomRequestWithRKObjectMananger`, 设置validResultBlock属性的方式同上.
    
    [manager getObject:nil path:@"/user" parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self showResult:YES operation:operation result:mappingResult error:nil];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self showResult:NO operation:operation result:nil error:error];
    }];
}

/**
 *  展示如何发送一个HTTPS的请求.
 *  请求的API同demoGetUserInfoWithRKObjectMananger.
 *
 *  Note: 由于暂时缺乏自己的测试HTTPS服务器，所以借助了运维项目的测试服务器. 测试地址为"https://106.2.44.242". 后续需要替换成为自己的测试服务器.
 */
- (void)demoSendHttpsRequest {
#warning 需要搭建自己的HTTPS测试服务器.
    RKMapping *mapping = [HTMockUserInfo ht_modelMapping];
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping method:RKRequestMethodPOST pathPattern:@"/authorize" keyPath:@"data" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    RKObjectManager *manager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:@"https://106.2.44.242"]];
    // 该测试服务器的MIME Type为@"text/html", 实际返回的仍然是JSON.
    [RKMIMETypeSerialization registerClass:[RKNSJSONSerialization class] forMIMEType:@"text/html"];
    [manager addResponseDescriptor:responseDescriptor];
    
    // 根据实际情况设置ASSecurityPolicy.
    // 对于该测试服务器, 暂时只支持自建证书. 如果服务器证书合法，不需要改变securityPolicy的默认值.
    manager.requestProvider.securityPolicy.allowInvalidCertificates = YES;
    manager.requestProvider.securityPolicy.validatesDomainName = NO;
    
//    // 也可以按照实际情况创建正确的securityPolicy. 创建与设置方法如下:
//    AFSecurityPolicy * securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
//    //    AFSecurityPolicy * securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModePublicKey];
//    securityPolicy.allowInvalidCertificates = YES;
//    securityPolicy.validatesDomainName = NO;
//    manager.requestProvider.securityPolicy = securityPolicy;
    
    NSDictionary *params = @{@"clientId" : @(1), @"clientSecret" : @"secret1", @"account" : @"测试时替换为自己的账号", @"password" : @"测试时替换为自己的密码"};
    [manager postObject:nil path:@"/authorize" parameters:params success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self showResult:YES operation:operation result:mappingResult error:nil];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self showResult:NO operation:operation result:nil error:error];
    }];
}

/**
 *  展示如何Mock数据进行测试.
 * 
 *  当仅仅有返回数据格式的定义而没有对应的服务器实现时，可以通过Mock数据进行测试. 本例的Mock数据见Test/TestData Group下的HTMockAuthorize.json文件.
 */
- (void)demoSendRequestWithMockData {
    // 添加ObjectMapping
    RKMapping *mapping = [HTMockUserInfo ht_modelMapping];
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping method:RKRequestMethodPOST pathPattern:@"/authorize" keyPath:@"data" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    // 添加ResponseDescriptor.
    RKObjectManager *manager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:@"http://localhost:3000"]];
    [manager addResponseDescriptor:responseDescriptor];
    [manager registerRequestOperationClass:[HTMockHTTPRequestOperation class]];
  
#warning HTBaseRequest中需要提供获取Absolute Request Url的方法.
    NSURLRequest *request = [manager requestWithObject:nil method:RKRequestMethodPOST path:@"/authorize" parameters:nil];
    request.ht_mockBlock = ^(NSURLRequest *mockRequest) {
        mockRequest.ht_mockJsonFilePath = [[NSBundle mainBundle] pathForResource:@"HTMockAuthorize" ofType:@"json"];
        mockRequest.ht_mockResponse = [HTMockURLResponse defaultMockResponseWithUrl:mockRequest.URL];
    };
    
    RKObjectRequestOperation *operation = [manager objectRequestOperationWithRequest:request success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self showResult:YES operation:operation result:mappingResult error:nil];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self showResult:NO operation:operation result:nil error:error];
    }];
    
    [manager enqueueObjectRequestOperation:operation];
}

/**
 *  展示通过RKObjectManager发起请求之前对请求进行定制的基本步骤与工作流程.
 *  请求的API同demoGetUserInfoWithRKObjectMananger.
 */
- (void)demoSendRequestWithCache {
    // 创建RKObjectMapping与RKResponseDescriptor.
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[RKDemoUserInfo class]];
    // 同名的Key直接通过addAttributeMappingsFromArray添加.
    [mapping addAttributeMappingsFromArray:@[@"userId", @"balance"]];
    // Key不对应时通过addAttributeMappingsFromDictionary添加，参数Dictionary中的key与返回的JSON Key对应，value与Model中的property名字对应.
    [mapping addAttributeMappingsFromDictionary:@{@"version":@"name", @"status":@"password"}];
    // 创建RKResponseDescriptor时，指明pathPattern(即对应的URL Relative Path), 请求的Method(本例为GET), keyPath(即待映射的JSON内容对应的key)和status code.
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping method:RKRequestMethodGET pathPattern:@"/user" keyPath:@"data" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    // 如果希望对错误码进行映射，则可以创建并添加一个errorResponseDescriptor.
    RKObjectMapping *errorMapping = [RKObjectMapping mappingForClass:[RKErrorMessage class]];
    [errorMapping addPropertyMapping:[RKAttributeMapping attributeMappingFromKeyPath:nil toKeyPath:@"errorMessage"]];
    RKResponseDescriptor *errorResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:errorMapping method:RKRequestMethodGET pathPattern:nil keyPath:@"code" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassClientError)];
    
    // 创建RKObjectManager对象.
    RKObjectManager *manager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:@"http://localhost:3000"]];
    
    // 添加ResponseDescriptor.
    [manager addResponseDescriptor:responseDescriptor];
    [manager addResponseDescriptor:errorResponseDescriptor];
    
    // 注册对@"text/plain"的解析. 如果MIMEType本身就是RKMIMETypeJSON，那么不需要额外注册解析类.
    [RKMIMETypeSerialization registerClass:[RKNSJSONSerialization class] forMIMEType:@"text/plain"];
    
    // Note: 创建NSURLRequest对象.
    // 此处可以创建任意自定义的NSURLRequest对象，通常建议通过RKObjectMananger的requestWithObject方法来创建, 也可以通过别的方法自行创建任意有效的请求.
    NSMutableURLRequest *request = [manager requestWithObject:nil method:RKRequestMethodGET path:@"/user" parameters:nil];
    
    // 创建请求后可以对该请求进行自定义. 例如下面设置request的超时时间.
    request.timeoutInterval = 120;
    // 也可以通过HTHTTP开放出来的Category设置cache等一系列相关属性.
    request.ht_cacheExpireTimeInterval = 3600;
    
    // 创建RKObjectRequestOperation.
    RKObjectRequestOperation *operation = [manager objectRequestOperationWithRequest:request success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self showResult:YES operation:operation result:mappingResult error:nil];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self showResult:NO operation:operation result:nil error:error];
    }];
    
    // 让Mananger调度operation, 则会开始请求的发送.
    [manager enqueueObjectRequestOperation:operation];
}

/**
 *  展示如何在发送请求前开启冻结请求功能.
 *
 *  请求的API同demoGetUserInfoWithRKObjectMananger.
 */
- (void)demoSendRequestWithFreezeEnabled {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[RKDemoUserInfo class]];
    [mapping addAttributeMappingsFromArray:@[@"userId", @"balance"]];
    [mapping addAttributeMappingsFromDictionary:@{@"version":@"name", @"status":@"password"}];
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping method:RKRequestMethodGET pathPattern:@"/user" keyPath:@"data" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
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
    
    // Note: 如果希望在冻结请求重新发送时收到通知以及提供RKObjectMananger, 则传递合适的Delegate.
    [HTFreezeManager setupWithDelegate:nil isStartMonitoring:YES];
    
    NSMutableURLRequest *request = [manager requestWithObject:nil method:RKRequestMethodGET path:@"/user" parameters:nil];
    
    // Note: 这里可以对Request进行配置.
    request.ht_freezeId = [request ht_defaultFreezeId];
    request.ht_canFreeze = YES;
    request.ht_freezePolicyId = HTFreezePolicySendFreezeAutomatically;
    
    RKObjectRequestOperation *operation = [manager objectRequestOperationWithRequest:request success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self showResult:YES operation:operation result:mappingResult error:nil];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self showResult:NO operation:operation result:nil error:error];
    }];
    
    [manager enqueueObjectRequestOperation:operation];
}

#pragma mark - Jump to Other Demo

- (void)gotoFreezeDemo {
    HTMainFreezeDemoViewController *vc = [[HTMainFreezeDemoViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)gotoCacheDemo {
    HTCacheDemoViewController *vc = [[HTCacheDemoViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)gotoAdvanceFeatureDemo {
    HTAdvanceFeatureDemoViewController *vc = [[HTAdvanceFeatureDemoViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Helper Methods

- (void)showResult:(BOOL)isSuccess operation:(RKObjectRequestOperation *)operation result:(RKMappingResult *)result error:(NSError *)error {
    if (isSuccess) {
        NSLog(@"Request %@ is finished successful", operation.HTTPRequestOperation.request.URL);
    } else {
        NSLog(@"Reqeust %@ failes with error: %@", operation.HTTPRequestOperation.request.URL, [error localizedDescription]);
        
        // You can access the model object used to construct the `NSError` via the `userInfo`
        RKErrorMessage *errorMessage =  [[error.userInfo objectForKey:RKObjectMapperErrorObjectsKey] firstObject];
        NSLog(@"ErrorMsg from Server is %@", errorMessage);
    }
    
    NSString *title = isSuccess ? @"请求成功" : @"请求失败";
    RKErrorMessage *errorMessage =  [[error.userInfo objectForKey:RKObjectMapperErrorObjectsKey] firstObject];
    NSString *message = isSuccess ? [NSString stringWithFormat:@"请求成功的结果信息: %@", result] : [NSString stringWithFormat:@"错误信息: %@, error Message信息: %@", [error localizedDescription], errorMessage];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alertView show];
}




- (void)demoWorkFlow {
    // 创建RKObjectMapping与RKResponseDescriptor.
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[RKDemoUserInfo class]];
    [mapping addAttributeMappingsFromArray:@[@"userId", @"balance"]];

    NSIndexSet *statusCodeSet = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful);
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping
                                                                                            method:RKRequestMethodGET
                                                                                       pathPattern:@"/user"
                                                                                           keyPath:@"data"
                                                                                       statusCodes:statusCodeSet];
    // 创建RKObjectManager对象并添加ResponseDescriptor.
    RKObjectManager *manager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:@"http://localhost:3000"]];
    [manager addResponseDescriptor:responseDescriptor];
    
    // 发请求获取数据并输出结果. 本例中不需要任何参数，如果需要传递参数，则指定parameters参数即可.
    [manager getObject:nil path:@"/user" parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self showResult:YES operation:operation result:mappingResult error:nil];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self showResult:NO operation:operation result:nil error:error];
    }];
}

- (void)demoWorkFlowWithRKObjectRequestOperation {
    // 添加ObjectMapping
    RKMapping *mapping = [HTMockUserInfo ht_modelMapping];
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping method:RKRequestMethodPOST
                                                                                       pathPattern:@"/authorize" keyPath:@"data"
                                                                                       statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    // 添加ResponseDescriptor.
    RKObjectManager *manager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:@"http://localhost:3000"]];
    [manager addResponseDescriptor:responseDescriptor];
    [manager registerRequestOperationClass:[HTMockHTTPRequestOperation class]];
    
    NSMutableURLRequest *request = [manager requestWithObject:nil method:RKRequestMethodPOST path:@"/authorize" parameters:nil];
    // 创建请求后可以对该请求进行自定义. 例如下面设置request的超时时间.
    request.timeoutInterval = 120;
    // 也可以通过HTHTTP开放出来的Category设置cache等一系列相关属性.
    request.ht_cacheExpireTimeInterval = 3600;
    
    RKObjectRequestOperation *operation = [manager objectRequestOperationWithRequest:request success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self showResult:YES operation:operation result:mappingResult error:nil];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self showResult:NO operation:operation result:nil error:error];
    }];
    
    [manager enqueueObjectRequestOperation:operation];
}



//
//
//// 注册对@"text/plain"的解析. 如果MIMEType本身就是RKMIMETypeJSON，那么不需要额外注册解析类.
//[RKMIMETypeSerialization registerClass:[RKNSJSONSerialization class] forMIMEType:@"text/plain"];


@end
