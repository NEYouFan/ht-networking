//
//  SecondViewController.m
//  HTHttpDemo
//
//  Created by NetEase on 15/7/23.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import "HTRACTestViewController.h"
#import "RKObjectRequestOperation+HTRAC.h"
#import "RestKit.h"
#import "RKDemoUserInfo.h"
#import "ReactiveCocoa/ReactiveCocoa.h"
#import "RKObjectManager+HTRAC.h"
#import "RKObjectRequestOperation+HTDemoRAC.h"
#import "HTDemoPhotoInfo.h"
#import "HTDemoHelper.h"
#import "HTOperationHelper.h"

@interface HTRACTestViewController ()

@property (nonatomic, strong) RKObjectManager *manager;

@end

@implementation HTRACTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self initRKObjectManager];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSArray *)generateMethodNameList {
    return @[@"testOperationSignal", @"testRestartOperation",  @"testRKObjectManagerRetryOperation", @"subscribeRetryOperationMultiTimes",
             @"testBatchOperation", @"testDependentOperation", @"testIfAThenBElseC", @"testReplayOperationSignal", @"testReplayFinishedOperationSignal", @"testGetUserPhotoList",
             @"testGetPhotoList", @"testRKObjectManagerSignal", @"testBatchedSignals"];
}

- (void)initRKObjectManager {
    // 初始化RKObjectManager.
    RKObjectManager *manager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:@"http://localhost:3000"]];
    
    // UserInfo
    RKObjectMapping *mapping1 = [RKObjectMapping mappingForClass:[RKDemoUserInfo class]];
    [mapping1 addAttributeMappingsFromArray:@[@"userId", @"balance"]];
    
    [mapping1 addAttributeMappingsFromDictionary:@{@"version":@"name", @"status":@"password"}];
    RKResponseDescriptor *responseDescriptor1 = [RKResponseDescriptor responseDescriptorWithMapping:mapping1 method:RKRequestMethodGET pathPattern:@"/user" keyPath:@"data" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    // Get Photo List with User Info
    {
        RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[HTDemoPhotoInfo class]];
        [mapping addAttributeMappingsFromArray:[HTDemoHelper getPropertyList:[HTDemoPhotoInfo class]]];
        RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping method:RKRequestMethodAny pathPattern:@"/collection" keyPath:@"photolist" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
        [manager addResponseDescriptor:responseDescriptor];
    }
    
    // Get User Info
    {
        RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[HTDemoPhotoInfo class]];
        [mapping addAttributeMappingsFromArray:[HTDemoHelper getPropertyList:[HTDemoPhotoInfo class]]];
        RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping method:RKRequestMethodAny pathPattern:@"/photolist" keyPath:@"photolist" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
        [manager addResponseDescriptor:responseDescriptor];
    }
    
    // ErrorMsg
    RKObjectMapping *errorMapping = [RKObjectMapping mappingForClass:[RKErrorMessage class]];
    [errorMapping addPropertyMapping:[RKAttributeMapping attributeMappingFromKeyPath:nil toKeyPath:@"errorMessage"]];
    RKResponseDescriptor *errorResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:errorMapping method:RKRequestMethodGET pathPattern:nil keyPath:@"code" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassClientError)];
    
    [RKMIMETypeSerialization registerClass:[RKNSJSONSerialization class] forMIMEType:@"text/plain"];
    
    // 添加ResponseDescriptor.
    [manager addResponseDescriptor:responseDescriptor1];
    [manager addResponseDescriptor:errorResponseDescriptor];
    
    self.manager = manager;
}

#pragma mark - Test Method List

- (void)testOperationSignal {
    NSString *methodName = NSStringFromSelector(_cmd);
    
    // 普通的信号订阅.
    RACSignal *signal = [self signalGetUserInfoOperation];
    [signal subscribeNext:^(id x) {
        NSLog(@"%@ : %@", methodName, x);
        
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

- (void)testRestartOperation {
    NSString *methodName = NSStringFromSelector(_cmd);
    
    // Note: 这个Retry是有问题的. 原因是这里的信号是依附于operaition的，而同一个operation是不能重复执行的.
    // retry的功能应该通过RKObjectManager的rac_operationWithObject来处理.
    RACSignal *signal = [self signalGetUserInfoOperation];
    RACSignal *retrySignal = [signal retry:5];
    [retrySignal subscribeNext:^(id x) {
        NSLog(@"%@ : %@", methodName, x);
    } error:^(NSError *error) {
        NSLog(@"%@ : %@", methodName, error);
    } completed:^{
        NSLog(@"%@ : %@", methodName, @"completed");
    }];
}

- (void)testRKObjectManagerRetryOperation {
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

- (void)subscribeRetryOperationMultiTimes {
    NSString *methodName = NSStringFromSelector(_cmd);
    
    // 解释: 即使是反复多次的订阅，也实际只会发送一次请求. 使用下面的接口可以正确实现该功能.
    RACSignal *retrySignal = [_manager rac_operationWithObject:nil method:RKRequestMethodGET path:@"/user" parameters:nil retryCount:5];
    for (int i = 0; i < 10; i ++) {
        [retrySignal subscribeNext:^(id x) {
            NSLog(@"%@ : %@", methodName, x);
        } error:^(NSError *error) {
            NSLog(@"%@ : %@", methodName, error);
        } completed:^{
            NSLog(@"%@ : %@", methodName, @"completed");
        }];
    }
}

- (void)testBatchOperation {
    
}

- (void)testDependentOperation {
    
}

- (void)testIfAThenBElseC {
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

// Post用户信息获取图片信息.
- (void)testGetUserPhotoList {
    NSString *methodName = NSStringFromSelector(_cmd);
    
    // 普通的信号订阅.
    RACSignal *signal = [self signalGetUserPhotoListInfoOperation];
    [signal subscribeNext:^(id x) {
        NSLog(@"%@ : %@", methodName, x);
    } error:^(NSError *error) {
        NSLog(@"%@ : %@", methodName, error);
    } completed:^{
        NSLog(@"%@ : %@", methodName, @"completed");
    }];
}

- (void)testGetPhotoList {
    NSString *methodName = NSStringFromSelector(_cmd);
    
    // 普通的信号订阅.
    RACSignal *signal = [self signalGetPhotoListInfoOperation];
    [signal subscribeNext:^(id x) {
        NSLog(@"%@ : %@", methodName, x);
    } error:^(NSError *error) {
        NSLog(@"%@ : %@", methodName, error);
    } completed:^{
        NSLog(@"%@ : %@", methodName, @"completed");
    }];
}

// 测试replaySignalInManager方法. 如果operation从来没有被执行过，可以正常工作.
- (void)testReplayOperationSignal {
    NSString *methodName = NSStringFromSelector(_cmd);
    
    NSURLRequest *request = [_manager requestWithObject:nil method:RKRequestMethodGET path:@"/user" parameters:nil];
    RKObjectRequestOperation *operation = [_manager objectRequestOperationWithRequest:request success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        NSLog(@"success");
        [self showResult:YES operation:operation result:mappingResult error:nil];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        // You can access the model object used to construct the `NSError` via the `userInfo`
        RKErrorMessage *errorMessage =  [[error.userInfo objectForKey:RKObjectMapperErrorObjectsKey] firstObject];
        NSLog(@"%@", errorMessage);
        
        [self showResult:NO operation:operation result:nil error:error];
    }];
    
    // 如果operation没有被执行过，那么测试
    RACSignal *signal = [operation replaySignalInManager:_manager];
    for (int i = 0; i < 5; i ++) {
        [signal subscribeNext:^(id x) {
            NSLog(@"%@ : %@", methodName, x);
        } error:^(NSError *error) {
            NSLog(@"%@ : %@", methodName, error);
        } completed:^{
            NSLog(@"%@ : %@", methodName, @"completed");
        }];
    }
}

// 测试replaySignalInManager方法. 如果operation已经被执行过，会报错甚至crash. 因为一个Operation只能被调度一次.
- (void)testReplayFinishedOperationSignal {
    NSString *methodName = NSStringFromSelector(_cmd);
    
    NSURLRequest *request = [_manager requestWithObject:nil method:RKRequestMethodGET path:@"/user" parameters:nil];
    RKObjectRequestOperation *operation = [_manager objectRequestOperationWithRequest:request success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        NSLog(@"success");
        [self showResult:YES operation:operation result:mappingResult error:nil];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        // You can access the model object used to construct the `NSError` via the `userInfo`
        RKErrorMessage *errorMessage =  [[error.userInfo objectForKey:RKObjectMapperErrorObjectsKey] firstObject];
        NSLog(@"%@", errorMessage);
        
        [self showResult:NO operation:operation result:nil error:error];
    }];
    
    // 先让任务执行一次
    [operation start];
    [operation waitUntilFinished];
    
    // 然后再次订阅信号，看是否会重新执行.
    // 这个Retry是有问题的, 该接口已经被废弃掉，移到了Demo中，仅供测试使用. 因为这个Retry的信号会重新发送请求.
    RACSignal *signal = [operation replaySignalInManager:_manager];
    [signal subscribeNext:^(id x) {
        NSLog(@"%@ : %@", methodName, x);
    } error:^(NSError *error) {
        NSLog(@"%@ : %@", methodName, error);
    } completed:^{
        NSLog(@"%@ : %@", methodName, @"completed");
    }];
}

- (void)testRKObjectManagerSignal {
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

- (void)testBatchedSignals {
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

#warning 添加上传下载整个文件的Demo与测试示例.

- (RKObjectRequestOperation *)getUserPhotoListInfoOperation {
    NSString *methodName = NSStringFromSelector(_cmd);
    
    NSDictionary *parameters = @{@"name":@"lwang", @"password":@"test", @"type":@"photolist"};
    NSURLRequest *request = [_manager requestWithObject:nil method:RKRequestMethodPOST path:@"/collection" parameters:parameters];
    return [self operationWithRequest:request methodName:methodName];
}

- (RKObjectRequestOperation *)operationWithRequest:(NSURLRequest *)request methodName:(NSString *)methodName {
    RKObjectRequestOperation *operation = [_manager objectRequestOperationWithRequest:request success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        NSLog(@"methodName: %@ success", methodName);
        [self showResult:YES operation:operation result:mappingResult error:nil];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        // You can access the model object used to construct the `NSError` via the `userInfo`
        RKErrorMessage *errorMessage =  [[error.userInfo objectForKey:RKObjectMapperErrorObjectsKey] firstObject];
        NSLog(@"methodName: %@ error: %@", methodName, errorMessage);
        
        [self showResult:NO operation:operation result:nil error:error];
    }];
    
    return operation;
}


- (void)testRACObjectManagerWorkflow {
    NSString *url = @"http://localhost:4567";
    NSURL *baseUrl = [[NSURL alloc] initWithString:url];
    NSString *getPath1 = @"/user";
    NSString *getPath2 = @"/users";
    
    RKObjectManager *manager = [RKObjectManager managerWithBaseURL:baseUrl];
    RACSignal *signal1 = [manager rac_getObject:nil path:getPath1 parameters:nil];
    
    RACSignal *signal2 = [manager rac_getObjectsAtPath:getPath2 parameters:nil];
    
    NSMutableArray *signalList = [NSMutableArray arrayWithObjects:signal1, signal2, nil];
    RACSignal *mergedSignal = [RACSignal merge:signalList];
    [mergedSignal subscribeNext:^(id x) {
        NSLog(@"%@", x);
    } error:^(NSError *error) {
        CFRunLoopRef runLoopRef = CFRunLoopGetCurrent();
        CFRunLoopStop(runLoopRef);
    } completed:^{
        CFRunLoopRef runLoopRef = CFRunLoopGetCurrent();
        CFRunLoopStop(runLoopRef);
    }];
    
    CFRunLoopRun();
}

- (void)testRKObjectRequestOperatonRAC {
    NSString *url = @"http://localhost:4567";
    NSURL *baseUrl = [[NSURL alloc] initWithString:url];
    NSString *getPath1 = @"/user";
    RKObjectManager *manager = [RKObjectManager managerWithBaseURL:baseUrl];
    NSURLRequest *request = [manager requestWithObject:nil method:RKRequestMethodGET path:getPath1 parameters:nil];
    RKObjectRequestOperation *operation = [[RKObjectRequestOperation alloc] initWithRequest:request responseDescriptors:manager.responseDescriptors];
    void (^originalSuccess)(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) = ^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        NSLog(@"originalSuccess");
        
        CFRunLoopRef runLoopRef = CFRunLoopGetCurrent();
        CFRunLoopStop(runLoopRef);
    };
    
    void (^originalFailure)(RKObjectRequestOperation *operation, NSError *error) = ^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"originalFailure");
        
        CFRunLoopRef runLoopRef = CFRunLoopGetCurrent();
        CFRunLoopStop(runLoopRef);
    };
    
    [operation setCompletionBlockWithSuccess:originalSuccess failure:originalFailure];
    
    RACSignal *signal = [operation rac_enqueueInManager:manager];
    [signal subscribeNext:^(id x) {
        NSLog(@"%@", x);
    } error:^(NSError *error) {
        NSLog(@"%@", error);
    } completed:^{
        NSLog(@"%@", @"completed");
    }];
    
    [signal subscribeNext:^(id x) {
        NSLog(@"%@1", x);
    } error:^(NSError *error) {
        NSLog(@"%@2", error);
    } completed:^{
        NSLog(@"%@3", @"completed");
    }];
    
    [signal subscribeNext:^(id x) {
        NSLog(@"%@11", x);
    } error:^(NSError *error) {
        NSLog(@"%@22", error);
    } completed:^{
        NSLog(@"%@33", @"completed");
    }];
    
    CFRunLoopRun();
}

- (void)testRKObjectRequestOperatonRACSuccessful {
    NSString *url = @"http://localhost:3000";
    NSURL *baseUrl = [[NSURL alloc] initWithString:url];
    NSString *getPath1 = @"/user";
    RKObjectManager *manager = [RKObjectManager managerWithBaseURL:baseUrl];
    [RKMIMETypeSerialization registerClass:[RKNSJSONSerialization class] forMIMEType:@"text/plain"];
    NSURLRequest *request = [manager requestWithObject:nil method:RKRequestMethodGET path:getPath1 parameters:nil];
    RKObjectMapping *mapping1 = [RKObjectMapping mappingForClass:[RKDemoUserInfo class]];
    [mapping1 addAttributeMappingsFromArray:@[@"userId", @"balance"]];
    
    [mapping1 addAttributeMappingsFromDictionary:@{@"version":@"name", @"status":@"password"}];
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping1 method:RKRequestMethodGET pathPattern:@"/user" keyPath:@"data" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [manager addResponseDescriptor:responseDescriptor];
    
    RKObjectRequestOperation *operation = [[RKObjectRequestOperation alloc] initWithRequest:request responseDescriptors:manager.responseDescriptors];
    void (^originalSuccess)(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) = ^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        NSLog(@"originalSuccess, original Maping Result: %@", mappingResult);
        CFRunLoopRef runLoopRef = CFRunLoopGetCurrent();
        CFRunLoopStop(runLoopRef);
    };
    
    void (^originalFailure)(RKObjectRequestOperation *operation, NSError *error) = ^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"originalFailure");
        CFRunLoopRef runLoopRef = CFRunLoopGetCurrent();
        CFRunLoopStop(runLoopRef);
    };
    
    [operation setCompletionBlockWithSuccess:originalSuccess failure:originalFailure];
    
    RACSignal *signal = [operation rac_enqueueInManager:manager];
    for (int i = 100; i < 150; i ++) {
        [signal subscribeNext:^(id x) {
            NSLog(@"%@ %d", x, i);
            if ([x isKindOfClass:[RKObjectRequestOperation class]]) {
                RKObjectRequestOperation *operation = x;
                NSLog(@"Mapping Result %d : %@", i, operation.mappingResult);
            }
        } error:^(NSError *error) {
            NSLog(@"%@ %d", error, i);
        } completed:^{
            NSLog(@"%@ %d", @"completed", i);
        }];
    }
    
    for (int i = 100; i < 150; i ++) {
        RACSignal *anotherSignal = [operation rac_enqueueInManager:manager];
        [anotherSignal subscribeNext:^(id x) {
            NSLog(@"anotherSignal %@ %i", x, i);
            if ([x isKindOfClass:[RKObjectRequestOperation class]]) {
                RKObjectRequestOperation *operation = x;
                NSLog(@"anotherSignal Mapping Result %d : %@", i, operation.mappingResult);
            }
        } error:^(NSError *error) {
            NSLog(@"%@ anotherSignal i", error);
        } completed:^{
            NSLog(@"%@ anotherSignal i", @"completed");
        }];
    }
    
    CFRunLoopRun();
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

- (void)showResult:(BOOL)isSuccess operation:(RKObjectRequestOperation *)operation result:(RKMappingResult *)result error:(NSError *)error {
//    NSString *title = isSuccess ? @"请求成功" : @"请求失败";
//    RKErrorMessage *errorMessage =  [[error.userInfo objectForKey:RKObjectMapperErrorObjectsKey] firstObject];
//    NSString *message = isSuccess ? [NSString stringWithFormat:@"请求成功的结果信息: %@", result] : [NSString stringWithFormat:@"错误信息: %@, error Message信息: %@", [error localizedDescription], errorMessage];
//    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//    [alertView show];
}

- (void)showResultSilently:(BOOL)isSuccess operation:(RKObjectRequestOperation *)operation result:(RKMappingResult *)result error:(NSError *)error {
    NSString *title = isSuccess ? @"请求成功" : @"请求失败";
    RKErrorMessage *errorMessage =  [[error.userInfo objectForKey:RKObjectMapperErrorObjectsKey] firstObject];
    NSString *message = isSuccess ? [NSString stringWithFormat:@"请求成功的结果信息: %@", result] : [NSString stringWithFormat:@"错误信息: %@, error Message信息: %@", [error localizedDescription], errorMessage];
    
    NSLog(@"title: %@ error Message: %@", title, message);
    
//    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//    [alertView show];
}


@end
