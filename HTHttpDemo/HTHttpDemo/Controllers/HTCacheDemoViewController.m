//
//  HTCacheDemoViewController.m
//  HTHttpDemo
//
//  Created by Wangliping on 16/2/2.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#import "HTCacheDemoViewController.h"
#import "HTNetworking.h"
#import "HTDemoCustomizeRequest.h"
#import "HTCustomCachePolicy.h"
#import "HTDemoCacheIgnoreParamsRequest.h"

@interface HTCacheDemoViewController ()

@end

@implementation HTCacheDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.title = @"Cache Demo";
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
    return @[@"demoSendRequestWithCache",
             @"demoSendRequestAndRefreshCache",
             @"demoSendRequestToServerAndRefreshCache",
             @"demoSendRequestWithCacheConfig",
             @"demoSendRequestWithCustomCacheId",
             @"demoSendRequestWithCustomCachePolicy",
             @"demoCacheWithVersion",
             @"demoCacheIgnoringSomeParams",
             @"demoGetCacheSizeSync",
             @"demoClearCacheSync",
             @"demoGetCacheSizeAsync",
             @"demoClearCacheAsync"];
}

#pragma mark - Demo Methods

/**
 *  发送请求时开启Cache; 如果Cache有效，则取Cache; 否则，发送请求并将结果存入Cache.
 */
- (void)demoSendRequestWithCache {
    HTDemoCustomizeRequest *request = [[HTDemoCustomizeRequest alloc] init];
    request.cacheId = HTCachePolicyCacheFirst;
    request.cacheExpireTimeInterval = 3600;
    [request startWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self showResult:YES operation:operation result:mappingResult error:nil];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self showResult:NO operation:operation result:nil error:error];
    }];
}

/**
 *  发送请求时, 如果Cache无效，则发送请求并将结果存入Cache; 如果Cache有效，则先取Cache数据来更新页面，然后再发送请求到服务器并在获取到结果后更新Cache.
 */
- (void)demoSendRequestAndRefreshCache {
    HTDemoCustomizeRequest *request = [[HTDemoCustomizeRequest alloc] init];
    request.cacheId = HTCachePolicyCacheFirst;
    request.cacheExpireTimeInterval = 3600;
    [request startWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self showResultSilently:YES operation:operation result:mappingResult error:nil];
        if (operation.HTTPRequestOperation.response.ht_isFromCache) {
            [self requestAndRefreshCache];
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self showResultSilently:NO operation:operation result:nil error:error];
    }];
}

- (void)requestAndRefreshCache {
    HTDemoCustomizeRequest *request = [[HTDemoCustomizeRequest alloc] init];
    request.cacheId = HTCachePolicyWriteOnly;
    [request startWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self showResultSilently:YES operation:operation result:mappingResult error:nil];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self showResultSilently:NO operation:operation result:nil error:error];
    }];
}

/**
 *  发送请求时, 不使用Cache的内容，但是在从服务器获取到结果后更新Cache.
 */
- (void)demoSendRequestToServerAndRefreshCache {
    [self requestAndRefreshCache];
}

/**
 *  发送请求时使用Cache, 并对Cache进行配置.
 */
- (void)demoSendRequestWithCacheConfig {
    HTDemoCustomizeRequest *request = [[HTDemoCustomizeRequest alloc] init];
    request.cacheId = HTCachePolicyCacheFirst;
    request.cacheExpireTimeInterval = 3600;
    
    // Demo: Following code show how to config cache.
    request.customCacheKey = @"It is a special cache key";
    
    [request startWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self showResult:YES operation:operation result:mappingResult error:nil];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self showResult:NO operation:operation result:nil error:error];
    }];
}

/**
 *  发送请求时使用Cache, 并且手动设置特定的CacheId.
 */
- (void)demoSendRequestWithCustomCacheId {
    HTDemoCustomizeRequest *request = [[HTDemoCustomizeRequest alloc] init];
    // 设置cache Id.
    request.cacheId = HTCachePolicyCacheFirst;
    request.cacheExpireTimeInterval = 3600;
    
    [request startWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self showResult:YES operation:operation result:mappingResult error:nil];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self showResult:NO operation:operation result:nil error:error];
    }];
}

/**
 *  发送请求时使用Cache, 并且使用自定义的Cache策略.
 */
- (void)demoSendRequestWithCustomCachePolicy {
    [[HTCachePolicyManager sharedInstance] registeCachePolicyWithPolicyId:(HTCachePolicyUserDefined + 1) policy:[HTCustomCachePolicy class]];
    
    HTDemoCustomizeRequest *request = [[HTDemoCustomizeRequest alloc] init];
    // 设置cache Id.
    request.cacheId = HTCachePolicyUserDefined + 1;
    request.cacheExpireTimeInterval = 3600;
    
    [request startWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self showResult:YES operation:operation result:mappingResult error:nil];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self showResult:NO operation:operation result:nil error:error];
    }];
}

/**
 *  发送请求时开启Cache, 并且配置不同的版本号，当版本号不同时视为未命中Cache.
 */
- (void)demoCacheWithVersion {
    HTDemoCustomizeRequest *request = [[HTDemoCustomizeRequest alloc] init];
    // 设置cache Id.
    request.cacheId = HTCachePolicyCacheFirst;
    request.cacheExpireTimeInterval = 3600;
    request.cacheSensitiveData = [[NSBundle mainBundle] infoDictionary][@"CFBundleVersion"];
    
    [request startWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self showResult:YES operation:operation result:mappingResult error:nil];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self showResult:NO operation:operation result:nil error:error];
    }];
}

/**
 *  发送请求时开启Cache, 并且忽略部分参数；即：当被忽略的参数有不同的值时，仍然视为命中Cache.
 *  实现参见HTDemoCacheIgnoreParamsRequest中覆写的基类方法- (NSDictionary *)cacheKeyFilteredRequestParams:(NSDictionary *)params.
 */
- (void)demoCacheIgnoringSomeParams {
    HTDemoCacheIgnoreParamsRequest *request = [[HTDemoCacheIgnoreParamsRequest alloc] init];
    [request startWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self showResult:YES operation:operation result:mappingResult error:nil];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self showResult:NO operation:operation result:nil error:error];
    }];
}

/**
 *  同步获取Cache的大小.
 */
- (void)demoGetCacheSizeSync {
    HTCacheManager *cacheManager = [HTCacheManager sharedManager];
    NSUInteger cacheSize = [cacheManager getCurCacheSize];
    NSLog(@"cacheSize is %@", @(cacheSize));
}

/**
 *  同步的清除Cache.
 */
- (void)demoClearCacheSync {
    // It is not supported as we shall always clear cache async.
}

/**
 *  异步的获取Cache的大小.
 */
- (void)demoGetCacheSizeAsync {
    HTCacheManager *cacheManager = [HTCacheManager sharedManager];
    [cacheManager calculateSizeWithCompletionBlock:^(NSUInteger cacheSize) {
        NSLog(@"cache size is %@", @(cacheSize));
    }];
}

/**
 *  异步的清除Cache.
 */
- (void)demoClearCacheAsync {
    HTCacheManager *cacheManager = [HTCacheManager sharedManager];
    [cacheManager removeAllCachedResponsesOnCompletion:^{
        NSLog(@"Clear Cache Mannager Successfully");
    }];
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
    NSString *title = isSuccess ? @"请求成功" : @"请求失败";
    RKErrorMessage *errorMessage =  [[error.userInfo objectForKey:RKObjectMapperErrorObjectsKey] firstObject];
    NSString *message = isSuccess ? [NSString stringWithFormat:@"请求成功的结果信息: %@", result] : [NSString stringWithFormat:@"错误信息: %@, error Message信息: %@", [error localizedDescription], errorMessage];
    
    NSLog(@"title: %@ error Message: %@", title, message);
}

@end
