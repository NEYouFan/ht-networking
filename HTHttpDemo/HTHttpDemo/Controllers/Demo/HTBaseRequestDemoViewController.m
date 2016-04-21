//
//  HTWrapRequestTestViewController.m
//  HTHttpDemo
//
//  Created by Wang Liping on 15/10/9.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import "HTBaseRequestDemoViewController.h"
#import "HTNetworking.h"

#import "RKConcreteHTTPRequestOperation.h"
#import "HTDemoGetUserInfoRequest.h"
#import "HTDemoGetPhotoListRequest.h"
#import "HTDemoGetUserPhotoListRequest.h"
#import "HTDemoUploadImageRequest.h"
#import "HTDemoCacheRequest.h"
#import "HTDemoFreezeRequest.h"
#import "HTDemoValidResultBlockRequest.h"
#import "HTMockUserInfoRequest.h"
#import "HTDemoCustomizeRequest.h"
#import "HTDemoErrorInfo.h"
#import "RKDemoUserInfo.h"
#import "HTDemoWithTypeRequest.h"

static NSString * const HTBaseRequestDemoBaseUrl = @"http://localhost:3000";

@interface HTBaseRequestDemoViewController () <HTRequestDelegate>

@end

@implementation HTBaseRequestDemoViewController

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"HTBaseRequest Demo";
    
    [RKMIMETypeSerialization registerClass:[RKNSJSONSerialization class] forMIMEType:@"text/plain"];
}

- (RKResponseDescriptor *)myErrorResponseDescriptor {
    RKObjectMapping *errorMapping = [RKObjectMapping mappingForClass:[HTDemoErrorInfo class]];
    [errorMapping addAttributeMappingsFromArray:@[@"code", @"message"]];
    RKResponseDescriptor *errorResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:errorMapping method:RKRequestMethodAny pathPattern:nil keyPath:nil statusCodes:nil];
    
    return errorResponseDescriptor;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Load Data

- (NSArray *)generateMethodNameList {
    // 测试Server参见 https://git.hz.netease.com/hzwangliping/TrainingServer
    return @[@"demoSendRequest",
             @"demoSendRequestWithDelegate",
             @"demoSendRequestWithParams",
             @"demoSendPostRequest",
             @"demoUploadImageRequest",
             @"demoSendRequestWithCache",
             @"demoSendRequestWithValidResultBlock",
             @"demoSendRequestWithFreeze",
             @"demoSendRequestWithMockInfo",
             @"demoSendCustomTypeRequest",
             @"demoSendRequestWithCustomizeRequest",
             @"demoSendRequestWithAdvanceCachePolicy",
             @"demoSendRequestInAnotherManger",
             @"demoSendRequestInAnotherMangerWithRegister",
             @"demoSendRequestWithSimpleResponse",
             @"demoSendRequestWithRAC",
             @"demoShowMoreResult",
             @"demoCancelRequest",
             @"demoCancelAllRequests"];
}

#pragma mark - Test Methods

/**
 *  展示最简单的发送请求的方法.
 *  示例Server与设置方法参见: https://git.hz.netease.com/hzwangliping/TrainingServer
 *  请求信息: Method: GET URL: http://localhost:3000/user. 返回数据: MIMEType:@"text/plain"
 *  正确返回时JSON数据为: {"data":{"userId":1854002,"balance":500,"updateTime":1429515081463,"version":26,"status":0,"blockBalance":600},"code":200}
 *  错误返回时JSON数据为: {"errorMessage":"It is a test error msg", "code":200}
 *  可以统一JSON格式为: {errorMessage:"asdfadfsa", "data":{...}, code=404}
 */
- (void)demoSendRequest {
    HTDemoGetUserInfoRequest *request = [[HTDemoGetUserInfoRequest alloc] init];
    [request startWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self showResult:YES operation:operation result:mappingResult error:nil];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self showResult:NO operation:operation result:nil error:error];
    }];
}

/**
 *  展示通过Delegate接收发送请求回调的方法.
 */
- (void)demoSendRequestWithDelegate {
    HTDemoGetUserInfoRequest *request = [[HTDemoGetUserInfoRequest alloc] init];
    request.requestDelegate = self;
    [request start];
}

/**
 *  展示带参数的请求发送的方法.
 */
- (void)demoSendRequestWithParams {
    HTDemoGetPhotoListRequest *request = [[HTDemoGetPhotoListRequest alloc] init];
    request.limit = 20;
    request.offset = 0;
    request.requestDelegate = self;
    [request start];
}

/**
 *  展示Post请求发送的方法. 完全等同于普通请求.
 */
- (void)demoSendPostRequest {
    HTDemoGetUserPhotoListRequest *request = [[HTDemoGetUserPhotoListRequest alloc] init];
    request.requestDelegate = self;
    [request start];
}

/**
 *  展示如何上传图片.
 */
- (void)demoUploadImageRequest {
    HTDemoUploadImageRequest *request = [[HTDemoUploadImageRequest alloc] init];
    request.image = [UIImage imageNamed:@"13.jpg"];
    [request startWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self showResult:YES operation:operation result:mappingResult error:nil];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self showResult:NO operation:operation result:nil error:error];
    }];
}

/**
 *  展示如何发送带cache的请求. 发送方式完全相同，cache的设置参见HTDemoCacheRequest.
 */
- (void)demoSendRequestWithCache {
    HTDemoCacheRequest *request = [[HTDemoCacheRequest alloc] init];
    [request startWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self showResult:YES operation:operation result:mappingResult error:nil];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self showResult:NO operation:operation result:nil error:error];
    }];
}

/**
 *  展示如何发送带validResultBlock的请求. 具体配置见HTDemoValidResultBlockRequest.
 */
- (void)demoSendRequestWithValidResultBlock {
    HTDemoValidResultBlockRequest *request = [[HTDemoValidResultBlockRequest alloc] init];
    [request startWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self showResult:YES operation:operation result:mappingResult error:nil];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self showResult:NO operation:operation result:nil error:error];
    }];
}

/**
 *  展示如何发送允许Freeze的请求.
 */
- (void)demoSendRequestWithFreeze {
    HTDemoFreezeRequest *request = [[HTDemoFreezeRequest alloc] init];
    [request startWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self showResult:YES operation:operation result:mappingResult error:nil];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self showResult:NO operation:operation result:nil error:error];
    }];
}

/**
 *  展示如何发送Mock数据的请求. 该功能可以模拟服务器返回的数据，便于测试与调试.
 */
- (void)demoSendRequestWithMockInfo {
    [HTBaseRequest enableMockTest];
    HTMockUserInfoRequest *request = [[HTMockUserInfoRequest alloc] init];
    request.mockJsonFilePath = [[NSBundle mainBundle] pathForResource:@"HTMockAuthorize" ofType:@"json"];
    [request startWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self showResultSilently:YES operation:operation result:mappingResult error:nil];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self showResultSilently:NO operation:operation result:nil error:error];
    }];
}

- (void)demoSendRequestWithMock {
    HTMockUserInfoRequest *request = [[HTMockUserInfoRequest alloc] init];
    request.enableMock = YES;
    request.mockJsonFilePath = [[NSBundle mainBundle] pathForResource:@"getProductProfile" ofType:@"json"];
    request.mockBlock = ^(NSURLRequest *urlRequest) {
        urlRequest.ht_mockResponse = [HTMockURLResponse defaultMockResponseWithUrl:urlRequest.URL];
    };
    [request startWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self showResultSilently:YES operation:operation result:mappingResult error:nil];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self showResultSilently:NO operation:operation result:nil error:error];
    }];
}



/**
 *  展示如何发送不同请求类型的请求，即使用者可以使用自己的私有协议来发送请求，只需要实现一个利用该私有协议发送请求的类并且遵循RKHTTPRequestOperationProtocol协议即可.
 *  典型的例子是严选中使用了自己的wzp协议进行网络请求的发送.
 */
- (void)demoSendCustomTypeRequest {
    HTDemoWithTypeRequest *request = [[HTDemoWithTypeRequest alloc] init];
    [RKRequestTypeOperation registerClass:[RKConcreteHTTPRequestOperation class] forRequestType:[request requestType]];
    request.requestDelegate = self;
    [request start];
}

/**
 *  演示如何在创建请求之后再对请求进行各种配置，尤其适用于使用NEI Mobile自动生成的请求，因为NEI Mobile自动生成的请求不可以在实现文件中覆写基类的方法来实现定制.
 */
- (void)demoSendRequestWithCustomizeRequest {
    HTDemoCustomizeRequest *request = [[HTDemoCustomizeRequest alloc] init];
    request.enableMock = YES;
    request.customRequestTimeoutInterval = 3600;
    request.configNeedCustomRequest = YES;
    request.cacheId = HTCachePolicyCacheFirst;
    request.customCacheKey = @"我就要写一个特殊的Key";
    // ... 进行更多配置
    
    [request startWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self showResult:YES operation:operation result:mappingResult error:nil];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self showResult:NO operation:operation result:nil error:error];
    }];
}

/**
 *  演示如何先从cache中获取数据，然后再保证从服务器获取最新的数据并且保存到cache中.
 */
- (void)demoSendRequestWithAdvanceCachePolicy {
    HTDemoGetUserPhotoListRequest *request = [[HTDemoGetUserPhotoListRequest alloc] init];
    request.cacheId = HTCachePolicyCacheFirst;
    [request startWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self showResultSilently:YES operation:operation result:mappingResult error:nil];
        if (operation.HTTPRequestOperation.response.ht_isFromCache) {
            [self getUserPhotoListWithWritingCache];
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self showResultSilently:NO operation:operation result:nil error:error];
    }];
}

/**
 *  演示发送这样的请求，不从Cache中读数据，但是每次获取到的数据都保存到Cache中.
 */
- (void)getUserPhotoListWithWritingCache {
    HTDemoGetUserPhotoListRequest *request = [[HTDemoGetUserPhotoListRequest alloc] init];
    request.cacheId = HTCachePolicyWriteOnly;
    [request startWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self showResultSilently:YES operation:operation result:mappingResult error:nil];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self showResultSilently:NO operation:operation result:nil error:error];
    }];
}

/**
 *  演示如何使用另一个RKObjectMananger实例来发送请求.
 */
- (void)demoSendRequestInAnotherManger {
    NSURL *baseURL = [NSURL URLWithString:HTBaseRequestDemoBaseUrl];
    RKObjectManager *manager = [RKObjectManager managerWithBaseURL:baseURL];
    [manager addResponseDescriptor:[HTDemoGetUserInfoRequest responseDescriptor]];
    
    HTDemoGetUserInfoRequest *request = [[HTDemoGetUserInfoRequest alloc] init];
    request.requestDelegate = self;
    [request startWithManager:manager];
}

/**
 *  演示如何通过注册的方式将请求的response descriptor添加到另一个RKObjectManager, 并且使用另一个RKObjectManager发送请求.
 */
- (void)demoSendRequestInAnotherMangerWithRegister {
    NSURL *baseURL = [NSURL URLWithString:HTBaseRequestDemoBaseUrl];
    RKObjectManager *manager = [RKObjectManager managerWithBaseURL:baseURL];
    [HTDemoGetUserInfoRequest registerInMananger:manager];
    
    HTDemoGetUserInfoRequest *request = [[HTDemoGetUserInfoRequest alloc] init];
    request.requestDelegate = self;
    [request startWithManager:manager];
}

/**
 *  演示如何取消一个请求; 实质是撤销这个请求的调度，但如果请求已经发出，其实是不能撤销的, 只是收到的结果会表明该请求已被撤销.
 */
- (void)demoCancelRequest {
    HTDemoGetUserPhotoListRequest *request = [[HTDemoGetUserPhotoListRequest alloc] init];
    [request startWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self showResultSilently:YES operation:operation result:mappingResult error:nil];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self showResultSilently:NO operation:operation result:nil error:error];
    }];

    [request cancel];
}

/**
 *  演示如何获取到更多不同层面的结果.
 */
- (void)demoShowMoreResult {
    HTDemoGetUserPhotoListRequest *request = [[HTDemoGetUserPhotoListRequest alloc] init];
    [request startWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self showResultSilently:YES operation:operation result:mappingResult error:nil];
        NSLog(@"Response Object: %@, Response String; %@, URL: %@, response Header : %@", operation.responseObject,
              operation.HTTPRequestOperation.responseString, operation.HTTPRequestOperation.request.URL.absoluteString,
              operation.HTTPRequestOperation.response.allHeaderFields);
        NSLog(@"HTTP BODY: %@, response Data : %@", operation.HTTPRequestOperation.request.HTTPBody,
              operation.HTTPRequestOperation.responseData);
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self showResultSilently:NO operation:operation result:nil error:error];
    }];
}

- (void)sendRequest {
    HTDemoGetUserPhotoListRequest *request = [[HTDemoGetUserPhotoListRequest alloc] init];
    [request startWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        // 请求成功, 从mappingResult中获取Model信息
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        // 请求失败，从error中获取错误信息
    }];
}


/**
 *  展示如何通过HTBaseRequest提供的信号来触发请求.
 */
- (void)demoSendRequestWithRAC {    
    [HTBaseRequest enableMockTest];
    HTMockUserInfoRequest *request = [[HTMockUserInfoRequest alloc] init];
    RACSignal *signal = [request signalStart];
    [signal subscribeNext:^(id x) {
        RACTupleUnpack(RKObjectRequestOperation *operationRe, RKMappingResult *mappingResultRe, HTBaseRequest *requestRe) = (RACTuple *)x;
        NSLog(@"%@ %@ %@", operationRe, mappingResultRe, requestRe);

    } error:^(NSError *error) {
        NSLog(@"%@", request);
    } completed:^{
        NSLog(@"finished");
    }];
    
    NSLog(@"%@", request);
}

/**
 *  演示如何取消所有请求.
 */
- (void)demoCancelAllRequests {
    for (int i = 0; i < 3; i ++) {
        HTDemoGetUserInfoRequest *request1 = [[HTDemoGetUserInfoRequest alloc] init];
        HTDemoGetPhotoListRequest *request2 = [[HTDemoGetPhotoListRequest alloc] init];
        HTDemoGetUserPhotoListRequest *request3 = [[HTDemoGetUserPhotoListRequest alloc] init];
        request1.requestDelegate = self;
        request2.requestDelegate = self;
        request3.requestDelegate = self;
        [request1 start];
        [request2 start];
        [request3 start];
    }
    
    [HTBaseRequest cancelAllRequests];
}

#pragma mark - Show Result

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

- (void)showResultSilently:(BOOL)isSuccess operation:(RKObjectRequestOperation *)operation result:(RKMappingResult *)result error:(NSError *)error {
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
    
    NSLog(@"title: %@ error Message: %@", title, message);
}

#pragma mark - HTRequestDelegate

- (void)htRequestFinished:(HTBaseRequest *)request {
    [self showResult:YES operation:request.requestOperation result:[request requestResult] error:request.requestOperation.error];
}

- (void)htRequestFailed:(HTBaseRequest *)request {
    [self showResult:NO operation:request.requestOperation result:[request requestResult] error:request.requestOperation.error];
}

@end
