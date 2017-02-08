//
//  HTRKFreezeDemoViewController.m
//  HTHttpDemo
//
//  Created by Wangliping on 16/2/4.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#import "HTRKFreezeDemoViewController.h"
#import "RKDemoUserInfo.h"
#import "HTNetworking.h"
#import "HTDemoHelper.h"

/**
 *  遵循HTFreezeManagerProtocol以提供发送冻结请求的RKObjectMananger; 否则使用默认的RKObjectManager来发送.
 */
@interface HTRKFreezeDemoViewController () <HTFreezeManagerProtocol>

@property (nonatomic, strong) RKObjectManager *manager;

@end

@implementation HTRKFreezeDemoViewController

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Freeze Request With RKObjectMananger";
    
    // 开启冻结请求的功能.
    [self enableFreezeFeature];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Enable Freeze Feature

- (void)enableFreezeFeature {
    // Step 1: 创建RKObjectMananger对象.
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[RKDemoUserInfo class]];
    [mapping addAttributeMappingsFromArray:@[@"userId", @"balance"]];
    [mapping addAttributeMappingsFromDictionary:@{@"version":@"name", @"status":@"password"}];
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping method:RKRequestMethodGET pathPattern:@"/user" keyPath:@"data" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    RKObjectMapping *errorMapping = [RKObjectMapping mappingForClass:[RKErrorMessage class]];
    [errorMapping addPropertyMapping:[RKAttributeMapping attributeMappingFromKeyPath:nil toKeyPath:@"errorMessage"]];
    RKResponseDescriptor *errorResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:errorMapping method:RKRequestMethodGET pathPattern:nil keyPath:@"code" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassClientError)];
    
    // 添加ResponseDescriptor.
    RKObjectManager *manager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:@"http://localhost:3000"]];
    
    [manager addResponseDescriptor:responseDescriptor];
    [manager addResponseDescriptor:errorResponseDescriptor];
    
    // 注册对@"text/plain"的解析
    [RKMIMETypeSerialization registerClass:[RKNSJSONSerialization class] forMIMEType:@"text/plain"];
    
    self.manager = manager;
    
    // Step 2: 监听冻结请求的发送成功与失败事件.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onFrozenRequestSuccessful:) name:kHTResendFrozenRequestSuccessfulNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onFrozenRequestFailure:) name:kHTResendFrozenRequestFailureNotification object:nil];
    
    // Step 3: 开始监听
    [HTFreezeManager setupWithDelegate:self isStartMonitoring:YES];
}

#pragma mark - Notifications

// 处理冻结请求的发送成功与失败事件.
- (void)onFrozenRequestSuccessful:(NSNotification *)notify {
    NSDictionary *userInfo = [notify userInfo];
    
    RKObjectRequestOperation *operation = [userInfo objectForKey:kHTResendFrozenNotificationOperationItem];
    RKMappingResult *result = [userInfo objectForKey:kHTResendFrozenNotificationResultItem];
    
    // 根据operation和result判断是否需要做界面刷新等的处理.
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
    return @[@"demoSendRequestEnableFreeze"];
}

#pragma mark - HTFreezeManagerProtocol

// 返回发送请求request所需要的RKObjectMananger对象.
- (RKObjectManager *)objectManagerForRequest:(NSURLRequest *)request {
    return _manager;
}

#pragma mark - Test Methods

/**
 *  展示如何通过RKObjectManager发送开启了冻结请求功能的request.
 */
- (void)demoSendRequestEnableFreeze {
    NSMutableURLRequest *request = [_manager requestWithObject:nil method:RKRequestMethodGET path:@"/user" parameters:nil];
    
    // Note: 这里可以对Request进行配置.
    request.ht_freezeId = [request ht_defaultFreezeId];
    request.ht_canFreeze = YES;
    request.ht_freezePolicyId = HTFreezePolicySendFreezeAutomatically;
    
    // 冻结的请求会在下次自动发送.
    RKObjectRequestOperation *operation = [_manager objectRequestOperationWithRequest:request success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self showResult:YES operation:operation result:mappingResult error:nil];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self showResult:NO operation:operation result:nil error:error];
    }];
    [_manager enqueueObjectRequestOperation:operation];
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