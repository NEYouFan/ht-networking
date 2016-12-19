//
//  HTFreezeRequestViewController.m
//  HTHttpDemo
//
//  Created by Wangliping on 15/11/2.
//  Copyright © 2015年 NetEase. All rights reserved.
//

#import "HTFreezeDemoViewController.h"
#import "HTNetworking.h"
#import "HTDemoFreezeRequest.h"
#import "HTDemoCustomFreezeRequest.h"
#import "HTCustomFreezePolicy.h"

/**
 *  遵循HTFreezeManagerProtocol以提供发送冻结请求的RKObjectMananger; 否则使用默认的RKObjectManager来发送.
 */
@interface HTFreezeDemoViewController () <HTFreezeManagerProtocol>

@property (nonatomic, strong) RKObjectManager *manager;

@end

@implementation HTFreezeDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Freeze Request With HT";
    
    // 监听冻结请求的发送成功与失败事件.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onFrozenRequestSuccessful:) name:kHTResendFrozenRequestSuccessfulNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onFrozenRequestFailure:) name:kHTResendFrozenRequestFailureNotification object:nil];
    
    // 开启冻结请求的功能. 通常，freezeMananger的delegate可以是一个单例的Mananger实例.
    [HTFreezeManager setupWithDelegate:self isStartMonitoring:YES];
    
    if (nil == [RKObjectManager sharedManager]) {
        [RKMIMETypeSerialization registerClass:[RKNSJSONSerialization class] forMIMEType:@"text/plain"];
        NSURL *baseURL = [NSURL URLWithString:@"http://localhost:3000"];
        RKObjectManager *manager = [RKObjectManager managerWithBaseURL:baseURL];
        NSAssert(nil != manager, @"manager已创建");
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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

#pragma mark - HTFreezeManagerProtocol

- (RKObjectManager *)objectManagerForRequest:(NSURLRequest *)request {
    return _manager;
}

#pragma mark - Load Data

- (NSArray *)generateMethodNameList {
    return @[@"demoSendRequestWithFreezeEnabled",
             @"demoSendRequestWithCustomFreezeConfig",
             @"demoCustomFreezePolicy",
             @"demoClearFreezeRequests"];
}

#pragma mark - Test Methods

/**
 *  Demo: 展示发送请求时开启Freeze功能，开启方式在于在HTDemoFreezeRequest中覆写基类方法- (HTFreezePolicyId)freezePolicyId.
 */
- (void)demoSendRequestWithFreezeEnabled {
    HTDemoFreezeRequest *request = [[HTDemoFreezeRequest alloc] init];
    [request startWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self showResult:YES operation:operation result:mappingResult error:nil];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self showResult:NO operation:operation result:nil error:error];
    }];
}

/**
 *  Demo: 展示发送请求时开启Freeze功能，并对request的freeze相关属性进行自定义配置.
 */
- (void)demoSendRequestWithCustomFreezeConfig {
    // Note: 大部分配置方式类似Cache功能.
    HTDemoCustomFreezeRequest *request = [[HTDemoCustomFreezeRequest alloc] init];
    request.freezePolicyId = HTFreezePolicySendFreezeAutomatically;
    
    // 自行配置freeze相关信息.
    request.customFreezeKey = @"demoSendRequestWithCustomFreezeConfig";
    [request startWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self showResult:YES operation:operation result:mappingResult error:nil];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self showResult:NO operation:operation result:nil error:error];
    }];
}

/**
 *  Demo: 展示使用自定义的Policy策略.
 */
- (void)demoCustomFreezePolicy {
    [[HTFreezePolicyMananger sharedInstance] registeFreezePolicyWithPolicyId:(HTFreezeolicyUserDefined + 1) policy:[HTCustomFreezePolicy class]];
    
    HTDemoCustomFreezeRequest *request = [[HTDemoCustomFreezeRequest alloc] init];
    request.freezePolicyId = (HTFreezeolicyUserDefined + 1);
    request.freezeExpireTimeInterval = 86400;
    [request startWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self showResult:YES operation:operation result:mappingResult error:nil];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self showResult:NO operation:operation result:nil error:error];
    }];
}

/**
 *  Demo: 展示如何清理所有冻结的请求.
 */
- (void)demoClearFreezeRequests {
    HTFreezeManager *freezeMananger = [HTFreezeManager sharedInstance];
    [freezeMananger clearAllFreezedRequestsOnCompletion:^{
        NSLog(@"Clear Freeze Requests successfully");
    }];
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

@end
