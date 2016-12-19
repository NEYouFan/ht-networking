//
//  HTWrapRequestTestViewController.m
//  HTHttpDemo
//
//  Created by Wang Liping on 15/10/9.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import "HTBaseRequestTestViewController.h"
#import "HTNetworking.h"
#import "HTDemoGetUserInfoRequest.h"
#import "HTDemoWithTypeRequest.h"
#import "HTDemoGetPhotoListRequest.h"
#import "HTDemoGetUserPhotoListRequest.h"
#import "HTDemoComplextRequest1.h"
#import "HTDemoErrorMsgRequest.h"
#import "HTDemoErrorInfo.h"
#import "RKDemoUserInfo.h"
#import "HTDemoHelper.h"
#import "HTArticle.h"
#import "HTDemoAuthor.h"
#import "HTDemoAddress.h"
#import "HTDemoArticle.h"
#import "HTDemoSubscriber.h"
#import "HTDemoPerson.h"
#import "HTDemoCycleA.h"
#import "HTDemoCycleB.h"
#import "HTDemoCycleC.h"
#import "HTDemoArticleEx.h"
#import "HTTestValidParamRequest.h"
#import "HTMockUserInfoRequest.h"
#import "HTTestRefreshTokenRequest.h"
#import "HTMockUserInfo.h"

static NSString * const HTBaseRequestDemoBaseUrl = @"http://localhost:3000";

@interface HTBaseRequestTestViewController () <HTRequestDelegate, UIAlertViewDelegate>

@property (nonatomic, copy) NSString *accessToken;
@property (nonatomic, copy) NSString *refreshToken;

@end

@implementation HTBaseRequestTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"HTBaseRequest Demo";
    
    self.accessToken = @"111";
    self.refreshToken = @"1111111";

    [HTBaseRequest enableMockTest];
}

// 对应的JSON如下，即result的value是一个字典.
// {"result": {"code":205, "message":"this is a test message by liping"},
//  "skuSpecList": {
//    }
//  }
//- (RKResponseDescriptor *)myErrorResponseDescriptor {
//    RKObjectMapping *errorMapping = [RKObjectMapping mappingForClass:[RKEErrorInfo class]];
//    [errorMapping addAttributeMappingsFromArray:@[@"code", @"message"]];
//
//    // 如果statusCodes设置为nil, 那么无论HTTP的status code是2xx还是4xx, 都能够正确的进行解析.
//    return [RKResponseDescriptor responseDescriptorWithMapping:errorMapping method:RKRequestMethodAny pathPattern:nil keyPath:@"result" statusCodes:nil];
//}

// 对应的JSON为
// {"code":205,
//  "data":{
//   }
// }
//
- (RKResponseDescriptor *)myErrorResponseDescriptor {
    // 方法1：对code进行Map, Code保存在RKEErorInfo中. 当然这里的RKEErrorInfo是包含了两个属性，如果只需要code的话，那么可以只包含一个属性.
    RKObjectMapping *errorMapping = [RKObjectMapping mappingForClass:[HTDemoErrorInfo class]];
    [errorMapping addPropertyMapping:[RKAttributeMapping attributeMappingFromKeyPath:nil toKeyPath:@"code"]];
    RKResponseDescriptor *errorResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:errorMapping method:RKRequestMethodAny pathPattern:nil keyPath:@"code" statusCodes:nil];
    
    return errorResponseDescriptor;
    
#if 0
    // 方法2: 对于最外层的结果进行Map, Code保存在RKEErrorInfo中. 但是不太好的是，如果某个请求的code不是表示error, 那么会被错误的解析. (但其实并不影响其他的解析的)
    RKObjectMapping *errorMapping = [RKObjectMapping mappingForClass:[RKEErrorInfo class]];
    [errorMapping addAttributeMappingsFromArray:@[@"code"]];
    RKResponseDescriptor *errorResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:errorMapping method:RKRequestMethodAny pathPattern:nil keyPath:nil statusCodes:nil];
    
    return errorResponseDescriptor;
#endif
    
    
#if 0
    // 方法3：对code进行Map, 不能直接转成String或者Number. 因为这样的话就不需要RestKit了. 那么建议用方法1. 方法3不work.
    // https://github.com/RestKit/RestKit/issues/1290
    RKObjectMapping *errorMapping = [RKObjectMapping mappingForClass:[NSNumber class]];
    //    [errorMapping addPropertyMapping:[RKAttributeMapping attributeMappingFromKeyPath:nil toKeyPath:@"code"]];
    RKResponseDescriptor *errorResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:errorMapping method:RKRequestMethodAny pathPattern:nil keyPath:@"code" statusCodes:nil];
    
    return errorResponseDescriptor;
#endif
}

//- (RKResponseDescriptor *)myErrorResponseDescriptor {
//    // 方法3：对code进行Map, 不能直接转成String或者Number. 因为这样的话就不需要RestKit了. 那么建议用方法1. 方法3不work.
//    // https://github.com/RestKit/RestKit/issues/1290
//    RKObjectMapping *errorMapping = [RKObjectMapping mappingForClass:[NSNumber class]];
//    //    [errorMapping addPropertyMapping:[RKAttributeMapping attributeMappingFromKeyPath:nil toKeyPath:@"code"]];
//    RKResponseDescriptor *errorResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:errorMapping method:RKRequestMethodAny pathPattern:nil keyPath:@"code" statusCodes:nil];
//
//    return errorResponseDescriptor;
//}


- (RKResponseDescriptor *)myErrorResponseDescriptor2 {
    // 方法1：对code进行Map, Code保存在RKEErorInfo中. 当然这里的RKEErrorInfo是包含了两个属性，如果只需要code的话，那么可以只包含一个属性.
    //    RKObjectMapping *errorMapping = [RKObjectMapping mappingForClass:[RKEErrorInfo class]];
    //    [errorMapping addPropertyMapping:[RKAttributeMapping attributeMappingFromKeyPath:nil toKeyPath:@"message"]];
    //    RKResponseDescriptor *errorResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:errorMapping method:RKRequestMethodAny pathPattern:nil keyPath:@"message" statusCodes:nil];
    //
    //    return errorResponseDescriptor;
    
    // TODO: 这种方式可以用，但是key是null，最好能够再改进一下.
    RKObjectMapping *errorMapping = [RKObjectMapping mappingForClass:[HTDemoErrorInfo class]];
    [errorMapping addAttributeMappingsFromArray:@[@"code", @"message"]];
    RKResponseDescriptor *errorResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:errorMapping method:RKRequestMethodAny pathPattern:nil keyPath:nil statusCodes:nil];
    
    return errorResponseDescriptor;
}

- (RKResponseDescriptor *)myErrorResponseDescriptor3 {
    // 方法1：对code进行Map, Code保存在RKEErorInfo中. 当然这里的RKEErrorInfo是包含了两个属性，如果只需要code的话，那么可以只包含一个属性.
    //    RKObjectMapping *errorMapping = [RKObjectMapping mappingForClass:[RKEErrorInfo class]];
    //    [errorMapping addPropertyMapping:[RKAttributeMapping attributeMappingFromKeyPath:nil toKeyPath:@"message"]];
    //    RKResponseDescriptor *errorResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:errorMapping method:RKRequestMethodAny pathPattern:nil keyPath:@"message" statusCodes:nil];
    //
    //    return errorResponseDescriptor;
    
    // TODO: 这种方式可以用，但是key是null，最好能够再改进一下.
    RKObjectMapping *errorMapping = [RKObjectMapping mappingForClass:[RKDemoUserInfo class]];
    [errorMapping addAttributeMappingsFromArray:@[@"name"]];
    RKResponseDescriptor *errorResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:errorMapping method:RKRequestMethodAny pathPattern:@"/specTest" keyPath:nil statusCodes:nil];
    
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
    return @[@"getUserInfoRequest",
             @"getUserInfoRequestWithDelegate",
             @"getUserPhotoList",
             @"getPhotoList",
             @"uploadImageRequest",
             @"baseUrlRequest",
             @"cancelAllRequests",
             @"sendRequestInAnotherManger",
             @"sendRequestInAnotherMangerWithRegister",
             @"testHTDemoSpecList",
             @"testRequestWithErrorMsg",
             @"testRequestDescriptor",
             @"getUserInfoRequestWithRequestType",
             @"getUserPhotoListWithCachePolicy",
             @"getUserPhotoListWithCacheInterval",
             @"getMockUserInfo",
             @"testValidParams",
             @"commonStoneWorkFlowWithBlock",
             @"testDefaultMapping"];
}

#pragma mark - Test Methods

- (BOOL)isValidToken:(NSString *)token {
    return [token length] > 10;
}

- (BOOL)isValidRefreshToken:(NSString *)refreshToken {
    return [refreshToken length] > 10;
}

// 模拟登录场景
- (void)testLogin:(NSInteger)tag {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"testLogin" message:@"需要登陆" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alertView.tag = tag;
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 1:
        {
            self.accessToken = @"11111111111";
            self.refreshToken = @"22222222222";
            if (alertView.tag == 2) {
                [self commonStoneWorkFlowWithBlock];
            } else {
                [self testStoneWorkFlow];
            }

            
        }
        break;
        
        default:
        break;
    }
}

/**
 *  需求: 便捷描述下列workflow.
 *  Workflow步骤如下: 
    1. 发请求之前判断参数token是否合法；
    2. 如果token不合法，
    2.1 如果refreshToken不合法，则弹出登录对话框进行登录
    2.1.1 如果登录失败，结束.
    2.1.2 如果登录成功，则可以获取到token, 转到3;
    2.2 如果refreshToken合法,发送refreshToken获取新的token;
    2.2.1 请求报错，错误码表示refreshToken过期，那么转到2.1.
    2.2.2 请求成功，转到3, 使用获取到的token发送请求.
    3. 如果token合法，则发送请求;
    3.1 如果请求报错，错误码表示token过期，那么转到第2步继续；
    3.2 如果请求成功，结束, 到success回调.
 *  这些逻辑描述会放在HTAdvanceFeatureDemoViewController中.
 *  注意问题：严选中做类似封装的时候, 会有所有权和内存泄漏的问题.
 */
- (void)testStoneWorkFlow {
    // 正常的发请求怎么写？
    if (![self isValidToken:self.accessToken]) {
        // accessToken非法，则需要获取accessToken.
        if (![self isValidToken:self.refreshToken]) {
            // refreshToken非法，需要登录.
            [self testLogin:1];
        } else {
            // 获取accessToken.
            HTTestRefreshTokenRequest *request = [[HTTestRefreshTokenRequest alloc] init];
            request.refreshToken = self.refreshToken;
            [request startWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                // 成功，则重新走整个流程.
                // TODO: 需要预防可能的无限递归.
                HTMockUserInfo *userInfo = [mappingResult firstObject];
                if ([userInfo isKindOfClass:[HTMockUserInfo class]]) {
                    self.accessToken = userInfo.accessToken;
                    [self testStoneWorkFlow];
                }
            } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                // refreshToken获取失败, 需要登录.
                [self testLogin:1];
            }];
        }
    } else {
        HTTestValidParamRequest *request = [[HTTestValidParamRequest alloc] init];
        request.token = self.accessToken;
        [request startWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            [self showResult:YES operation:operation result:mappingResult error:nil];
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            if (error.code == 602) {
                // Token非法. 清空这个token或者修改下过期时间; 避免直接在block中发请求.
                self.accessToken = @"";
                [self testStoneWorkFlow];
            } else {
                [self showResult:NO operation:operation result:nil error:error];
            }
        }];
    }
}

/**
 *  重新登录后，如果请求还失败，那么直接重新请求登录.
 */
- (void)testStoneWorkFlowAfterReLogin {
    HTTestValidParamRequest *request = [[HTTestValidParamRequest alloc] init];
    request.token = self.accessToken;
    [request startWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self showResult:YES operation:operation result:mappingResult error:nil];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        if (error.code == 602) {
            [self testLogin:1];
        } else {
            [self showResult:NO operation:operation result:nil error:error];
        }
        
        [self showResult:NO operation:operation result:nil error:error];
    }];
}

/**
 *  分页不需要额外做逻辑，每次重新发送新的请求好了; 
 *  这里只展示通过分页接口一次性获取所有请求的方法；优先级低.
 */
- (void)testStonePagesWorkFlow {

}

/**
 *  多个请求同时执行的case. 这个Demo先写在Stone中. 暂时不列在此处.
 */
- (void)testMyChangeAndTask {
    // 我的变更和工单要在一起获取
}

- (void)testStoneWorkFlowWithSignals {
    RACSignal *loginSignal;
    RACSignal *validTokenSignal;
    RACSignal *validRefreshTokenSignal;
    RACSignal *refreshTokenSignal;
    RACSignal *requestSignal;
    RACSignal *sendValidTokenSignal;

    RACSignal *combineSignal = [RACSignal if:validTokenSignal then:sendValidTokenSignal else:[RACSignal if:validRefreshTokenSignal then:refreshTokenSignal else:loginSignal]];
//    combineSignal
    
    [combineSignal flattenMap:^RACStream *(id value) {
        return requestSignal;
    }];
    
    
    
    // 先弄简单的; 发request; 如果失败，则获取token再发request; 如果成功，结束.
//    RACSignal *level1 = [refreshTokenSignal flattenMap:^RACStream *(id value) {
//        return requestSignal;
//    }];
//    
//    RACSignal *level2 = [level1 catchTo:loginSignal];
//    
//    
//    RACSignal *combinedSignal = [requestSignal catchTo:level1];
}

#pragma mark - 

- (void)commonStoneSendRequestWithBlock:(HTBaseRequest * (^)(NSString *accessToken))buildRequestBlock
                                success:(void (^)(RKObjectRequestOperation *operation, RKMappingResult *mappingResult))success
                                failure:(void (^)(RKObjectRequestOperation *operation, NSError *error))failure {
    if (nil == buildRequestBlock || nil == success || nil == failure) {
        return;
    }
    
    if (![self isValidToken:self.accessToken]) {
        // accessToken非法，则需要获取accessToken.
        if (![self isValidToken:self.refreshToken]) {
            // refreshToken非法，需要登录.
            [self testLogin:2];
        } else {
            // 获取accessToken.
            HTTestRefreshTokenRequest *request = [[HTTestRefreshTokenRequest alloc] init];
            request.refreshToken = self.refreshToken;
            [request startWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                // 成功，则重新走整个流程.
                // TODO: 这个判断可以移入HTTestRefreshTokenRequest的validResultBlock中.
                HTMockUserInfo *userInfo = [mappingResult firstObject];
                if ([userInfo isKindOfClass:[HTMockUserInfo class]]) {
                    self.accessToken = userInfo.accessToken;
                    if (![self isValidToken:self.accessToken]) {
                        [self testLogin:2];
                    }
                    
                    [self commonStoneSendRequestWithBlock:buildRequestBlock success:success failure:failure];
                }
            } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                // refreshToken获取失败, 需要登录.
                [self testLogin:2];
            }];
        }
    } else {
        HTBaseRequest *originRequest = buildRequestBlock(self.accessToken);
        [originRequest startWithSuccess:success failure:^(RKObjectRequestOperation *operation, NSError *error) {
            if (error.code == 602) {
                // Token非法. 清空这个token或者修改下过期时间; 避免直接在block中发请求.
                self.accessToken = @"";
                [self commonStoneSendRequestWithBlock:buildRequestBlock success:success failure:failure];
            } else if (nil != failure) {
                failure(operation, error);
            }
        }];
    }
}

- (void)commonStoneWorkFlowWithBlock {
    [self commonStoneSendRequestWithBlock:^HTBaseRequest *(NSString *accessToken) {
        HTTestValidParamRequest *request = [[HTTestValidParamRequest alloc] init];
        request.token = self.accessToken;
        
        return request;
    } success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self showResult:YES operation:operation result:mappingResult error:nil];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self showResult:NO operation:operation result:nil error:error];
    }];
}

- (void)commonStoneSendRequest:(HTTestValidParamRequest *)originRequest
                       success:(void (^)(RKObjectRequestOperation *operation, RKMappingResult *mappingResult))success
                       failure:(void (^)(RKObjectRequestOperation *operation, NSError *error))failure {
    if (![self isValidToken:self.accessToken]) {
        // accessToken非法，则需要获取accessToken.
        if (![self isValidToken:self.refreshToken]) {
            // refreshToken非法，需要登录.
            [self testLogin:1];
        } else {
            // 获取accessToken.
            HTTestRefreshTokenRequest *request = [[HTTestRefreshTokenRequest alloc] init];
            request.refreshToken = self.refreshToken;
            [request startWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                // 成功，则重新走整个流程.
                // TODO: 需要预防可能的无限递归.
                HTMockUserInfo *userInfo = [mappingResult firstObject];
                if ([userInfo isKindOfClass:[HTMockUserInfo class]]) {
                    self.accessToken = userInfo.accessToken;
                    [self commonStoneSendRequest:originRequest success:success failure:failure];
                }
            } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                // refreshToken获取失败, 需要登录.
                [self testLogin:1];
            }];
        }
    } else {
        originRequest.token = self.accessToken;
        [originRequest startWithSuccess:success failure:^(RKObjectRequestOperation *operation, NSError *error) {
            if (error.code == 602) {
                // Token非法. 清空这个token或者修改下过期时间; 避免直接在block中发请求.
                self.accessToken = @"";
                [self commonStoneSendRequest:originRequest success:success failure:failure];
            } else if (nil != failure) {
                failure(operation, error);
            }
        }];
    }
}

- (void)commonStoneWorkFlow {
    HTTestValidParamRequest *request = [[HTTestValidParamRequest alloc] init];
    request.token = self.accessToken;
    [self commonStoneSendRequest:request success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self showResult:YES operation:operation result:mappingResult error:nil];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self showResult:NO operation:operation result:nil error:error];
    }];
}

/**
 *  重新登录后，如果请求还失败，那么直接重新请求登录.
 */
- (void)sendCurrentPageRequest {
    HTTestValidParamRequest *request = [[HTTestValidParamRequest alloc] init];
    request.token = self.accessToken;
    [request startWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self showResult:YES operation:operation result:mappingResult error:nil];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        if (error.code == 602) {
            [self testLogin:1];
        } else {
            [self showResult:NO operation:operation result:nil error:error];
        }
        
        [self showResult:NO operation:operation result:nil error:error];
    }];
}



#pragma mark -

- (void)testValidParams {
    HTTestValidParamRequest *request = [[HTTestValidParamRequest alloc] init];
    request.token = @"1111";
    if ([request.token length] < 10) {
        HTMockUserInfoRequest *mockInfoRequest = [[HTMockUserInfoRequest alloc] init];
        [mockInfoRequest startWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            HTMockUserInfo *userInfo = [mappingResult firstObject];
            if ([userInfo isKindOfClass:[HTMockUserInfo class]]) {
                request.token = userInfo.accessToken;
                [request startWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                    [self showResult:YES operation:operation result:mappingResult error:nil];
                } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                    [self showResult:NO operation:operation result:nil error:error];
                }];
            }
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            [self showResult:NO operation:operation result:nil error:error];
        }];
    } else {
        [request startWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            [self showResult:YES operation:operation result:mappingResult error:nil];
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            [self showResult:NO operation:operation result:nil error:error];
        }];
    }
}

- (void)sendRequest:(HTTestValidParamRequest *)request withValidToken:(NSString *)token success:(void (^)(RKObjectRequestOperation *operation, RKMappingResult *mappingResult))success failure:(void (^)(RKObjectRequestOperation *operation, NSError *error))failure {
    if ([request.token length] < 10) {
        HTMockUserInfoRequest *mockInfoRequest = [[HTMockUserInfoRequest alloc] init];
        [mockInfoRequest startWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            HTMockUserInfo *userInfo = [mappingResult firstObject];
            if ([userInfo isKindOfClass:[HTMockUserInfo class]]) {
                request.token = userInfo.accessToken;
                [request startWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                    [self showResult:YES operation:operation result:mappingResult error:nil];
                } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                    [self showResult:NO operation:operation result:nil error:error];
                }];
            }
        } failure:failure];
    } else {
        request.token = token;
        [request startWithSuccess:success failure:^(RKObjectRequestOperation *operation, NSError *error) {
            HTMockUserInfoRequest *mockInfoRequest = [[HTMockUserInfoRequest alloc] init];
            [mockInfoRequest startWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                HTMockUserInfo *userInfo = [mappingResult firstObject];
                if ([userInfo isKindOfClass:[HTMockUserInfo class]]) {
                    request.token = userInfo.accessToken;
                    [request startWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                        [self showResult:YES operation:operation result:mappingResult error:nil];
                    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                        [self showResult:NO operation:operation result:nil error:error];
                    }];
                }
            } failure:failure];
        }];
    }
}

- (void)getUserInfoRequest {
    HTDemoGetUserInfoRequest *request = [[HTDemoGetUserInfoRequest alloc] init];
    [request startWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self showResult:YES operation:operation result:mappingResult error:nil];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self showResult:NO operation:operation result:nil error:error];
    }];
}

- (void)getUserInfoRequestWithDelegate {
    HTDemoGetUserInfoRequest *request = [[HTDemoGetUserInfoRequest alloc] init];
    request.requestDelegate = self;
    [request start];
}

- (void)getPhotoList {
    HTDemoGetPhotoListRequest *request = [[HTDemoGetPhotoListRequest alloc] init];
    request.requestDelegate = self;
    [request start];
}

- (void)getUserPhotoList {
    HTDemoGetUserPhotoListRequest *request = [[HTDemoGetUserPhotoListRequest alloc] init];
    request.requestDelegate = self;
    [request start];
}

- (void)getUserPhotoListWithCachePolicy {
    // 演示如何先从cache中获取数据，然后再保证从服务器获取最新的数据并且保存到cache中.
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

- (void)getUserPhotoListWithWritingCache {
    HTDemoGetUserPhotoListRequest *request = [[HTDemoGetUserPhotoListRequest alloc] init];
    request.cacheId = HTCachePolicyWriteOnly;
    [request startWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self showResultSilently:YES operation:operation result:mappingResult error:nil];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self showResultSilently:NO operation:operation result:nil error:error];
    }];
}

- (void)getUserPhotoListWithCacheInterval {
    HTDemoGetUserPhotoListRequest *request = [[HTDemoGetUserPhotoListRequest alloc] init];
    request.cacheId = HTCachePolicyCacheFirst;
    [request startWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self showResultSilently:YES operation:operation result:mappingResult error:nil];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self showResultSilently:NO operation:operation result:nil error:error];
    }];
}

- (void)getMockUserInfo {
    [HTBaseRequest enableMockTest];
    HTMockUserInfoRequest *request = [[HTMockUserInfoRequest alloc] init];
    [request startWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self showResultSilently:YES operation:operation result:mappingResult error:nil];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self showResultSilently:NO operation:operation result:nil error:error];
    }];
}

- (void)testDefaultMapping {
    //    [HTDemoHelper defaultResponseDescritorWithClass:[HTArticle class] pathPattern:@"/user" keyPath:@"data"];
    //    [HTDemoHelper responseDescritorWithClass:[HTArticle class] pathPattern:@"/user" keyPath:@"data"];
    
    RKMapping *authorMapping = [HTDemoAuthor defaultResponseMapping];
    RKMapping *addressMapping = [HTDemoAddress defaultResponseMapping];
    RKMapping *articleMapping = [HTDemoArticle defaultResponseMapping];
    RKMapping *subscriberMapping = [HTDemoSubscriber defaultResponseMapping];
    RKMapping *articleExMapping = [HTDemoArticleEx defaultResponseMapping];
    
    RKMapping *traditionAuthorMapping = [self traditionAuthorMapping];
    RKMapping *traditionAddressMapping = [self traditionAddressMapping];
    RKMapping *traditionArticleMapping = [self traditionArticleMapping];
    RKMapping *traditionArticleExMapping = [self traditionArticleExMapping];
    RKMapping *traditionSubscriberMapping = [self traditionSubscriberMapping];
    
    NSAssert([authorMapping isEqualToMapping:traditionAuthorMapping], @"结果不正确");
    NSAssert([addressMapping isEqualToMapping:traditionAddressMapping], @"结果不正确");
    NSAssert([articleMapping isEqualToMapping:traditionArticleMapping], @"结果不正确");
    NSAssert([articleExMapping isEqualToMapping:traditionArticleExMapping], @"结果不正确");
    NSAssert([subscriberMapping isEqualToMapping:traditionSubscriberMapping], @"结果不正确");
    
    RKMapping *personMapping = [HTDemoPerson defaultResponseMapping];
    NSLog(@"%@", personMapping);
    
    RKMapping *demoA = [HTDemoCycleA defaultResponseMapping];
    NSLog(@"HTDemoCycleA: %@", demoA);
    
    RKMapping *demoB = [HTDemoCycleB defaultResponseMapping];
    NSLog(@"HTDemoCycleB: %@", demoB);
    
    RKMapping *demoC = [HTDemoCycleC defaultResponseMapping];
    NSLog(@"HTDemoCycleC: %@", demoC);
}

- (void)cancelAllRequests {
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

- (void)sendRequestInAnotherManger {
    NSURL *baseURL = [NSURL URLWithString:HTBaseRequestDemoBaseUrl];
    RKObjectManager *manager = [RKObjectManager managerWithBaseURL:baseURL];
    [manager addResponseDescriptor:[HTDemoGetUserInfoRequest responseDescriptor]];
    
    HTDemoGetUserInfoRequest *request = [[HTDemoGetUserInfoRequest alloc] init];
    request.requestDelegate = self;
    [request startWithManager:manager];
}

- (void)sendRequestInAnotherMangerWithRegister {
    NSURL *baseURL = [NSURL URLWithString:HTBaseRequestDemoBaseUrl];
    RKObjectManager *manager = [RKObjectManager managerWithBaseURL:baseURL];
    [HTDemoGetUserInfoRequest registerInMananger:manager];
    
    HTDemoGetUserInfoRequest *request = [[HTDemoGetUserInfoRequest alloc] init];
    request.requestDelegate = self;
    [request startWithManager:manager];
}

- (void)testHTDemoSpecList {
    HTDemoComplextRequest1 *request = [[HTDemoComplextRequest1 alloc] init];
    request.requestDelegate = self;
    [request start];
}

- (void)testRequestWithErrorMsg {
    HTDemoErrorMsgRequest *request = [[HTDemoErrorMsgRequest alloc] init];
    request.requestDelegate = self;
    [request start];
}

- (void)testRequestDescriptor {
    RKObjectMapping *requestMapping = [RKObjectMapping requestMapping];
    [requestMapping addAttributeMappingsFromDictionary:@{ @"name": @"name", @"password": @"password" }];
    
    // We wish to generate parameters of the format:
    // @{ @"page": @{ @"title": @"An Example Page", @"body": @"Some example content" } }
    RKRequestDescriptor *requestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:requestMapping
                                                                                   objectClass:[RKDemoUserInfo class]
                                                                                   rootKeyPath:nil
                                                                                        method:RKRequestMethodAny];
    
    // Construct an object mapping for the response
    // We are expecting JSON in the format:
    // {"page": {"title": "<title value>", "body": "<body value>"}}
    RKObjectMapping *responseMapping = [RKObjectMapping mappingForClass:[RKDemoUserInfo class]];
    [responseMapping addAttributeMappingsFromArray:@[ @"name", @"password" ]];
    
    // Construct a response descriptor that matches any URL (the pathPattern is nil), when the response payload
    // contains content nested under the `@"page"` key path, if the response status code is 200 (OK)
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:responseMapping
                                                                                            method:RKRequestMethodAny
                                                                                       pathPattern:nil
                                                                                           keyPath:@"/user"
                                                                                       statusCodes:[NSIndexSet indexSetWithIndex:200]];
    
    // Register our descriptors with a manager
    RKObjectManager *manager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:@"http://localhost:3000"]];
    [manager addRequestDescriptor:requestDescriptor];
    [manager addResponseDescriptor:responseDescriptor];
    
    // Work with the object
    RKDemoUserInfo *user = [RKDemoUserInfo new];
    user.name = @"An Example Page";
    user.password  = @"Some example content";
    
    // POST the parameterized representation of the `page` object to `/posts` and map the response
    [manager postObject:user path:@"/user" parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        NSLog(@"We object mapped the response with the following result: %@", result);
    } failure:nil];
}

- (void)getUserInfoRequestWithRequestType {
    HTDemoWithTypeRequest *request = [[HTDemoWithTypeRequest alloc] init];
    request.requestDelegate = self;
    [request start];
}

#pragma mark - Show Result

- (void)showResult:(BOOL)isSuccess operation:(RKObjectRequestOperation *)operation result:(RKMappingResult *)result error:(NSError *)error {
    NSString *title = isSuccess ? @"请求成功" : @"请求失败";
    RKErrorMessage *errorMessage =  [[error.userInfo objectForKey:RKObjectMapperErrorObjectsKey] firstObject];
    NSString *message = isSuccess ? [NSString stringWithFormat:@"请求成功的结果信息: %@", result] : [NSString stringWithFormat:@"错误信息: %@, error Message信息: %@", [error localizedDescription], errorMessage];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alertView show];
}

- (void)showResultSilently:(BOOL)isSuccess operation:(RKObjectRequestOperation *)operation result:(RKMappingResult *)result error:(NSError *)error {
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

#pragma mark - Helper Mapping Methods

- (RKMapping *)traditionAuthorMapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[HTDemoAuthor class]];
    [mapping addAttributeMappingsFromArray:@[@"name", @"email"]];
    
    RKMapping *addressMapping = [self traditionAddressMapping];
    [mapping addRelationshipMappingWithSourceKeyPath:@"address" mapping:addressMapping];
    
    return mapping;
}

- (RKMapping *)traditionArticleMapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[HTDemoArticle class]];
    [mapping addAttributeMappingsFromArray:@[@"title", @"body", @"publicationDate", @"comments"]];
    
    RKMapping *authorMapping = [self traditionAuthorMapping];
    RKMapping *subsriberMapping = [self traditionSubscriberMapping];
    [mapping addRelationshipMappingWithSourceKeyPath:@"author" mapping:authorMapping];
    [mapping addRelationshipMappingWithSourceKeyPath:@"subscribers" mapping:subsriberMapping];
    
    return mapping;
}

- (RKMapping *)traditionArticleExMapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[HTDemoArticleEx class]];
    [mapping addAttributeMappingsFromArray:@[@"title", @"body", @"publicationDate", @"comments"]];
    
    RKMapping *authorMapping = [self traditionAuthorMapping];
    RKMapping *authorExMapping = [authorMapping copy];
    RKMapping *subsriberMapping = [self traditionSubscriberMapping];
    [mapping addRelationshipMappingWithSourceKeyPath:@"author" mapping:authorMapping];
    [mapping addRelationshipMappingWithSourceKeyPath:@"authorList" mapping:authorExMapping];
    [mapping addRelationshipMappingWithSourceKeyPath:@"subscribers" mapping:subsriberMapping];
    
    return mapping;
}

- (RKMapping *)traditionAddressMapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[HTDemoAddress class]];
    [mapping addAttributeMappingsFromArray:@[@"province", @"city"]];
    
    return mapping;
}

- (RKMapping *)traditionSubscriberMapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[HTDemoSubscriber class]];
    [mapping addAttributeMappingsFromArray:@[@"name", @"email"]];
    
    RKMapping *authorMapping = [self traditionAuthorMapping];
    RKMapping *addressMapping = [self traditionAddressMapping];
    [mapping addRelationshipMappingWithSourceKeyPath:@"favoriteAuthors" mapping:authorMapping];
    [mapping addRelationshipMappingWithSourceKeyPath:@"address" mapping:addressMapping];
    
    return mapping;
}

@end
