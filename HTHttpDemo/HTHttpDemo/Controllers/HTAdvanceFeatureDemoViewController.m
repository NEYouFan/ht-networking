//
//  HTAdvanceFeatureDemoViewController.m
//  HTHttpDemo
//
//  Created by Wangliping on 16/2/2.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#import "HTAdvanceFeatureDemoViewController.h"
#import "RKDemoUserInfo.h"

@interface HTAdvanceFeatureDemoViewController ()

@end

@implementation HTAdvanceFeatureDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.title = @"Advanced Feature Demo";
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
    return @[@"demoExtendMIMEType",
             @"demoHTHTTPModel",
             @"demoWrapStatusCodeIntoNSError"];
}

#pragma mark - 

/**
 *  Demo: 展示当返回的结果实际是JSON, 但是MIME Type不正确时如何处理; 以及展示自定义的MIME Type以及返回数据格式时，如何自行扩展以支持自定义格式数据的反序列化.
 */
- (void)demoExtendMIMEType {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[RKDemoUserInfo class]];
    [mapping addAttributeMappingsFromDictionary:@{@"version1":@"name", @"status1":@"password"}];
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping method:RKRequestMethodGET pathPattern:@"/user" keyPath:@"data" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    // 创建并配置RKObjectManager.
    RKObjectManager *manager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:@"http://localhost:3000"]];
    [manager addResponseDescriptor:responseDescriptor];
    
    // 例1: MIME Type为@"text/plain"而实际数据格式为JSON.
    [RKMIMETypeSerialization registerClass:[RKNSJSONSerialization class] forMIMEType:@"text/plain"];
    
    // 例2：引入RKXMLReaderSerialization解析xml, 用于实际返回的数据格式为xml的case.
    // 参见：http://stackoverflow.com/questions/14876495/restkit-response-in-text-xml
    // RestKit 0.20.0rc1 does not include an XML serializer in the main repository, but you can find one here: RKXMLReaderSerialization(https://github.com/RestKit/RKXMLReaderSerialization).
    // [RKMIMETypeSerialization registerClass:[RKXMLReaderSerialization class] forMIMEType:@"application/xml"];
    
    [manager getObject:nil path:@"/user" parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self showResult:YES operation:operation result:mappingResult error:nil];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self showResult:NO operation:operation result:nil error:error];
    }];
}

/**
 *  Demo: 展示如何利用HTHTTP Model的一些属性.
 */
- (void)demoHTHTTPModel {
#warning TODO: 展示如何利用HTHTTP Model的一些属性.
}

/**
 *  Demo: 展示如何将返回结果中的错误码包装到NSError中.
 *
 */
- (void)demoWrapStatusCodeIntoNSError {
#warning TODO: 当返回结果非法时，可以通过validResultBlock切换到error回调分支中，此时，如果可以在error中直接拿到错误码会更好；否则，需要通过两种不同的方式来取错误码.
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

@end
