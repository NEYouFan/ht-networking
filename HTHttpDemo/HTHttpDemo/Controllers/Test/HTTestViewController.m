//
//  HTTestViewController.m
//  HTHttpDemo
//
//  Created by Wangliping on 16/2/1.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#import "HTTestViewController.h"
#import "HTHttpModelTestController.h"
#import "RKDemoUserInfo.h"
#import "HTNetworking.h"
#import <HTNetworking/Core/HTMockHTTPRequestOperation.h>
#import "HTBaseRequestTestViewController.h"

@interface HTTestViewController ()

@end

@implementation HTTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.navigationItem.title = @"测试界面";
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
    return @[@"getUserInfoFromServerWithComments",
             @"gotoModelTest",
             @"testYYModelPerformance",
             @"testYYModelUnsupportType",
             @"testDerivedModel",
             @"testCategoryModel",
             @"testWithOldResponseDescriptor",
             @"testRequestWithNewDescriptor",
             @"testUndefinedKey",
             @"testRequestToJSON",
             @"testRequestParams",
             @"testRequestParamsPerformance",
             @"testModelWithRestKit",
             @"testModelWrapperWithRestKit",
             @"testSpecialModel",
             @"testInvalidRequestDescriptor",
             @"testInvalidModel",
             @"testParamsValidation",
             @"testHTBaseRequest",
             @"testMaxUndefined"];
}

#pragma mark - Test Methods

/**
 *  展示通过RKObjectManager发起请求的基本步骤与工作流程. 同HTRKDemoViewController中getUserInfo.
 *  示例Server与设置方法参见: https://git.hz.netease.com/hzwangliping/TrainingServer
 *  请求信息: Method: GET URL: http://localhost:3000/user. 返回数据: MIMEType:@"text/plain"
 *  正确返回时JSON数据为: {"data":{"userId":1854002,"balance":500,"updateTime":1429515081463,"version":26,"status":0,"blockBalance":600},"code":200}
 *  错误返回时JSON数据为: {"errorMessage":"It is a test error msg", "code":200}
 *  可以统一JSON格式为: {errorMessage:"asdfadfsa", "data":{...}, code=404}
 */
- (void)getUserInfoFromServerWithComments {
    // 服务器返回的Json为
    // {"data":{"userId":1854002,"balance":500,"updateTime":1429515081463,"version":26,"status":0,"blockBalance":600},"code":200}
    // {errorMessage:"asdfadfsa", "data":{...}, code=404}
    RKObjectMapping *mapping1 = [RKObjectMapping mappingForClass:[RKDemoUserInfo class]];
    [mapping1 addAttributeMappingsFromArray:@[@"userId", @"balance"]];
    
    // 类型不匹配也可以正确解析.
    [mapping1 addAttributeMappingsFromDictionary:@{@"version":@"name", @"status":@"password"}];
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping1 method:RKRequestMethodGET pathPattern:@"/user" keyPath:@"data" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    // 经过测试，服务器一定要加上错误的status code才会到出错分支中.
    // Note: 如果返回的是错误的status code; 那么AFNetworking 2.0里面就会报错；但是这个时候就不会去做Mapping了; 所以这个也要处理掉.
    // 调试结果1: 必须要屏蔽掉AFNetworking 2.0对于Response的校验，才可以让ErrorResponseDescriptor走到Error分支；
    // 调试结果2：在1的基础上，仍然要求status code > 200 才可以；否则仍然会报成功. 因为是根据StatusCode来决定是否走到错误分支的.
    // 现有的代码已经处理掉该问题. 解决方法是将RKHTTPRequestOperation的responseSerializer设置为空.
    RKObjectMapping *errorMapping = [RKObjectMapping mappingForClass:[RKErrorMessage class]];
    [errorMapping addPropertyMapping:[RKAttributeMapping attributeMappingFromKeyPath:nil toKeyPath:@"errorMessage"]];
    RKResponseDescriptor *errorResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:errorMapping method:RKRequestMethodGET pathPattern:nil keyPath:@"code" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassClientError)];
    
    RKObjectManager *manager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:@"http://localhost:3000"]];
    [manager addResponseDescriptor:responseDescriptor];
    [manager addResponseDescriptor:errorResponseDescriptor];
    
    [RKMIMETypeSerialization registerClass:[RKNSJSONSerialization class] forMIMEType:@"text/plain"];
    // 如果需要解析XML的话，还必须加上RKXMLReaderSerialization. 否则无法解析xml.
    // 参见：
    // http://stackoverflow.com/questions/14876495/restkit-response-in-text-xml
    // RestKit 0.20.0rc1 does not include an XML serializer in the main repository, but you can find one here: RKXMLReaderSerialization.
    // 这个使用是为了解析Response用的.
    //  [RKMIMETypeSerialization registerClass:[RKXMLReaderSerialization class] forMIMEType:@"application/xml"];
    
    // 返回数据中code错误（非http status code），也自动走到error分支的支持方法: 对于manager设置validResultBlock即可.
#warning 支持将错误信息统一成NSError对象，机制要在严选中使用
    [manager getObject:nil path:@"/user" parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        NSLog(@"success");
        [self showResult:YES operation:operation result:mappingResult error:nil];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"failure");
        
        NSLog(@"Loaded this error: %@", [error localizedDescription]);
        // You can access the model object used to construct the `NSError` via the `userInfo`
        RKErrorMessage *errorMessage =  [[error.userInfo objectForKey:RKObjectMapperErrorObjectsKey] firstObject];
        NSLog(@"%@", errorMessage);
        
        [self showResult:NO operation:operation result:nil error:error];
    }];
}



- (void)getUserInfoWithWrongResponseDescriptor {
    // 服务器返回的Json为
    // {"data":{"userId":1854002,"balance":500,"updateTime":1429515081463,"version":26,"status":0,"blockBalance":600},"code":200}
    
    // Note: 当Response Descriptor不正确时, mapping result为空，但是不会报错. 暂时不处理这种情况，由调用者自己传递block来校验是否结果有效.
    RKObjectMapping *mapping1 = [RKObjectMapping mappingForClass:[RKDemoUserInfo class]];
    //    [mapping1 addAttributeMappingsFromArray:@[@"userId", @"balance"]];
    
    // 类型不匹配也可以正确解析.
    [mapping1 addAttributeMappingsFromDictionary:@{@"version1":@"name", @"status1":@"password"}];
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping1 method:RKRequestMethodGET pathPattern:@"/user" keyPath:@"data" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    // 经过测试，是一定要加上错误的status code才会到出错分支中.
    // 如果返回的是错误的status code; 那么AFNetworking 2.0里面就会报错；但是这个时候就不会去做Mapping了; 所以这个也要处理掉.
    // 调试结果1: 必须要屏蔽掉AFNetworking 2.0对于Response的校验，才可以让ErrorResponseDescriptor走到Error分支；
    // 调试结果2：在1的基础上，仍然要求status code > 200 才可以；否则仍然会报成功. 因为是根据StatusCode来决定是否走到错误分支的.
    // 现有的代码已经处理掉该问题. 解决方法是将RKHTTPRequestOperation的responseSerializer设置为空.
    RKObjectMapping *errorMapping = [RKObjectMapping mappingForClass:[RKErrorMessage class]];
    [errorMapping addPropertyMapping:[RKAttributeMapping attributeMappingFromKeyPath:nil toKeyPath:@"errorMessage"]];
    RKResponseDescriptor *errorResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:errorMapping method:RKRequestMethodGET pathPattern:nil keyPath:@"code" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassClientError)];
    
    RKObjectManager *manager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:@"http://localhost:3000"]];
    [manager addResponseDescriptor:responseDescriptor];
    [manager addResponseDescriptor:errorResponseDescriptor];
    
    [RKMIMETypeSerialization registerClass:[RKNSJSONSerialization class] forMIMEType:@"text/plain"];
    // Note: 如果需要解析XML的话，还必须加上RKXMLReaderSerialization. 否则无法解析xml.
    // 参见：http://stackoverflow.com/questions/14876495/restkit-response-in-text-xml
    // RestKit 0.20.0rc1 does not include an XML serializer in the main repository, but you can find one here: RKXMLReaderSerialization.
    // 这个使用是为了解析Response用的.
    //  [RKMIMETypeSerialization registerClass:[RKXMLReaderSerialization class] forMIMEType:@"application/xml"];
    
    [manager getObject:nil path:@"/user" parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        NSLog(@"success");
        [self showResult:YES operation:operation result:mappingResult error:nil];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"failure");
        
        NSLog(@"Loaded this error: %@", [error localizedDescription]);
        // You can access the model object used to construct the `NSError` via the `userInfo`
        RKErrorMessage *errorMessage =  [[error.userInfo objectForKey:RKObjectMapperErrorObjectsKey] firstObject];
        NSLog(@"%@", errorMessage);
        
        [self showResult:NO operation:operation result:nil error:error];
    }];
}

// TODO: 这里需要加到Advanced Feature Demo中.
- (void)getUserInfoWithValidBlock {
    // 服务器返回的Json为
    // {"data":{"userId":1854002,"balance":500,"updateTime":1429515081463,"version":26,"status":0,"blockBalance":600},"code":200}
    
    // Note: 当Response Descriptor不正确时, mapping result为空，但是不会报错. 本方法给Manager加上validBlock来将mapping result为空的case或者仅有Error Msg的case转到错误分支上.
    RKObjectMapping *mapping1 = [RKObjectMapping mappingForClass:[RKDemoUserInfo class]];
    //    [mapping1 addAttributeMappingsFromArray:@[@"userId", @"balance"]];
    
    // 类型不匹配也可以正确解析.
    [mapping1 addAttributeMappingsFromDictionary:@{@"version1":@"name", @"status1":@"password"}];
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping1 method:RKRequestMethodGET pathPattern:@"/user" keyPath:@"data" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    // 经过测试，是一定要加上错误的status code才会到出错分支中.
    // 如果返回的是错误的status code; 那么AFNetworking 2.0里面就会报错；但是这个时候就不会去做Mapping了; 所以这个也要处理掉.
    // 调试结果1: 必须要屏蔽掉AFNetworking 2.0对于Response的校验，才可以让ErrorResponseDescriptor走到Error分支；
    // 调试结果2：在1的基础上，仍然要求status code > 200 才可以；否则仍然会报成功. 因为是根据StatusCode来决定是否走到错误分支的.
    // 现有的代码已经处理掉该问题. 解决方法是将RKHTTPRequestOperation的responseSerializer设置为空.
    
    // 更新：搜索RKErrorStatusCodes()可以发现，如果HTTP Status code不在200到400之间，那么一定会走到错误回调；如果在200到400之间，仍然会走到success回调.
    // 这个逻辑与ResponseDescriptor以及Error Descriptor并没有任何关系. Response Descriptor的status code只是表明status code在这一区间内是否会被解析.
    
    // 新的需求，例如，ww有需求说，status code为502的时候还希望拿到解析的结果，那么首先，对应的response descriptor对应的statusCodes不应该仅仅局限于2xx, 可以设置为nil, 也可以自己手动加NSIndexSet.
    // 其次，这个时候还是会走到error的回调，但是error的回调里面，可以通过[error.userInfo objectForKey:RKObjectMapperErrorObjectsKey]获取到map后的结果.
    // 再次，最后会考虑是否在这种情况下也允许用户手动控制走error还是success分支. (但是感觉这样的话，太危险, 所以暂不考虑)
    RKObjectMapping *errorMapping = [RKObjectMapping mappingForClass:[RKErrorMessage class]];
    [errorMapping addPropertyMapping:[RKAttributeMapping attributeMappingFromKeyPath:nil toKeyPath:@"errorMessage"]];
    RKResponseDescriptor *errorResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:errorMapping method:RKRequestMethodGET pathPattern:nil keyPath:@"code" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassClientError)];
    
    RKObjectManager *manager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:@"http://localhost:3000"]];
    [manager addResponseDescriptor:responseDescriptor];
    [manager addResponseDescriptor:errorResponseDescriptor];
    
    // 这个默认的block已经以Helper的方式提供出来. 可以参见HTOperationHelper中的defaultValidResultBlock.
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
    
    [RKMIMETypeSerialization registerClass:[RKNSJSONSerialization class] forMIMEType:@"text/plain"];
    // 如果需要解析XML的话，还必须加上RKXMLReaderSerialization. 否则无法解析xml.
    // 参见：http://stackoverflow.com/questions/14876495/restkit-response-in-text-xml
    // RestKit 0.20.0rc1 does not include an XML serializer in the main repository, but you can find one here: RKXMLReaderSerialization.
    // 这个使用是为了解析Response用的.
    //  [RKMIMETypeSerialization registerClass:[RKXMLReaderSerialization class] forMIMEType:@"application/xml"];
    
    [manager getObject:nil path:@"/user" parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        NSLog(@"success");
        [self showResult:YES operation:operation result:mappingResult error:nil];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"failure");
        
        NSLog(@"Loaded this error: %@", [error localizedDescription]);
        // You can access the model object used to construct the `NSError` via the `userInfo`
        RKErrorMessage *errorMessage =  [[error.userInfo objectForKey:RKObjectMapperErrorObjectsKey] firstObject];
        NSLog(@"%@", errorMessage);
        
        [self showResult:NO operation:operation result:nil error:error];
    }];
}


- (void)getUserInfoMockTest {
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
    [manager registerRequestOperationClass:[HTMockHTTPRequestOperation class]];
    
    NSURLRequest *request = [manager requestWithObject:nil method:RKRequestMethodGET path:@"/user" parameters:nil];
    request.ht_mockBlock = ^(NSURLRequest *mockRequest) {
        //        mockRequest.ht_mockError = nil;
        mockRequest.ht_mockResponseObject = @{@"data":@{@"status":@"It is password", @"userId" : @(123456), @"version" : @"It is myName"}};
    };
    
    RKObjectRequestOperation *operation = [manager objectRequestOperationWithRequest:request success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        NSLog(@"success");
        
        [self showResult:YES operation:operation result:mappingResult error:nil];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        // You can access the model object used to construct the `NSError` via the `userInfo`
        RKErrorMessage *errorMessage =  [[error.userInfo objectForKey:RKObjectMapperErrorObjectsKey] firstObject];
        NSLog(@"%@", errorMessage);
        
        [self showResult:NO operation:operation result:nil error:error];
    }];
    
    [operation start];
}



#pragma mark - 流程调试代码

// 关于全路径的问题.
// 首先, 请求path需要写全路径.
// 剩下的就是path pattern和responseDescriptor的baseURL的问题.
// 如果path pattern为全路径，baseURL不是；那么在比对BaseURL的时候失败，找不到可用的ResponseMapping Descriptor
// 如果path pattern不为全路径，baseURL是，对应的response Descritor都为空.
// 如果path pattern为全路径，baseURL为空，那么URL比对OK, path pattern比对不成功.

// 如果请求的是全路径，并且和baseURL不匹配，此时如果response Descriptor的path pattern不是全路径，则request operation的response Descriptor为空.

// 原因似乎是由于_COREDATADEFINES_H定义了，所以会事先对response Descriptor作一个过滤; 如果不作过滤，path pattern 可以不为全路径.
// 在这种情况下，Response Descriptor里面的path Pattern是一定要包含getObject时传的path.....; 否则operation就没有response Descriptor了.
// _COREDATADEFINES_H是在CoreDataDefines.h中定义的；也就是在CoreData.h中定义的.
// 不明白为什么定义了CoreData后就一定要做过滤.....

// 根据现在的代码要求：
// 1 responseDescriptor的path pattern一定要包含 getObject的path. 否则response Descriptor不会赋值给request Operation. 对应的方法为RKFilteredArrayOfResponseDescriptorsMatchingPathAndMethod(self.responseDescriptors, path, method);
// 2 buildMatchingResponseDescriptors -- > - (BOOL)matchesURL:(NSURL *)URL parsedArguments:(NSDictionary **)outParsedArguments
// 要求请求的URL, baseURL, pathPattern三个是可以对应上的.
// 问题在于，如果baseURL传空, 那么会从请求的URL里面取参数“/user”, 判断这个"/user"是否对应path pattern, 这个时候，是不对应的，因为path pattern要比/user长，是一个全路径;
// 如果baseURL和path pattern等等一样，那么参数pathAndQueryString为空，判断这个空是否对应path pattern也是不正确的.

- (void)loadDifferentBaseUrl {
    RKObjectMapping *mapping1 = [RKObjectMapping mappingForClass:[RKDemoUserInfo class]];
    [mapping1 addAttributeMappingsFromArray:@[@"userId", @"balance"]];
    
    // 类型不匹配也可以正确解析.
    [mapping1 addAttributeMappingsFromDictionary:@{@"version":@"name", @"status":@"password"}];
    RKResponseDescriptor *responseDescriptor1 = [RKResponseDescriptor responseDescriptorWithMapping:mapping1 method:RKRequestMethodGET pathPattern:@"/user" keyPath:@"data" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    // 经过测试，是一定要加上错误的status code才会到出错分支中.
    RKObjectManager *manager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:@"http://baidu:3000"]];
    [manager addResponseDescriptor:responseDescriptor1];
    //    responseDescriptor1.baseURL = nil;
    responseDescriptor1.baseURL = [NSURL URLWithString:@"http://localhost:3000"];
    
    [RKMIMETypeSerialization registerClass:[RKNSJSONSerialization class] forMIMEType:@"text/plain"];
    
    NSURLRequest *request = [manager requestWithObject:nil method:RKRequestMethodGET path:@"http://localhost:3000/user" parameters:nil];
    RKObjectRequestOperation *operation = [manager objectRequestOperationWithRequest:request success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        NSLog(@"success");
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"failure");
        
        NSLog(@"Loaded this error: %@", [error localizedDescription]);
        
        // You can access the model object used to construct the `NSError` via the `userInfo`
        RKErrorMessage *errorMessage =  [[error.userInfo objectForKey:RKObjectMapperErrorObjectsKey] firstObject];
        NSLog(@"%@", errorMessage);
    }];
    [manager enqueueObjectRequestOperation:operation];
    
    // 如果不过滤RequestOperation的ResponseDescriptor, 那么按照上面的用法是可以通过的.
    // 所以主要就变成三步修改:
    // 1 不要过滤requestOperation的ResponseDecriptor; Operation直接拿到RKObjectManager的ResponseDescriptor;
    // 2 responseDescriptor的baseURL设置为空 或者 实际的baseURL @"http://localhost:3000"
    // 但是一定不可以用RKObjectManager的baseURL; 也不可以用全路径.
    // 3 请求的时候给全路径.
}

- (void)gotoModelTest {
    HTHttpModelTestController *vc = [[HTHttpModelTestController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)testParamsValidation {
    
}

- (void)testHTBaseRequest {
    HTBaseRequestTestViewController *vc = [[HTBaseRequestTestViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
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
