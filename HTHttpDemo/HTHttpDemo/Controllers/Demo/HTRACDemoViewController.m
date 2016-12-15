//
//  HTRACDemoViewController.m
//  HTHttpDemo
//
//  Created by Wangliping on 16/2/1.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#import "HTRACDemoViewController.h"
#import "HTNetworking.h"
#import <HTNetworking/HTHttp/RACSupport/RKObjectManager+HTRAC.h>
#import <HTNetworking/HTHttp/RACSupport/HTOperationHelper.h>
#import "RKObjectRequestOperation+HTDemoRAC.h"
#import "RKDemoUserInfo.h"
#import "HTDemoPhotoInfo.h"
#import "HTDemoHelper.h"
#import "HTDemoGetUserInfoRequest.h"
#import "HTDemoGetUserPhotoListRequest.h"
#import "HTDemoGetPhotoListRequest.h"
#import "HTDemoRACPhotoListRequest.h"

@interface HTRACDemoViewController ()

@property (nonatomic, strong) RKObjectManager *manager;

@end

@implementation HTRACDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.title = @"HTHTTP With RAC Demo";
    
    [self initRKObjectManager];
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

#pragma mark - Prepare For Demo

- (void)initRKObjectManager {
    // 初始化RKObjectManager.
    RKObjectManager *manager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:@"http://localhost:3000"]];
    
    // 添加ResponseDescriptor.
    // UserInfo
    {
        RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[RKDemoUserInfo class]];
        [mapping addAttributeMappingsFromArray:@[@"userId", @"balance"]];
        [mapping addAttributeMappingsFromDictionary:@{@"version":@"name", @"status":@"password"}];
        
        RKResponseDescriptor *responseDescriptor1 = [RKResponseDescriptor responseDescriptorWithMapping:mapping method:RKRequestMethodGET pathPattern:@"/user" keyPath:@"data" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
        
            [manager addResponseDescriptor:responseDescriptor1];
    }
    
    // Get Photo List with User Info
    {
        RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[HTDemoPhotoInfo class]];
        [mapping addAttributeMappingsFromArray:[HTDemoHelper getPropertyList:[HTDemoPhotoInfo class]]];
        RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping method:RKRequestMethodAny pathPattern:@"/collection" keyPath:@"photolist" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
        [manager addResponseDescriptor:responseDescriptor];
    }
    
    // Get Photo List
    {
        RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[HTDemoPhotoInfo class]];
        [mapping addAttributeMappingsFromArray:[HTDemoHelper getPropertyList:[HTDemoPhotoInfo class]]];
        RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping method:RKRequestMethodAny pathPattern:@"/photolist" keyPath:@"photolist" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
        [manager addResponseDescriptor:responseDescriptor];
    }
    
    // ErrorMsg
    {
        RKObjectMapping *errorMapping = [RKObjectMapping mappingForClass:[RKErrorMessage class]];
        [errorMapping addPropertyMapping:[RKAttributeMapping attributeMappingFromKeyPath:nil toKeyPath:@"errorMessage"]];
        RKResponseDescriptor *errorResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:errorMapping method:RKRequestMethodGET pathPattern:nil keyPath:@"code" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassClientError)];
        [manager addResponseDescriptor:errorResponseDescriptor];
    }
    
    [RKMIMETypeSerialization registerClass:[RKNSJSONSerialization class] forMIMEType:@"text/plain"];
    self.manager = manager;
}

#pragma mark - Load Data

- (NSArray *)generateMethodNameList {
    return @[@"demoOperationSignal",
             @"demoSignalWithSideEffect",
             @"demoRetryRequest",
             @"demoBatchRequests",
             @"demoDependentRequests",
             @"demoIfAThenBElseC",
             @"RK--分割线--HT",
             @"demoHTSignal",
             @"demoHTRetrySignals",
             @"demoHTBatchSignals",
             @"demoHTDependentSignals",
             @"demoHTIfAThenBElseC",
             @"demoHTIfAFailWithConditionBThenCAndA",
             @"demoFinished"];
}

#pragma mark - Operaions

- (RKObjectRequestOperation *)getUserInfoOperation {
    NSString *methodName = NSStringFromSelector(_cmd);
    NSURLRequest *request = [_manager requestWithObject:nil method:RKRequestMethodGET path:@"/user" parameters:nil];
    return [self operationWithRequest:request methodName:methodName];
}

- (RKObjectRequestOperation *)getPhotoListInfoOperation {
    NSString *methodName = NSStringFromSelector(_cmd);
    NSURLRequest *request = [_manager requestWithObject:nil method:RKRequestMethodGET path:@"/photolist?limit=20&offset=0" parameters:nil];
    return [self operationWithRequest:request methodName:methodName];
}

- (RKObjectRequestOperation *)getUserPhotoListInfoOperation {
    NSString *methodName = NSStringFromSelector(_cmd);
    NSDictionary *parameters = @{@"name":@"lwang", @"password":@"test", @"type":@"photolist"};
    NSURLRequest *request = [_manager requestWithObject:nil method:RKRequestMethodPOST path:@"/collection" parameters:parameters];
    return [self operationWithRequest:request methodName:methodName];
}

- (RKObjectRequestOperation *)operationWithRequest:(NSURLRequest *)request methodName:(NSString *)methodName {
    RKObjectRequestOperation *operation = [_manager objectRequestOperationWithRequest:request success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        NSLog(@"methodName: %@ success", methodName);
        [self showResultSilently:YES operation:operation result:mappingResult error:nil];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"methodName: %@ failed", methodName);
        [self showResultSilently:NO operation:operation result:nil error:error];
    }];
    
    return operation;
}

#pragma mark - Signals

- (RACSignal *)signalGetUserInfoOperation {
    return [self signalOfOperation:[self getUserInfoOperation]];
}

- (RACSignal *)signalGetPhotoListInfoOperation {
    return [self signalOfOperation:[self getPhotoListInfoOperation]];
}

- (RACSignal *)signalGetUserPhotoListInfoOperation {
    return [self signalOfOperation:[self getUserPhotoListInfoOperation]];
}

- (RACSignal *)signalOfOperation:(RKObjectRequestOperation *)operation {
    return [operation rac_enqueueInManager:self.manager];
}

#pragma mark - Helper Methods

- (void)showResultSilently:(BOOL)isSuccess operation:(RKObjectRequestOperation *)operation result:(RKMappingResult *)result error:(NSError *)error {
    if (isSuccess) {
        NSLog(@"Request %@ is finished successful, result is %@", operation.HTTPRequestOperation.request.URL, result);
    } else {
        // You can access the model object used to construct the `NSError` via the `userInfo`
        RKErrorMessage *errorMessage =  [[error.userInfo objectForKey:RKObjectMapperErrorObjectsKey] firstObject];
        NSLog(@"Reqeust %@ failes with error: %@, error message from server is %@", operation.HTTPRequestOperation.request.URL, [error localizedDescription], errorMessage);
    }
}

#pragma mark - Test Methods

/**
 *  展示如何使用一个普通的Operation的Signal来进行请求的发送, 并且该信号被订阅多次也仅仅只发送一次请求.
 */
- (void)demoOperationSignal {
    NSString *methodName = NSStringFromSelector(_cmd);
    
    // 普通的信号订阅. 类似的，通过方法signalGetPhotoListInfoOperation或者signalGetUserPhotoListInfoOperation获取到的RACSignal对象可以使用同样的方法进行订阅.
    RACSignal *signal = [self signalGetUserInfoOperation];
    [signal subscribeNext:^(id x) {
        NSLog(@"%@ : %@", methodName, x);
        
        // 此处x为RKObjectRequestOperation.
        if ([x isKindOfClass:[RKObjectRequestOperation class]]) {
            RKObjectRequestOperation *operation = x;
            RKMappingResult *result = operation.mappingResult;
            NSLog(@"%@ result : %@", methodName, result);
        }
    } error:^(NSError *error) {
        NSLog(@"%@ : %@", methodName, error);
    } completed:^{
        NSLog(@"%@ : %@", methodName, @"completed");
    }];
}

/**
 *  展示如何使用一个RACSignal来进行请求的发送，并且满足条件：该信号每次被订阅都被发送一次.
 *  通常情况下，我们希望避免这种信号被多次订阅时请求被发送，那么就应该使用demoOperationSignal展示的方法.
 */
- (void)demoSignalWithSideEffect {
    NSString *methodName = NSStringFromSelector(_cmd);
    
    RACSignal *signal = [_manager rac_getObjectsAtPath:@"/user" parameters:nil];
    [signal subscribeNext:^(id x) {
        NSLog(@"%@ : %@", methodName, x);
    } error:^(NSError *error) {
        NSLog(@"%@ : %@", methodName, error);
    } completed:^{
        NSLog(@"%@ : %@", methodName, @"completed");
    }];
}

/**
 *  展示如何利用ReactiveCocoa进行Retry的操作，该信号即使被重复订阅，实际的请求也仅仅只会执行一次.
 *  Note: 由于信号是依附于operaition的，而同一个operation是不能重复执行的. 所以retry的功能应该通过RKObjectManager的rac_operationWithObject来处理.
 */
- (void)demoRetryRequest {
    NSString *methodName = NSStringFromSelector(_cmd);
    
    // 应该使用rac_operationWithObject进行retry处理. Operation开放的信号是不能被retry的.
    RACSignal *retrySignal = [_manager rac_operationWithObject:nil method:RKRequestMethodGET path:@"/user" parameters:nil retryCount:5];
    [retrySignal subscribeNext:^(id x) {
        NSLog(@"%@ : %@", methodName, x);
    } error:^(NSError *error) {
        NSLog(@"%@ : %@", methodName, error);
    } completed:^{
        NSLog(@"%@ : %@", methodName, @"completed");
    }];
}

/**
 *  展示如何利用ReactiveCocoa并行发送多个请求.
 */
- (void)demoBatchRequests {
    NSString *methodName = NSStringFromSelector(_cmd);
    
    NSMutableArray *batchedOperations = [NSMutableArray array];
    for (int i = 0; i < 3; i ++) {
        [batchedOperations addObject:[self getUserInfoOperation]];
    }
    
    for (int i = 0; i < 3; i ++) {
        [batchedOperations addObject:[self getPhotoListInfoOperation]];
    }
    
    for (int i = 0; i < 3; i ++) {
        [batchedOperations addObject:[self getUserPhotoListInfoOperation]];
    }
    
    RACSignal *batchedSignal = [HTOperationHelper batchedSignalWith:batchedOperations inManager:_manager];
    [batchedSignal subscribeNext:^(id x) {
        NSLog(@"%@ : %@", methodName, x);
    } error:^(NSError *error) {
        NSLog(@"%@ : %@", methodName, error);
    } completed:^{
        NSLog(@"%@ : %@", methodName, @"completed");
    }];
}

/**
 *  展示如何利用ReactiveCocoa发送多个相互依赖的请求, 例如，A请求的输出作为B请求的输入继续发送; 并不仅仅是请求的顺序依赖关系，还包括数据的流动.
 */
- (void)demoDependentRequests {
    NSString *methodName = NSStringFromSelector(_cmd);
    RACSignal *signal = [self signalGetUserInfoOperation];
    RACSignal *combinedSignal = [signal flattenMap:^RACStream *(id value) {
        NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:@{@"name":@"lwang", @"password":@"test", @"type":@"photolist"}];
        if ([value isKindOfClass:[RKObjectRequestOperation class]]) {
            RKObjectRequestOperation *operation = value;
            RKDemoUserInfo *userInfo = operation.mappingResult.dictionary[@"data"];
            if ([userInfo.name length] > 0) {
                parameters[@"name"] = userInfo.name;
            }
        }
        
        NSURLRequest *request = [_manager requestWithObject:nil method:RKRequestMethodPOST path:@"/collection" parameters:parameters];
        RKObjectRequestOperation *photoListOperation = [self operationWithRequest:request methodName:methodName];
        
        return [self signalOfOperation:photoListOperation];
    }];
    
    [combinedSignal subscribeNext:^(id x) {
        // 此处x为RKObjectRequestOperation.
        if ([x isKindOfClass:[RKObjectRequestOperation class]]) {
            RKObjectRequestOperation *operation = x;
            RKMappingResult *result = operation.mappingResult;
            NSLog(@"%@ result : %@", methodName, result);
        }
    } error:^(NSError *error) {
        NSLog(@"%@ : %@", methodName, error);
    } completed:^{
        NSLog(@"%@ : %@", methodName, @"completed");
    }];
}

/**
 *  展示如何实现如下需求：请求A成功，则执行B；否则执行C.
 */
- (void)demoIfAThenBElseC {
    NSString *methodName = NSStringFromSelector(_cmd);
    RKObjectRequestOperation *operationA = [self getUserInfoOperation];
    RKObjectRequestOperation *operationB = [self getUserPhotoListInfoOperation];
    RKObjectRequestOperation *operationC = [self getPhotoListInfoOperation];
    RACSignal *signal = [HTOperationHelper if:operationA then:operationB else:operationC inManager:self.manager validResultBlock:nil];
    [signal subscribeNext:^(id x) {
        NSLog(@"%@ : %@", methodName, x);
    } error:^(NSError *error) {
        NSLog(@"%@ : %@", methodName, error);
    } completed:^{
        NSLog(@"%@ : %@", methodName, @"completed");
    }];
}

#pragma mark - HT RAC Support 

/**
 *  展示HTBaseRequest这一层的RACSignal. 该信号被重新订阅时也不会重复发送请求.
 */
- (void)demoHTSignal {
    NSString *methodName = NSStringFromSelector(_cmd);
    
    HTDemoGetUserPhotoListRequest *request = [[HTDemoGetUserPhotoListRequest alloc] init];
    RACSignal *signal = [request signalStart];
    [signal subscribeNext:^(id x) {
        RACTupleUnpack(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) = (RACTuple *)x;
        [self showResultSilently:YES operation:operation result:mappingResult error:nil];
    } error:^(NSError *error) {
        RKObjectRequestOperation *operation = error.userInfo[@"operation"];
        NSError *realError = error.userInfo[@"error"];
        if (nil == realError) {
            realError = error;
        }
        
        [self showResultSilently:NO operation:operation result:nil error:realError];
    } completed:^{
        NSLog(@"%@ : %@", methodName, @"completed");
    }];
}

/**
 *  展示通过HTBaseRequest这一层的RACSignal来支持Retry. 该信号被重新订阅时也不会重复发送请求.
 */
- (void)demoHTRetrySignals {
    NSString *methodName = NSStringFromSelector(_cmd);
    
    HTDemoGetUserPhotoListRequest *request = [[HTDemoGetUserPhotoListRequest alloc] init];
    RACSignal *signal = [request signalStartWithRetry:5];
    [signal subscribeNext:^(id x) {
        RACTupleUnpack(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) = (RACTuple *)x;
        [self showResultSilently:YES operation:operation result:mappingResult error:nil];
    } error:^(NSError *error) {
        RKObjectRequestOperation *operation = error.userInfo[@"operation"];
        NSError *realError = error.userInfo[@"error"];
        if (nil == realError) {
            realError = error;
        }
        
        [self showResultSilently:NO operation:operation result:nil error:realError];
    } completed:^{
        NSLog(@"%@ : %@", methodName, @"completed");
    }];
}

/**
 *  展示如何利用HTBaseRequest与ReactiveCocoa并行发送多个请求.
 */
- (void)demoHTBatchSignals {
    NSString *methodName = NSStringFromSelector(_cmd);
    
    HTDemoGetUserPhotoListRequest *requestA = [[HTDemoGetUserPhotoListRequest alloc] init];
    RACSignal *signalA = [requestA signalStart];
    
    HTDemoGetPhotoListRequest *requestB = [[HTDemoGetPhotoListRequest alloc] init];
    RACSignal *signalB = [requestB signalStart];
    
    NSMutableArray *signalList = [NSMutableArray array];
    if (nil != signalA) {
        [signalList addObject:signalA];
    }
    
    if (nil != signalB) {
        [signalList addObject:signalB];
    }
    
    RACSignal *mergedSignal = [RACSignal merge:signalList];
    [mergedSignal subscribeNext:^(id x) {
        RACTupleUnpack(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) = (RACTuple *)x;
        [self showResultSilently:YES operation:operation result:mappingResult error:nil];
    } error:^(NSError *error) {
        RKObjectRequestOperation *operation = error.userInfo[@"operation"];
        NSError *realError = error.userInfo[@"error"];
        if (nil == realError) {
            realError = error;
        }
        
        [self showResultSilently:NO operation:operation result:nil error:realError];
    } completed:^{
        NSLog(@"%@ : %@", methodName, @"completed");
    }];
}

/**
 *  展示如何利用ReactiveCocoa与HTBaseRequest发送多个相互依赖的请求.
 */
- (void)demoHTDependentSignals {
    NSString *methodName = NSStringFromSelector(_cmd);
    
    HTDemoGetUserInfoRequest *getUserInfoRequest = [[HTDemoGetUserInfoRequest alloc] init];
    HTDemoRACPhotoListRequest *getPhotoListRequest = [[HTDemoRACPhotoListRequest alloc] init];
   
    RACSignal *combinedSignal = [[getUserInfoRequest signalStart] flattenMap:^RACStream *(id value) {
        RACTupleUnpack(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) = (RACTuple *)value;
        NSAssert(nil != operation, @"received value is incorrect");
        RKDemoUserInfo *userInfo = mappingResult.dictionary[@"data"];
        getPhotoListRequest.userName = userInfo.name;
        return [getPhotoListRequest signalStart];
    }];
    
    [combinedSignal subscribeNext:^(id x) {
        RACTupleUnpack(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) = (RACTuple *)x;
        [self showResultSilently:YES operation:operation result:mappingResult error:nil];
    } error:^(NSError *error) {
        RKObjectRequestOperation *operation = error.userInfo[@"operation"];
        NSError *realError = error.userInfo[@"error"];
        if (nil == realError) {
            realError = error;
        }
        
        [self showResultSilently:NO operation:operation result:nil error:realError];
    } completed:^{
        NSLog(@"%@ : %@", methodName, @"completed");
    }];
}

/**
 *  展示如何实现如下需求：请求A成功，则执行B；否则执行C.
 */
- (void)demoHTIfAThenBElseC {
    NSString *methodName = NSStringFromSelector(_cmd);
    
    HTDemoGetUserInfoRequest *getUserInfoRequest = [[HTDemoGetUserInfoRequest alloc] init];
    HTDemoGetUserPhotoListRequest *requestA = [[HTDemoGetUserPhotoListRequest alloc] init];
    HTDemoGetPhotoListRequest *requestB = [[HTDemoGetPhotoListRequest alloc] init];

    RACSignal *combinedSignal = [HTBaseRequest ifRequestSucceed:getUserInfoRequest then:requestA else:requestB withMananger:nil];
    [combinedSignal subscribeNext:^(id x) {
        RACTupleUnpack(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) = (RACTuple *)x;
        [self showResultSilently:YES operation:operation result:mappingResult error:nil];
    } error:^(NSError *error) {
        RKObjectRequestOperation *operation = error.userInfo[@"operation"];
        NSError *realError = error.userInfo[@"error"];
        if (nil == realError) {
            realError = error;
        }
        
        [self showResultSilently:NO operation:operation result:nil error:realError];
    } completed:^{
        NSLog(@"%@ : %@", methodName, @"completed");
    }];
}

/**
 *  展示如下需求：如果请求A失败，并且满足条件B, 那么执行C后再执行A.
 *  实际的需求：发送请求A, 如果token失效，则获取token后重新发送请求A.
 */
- (void)demoHTIfAFailWithConditionBThenCAndA {
#warning TODO.
}

@end
