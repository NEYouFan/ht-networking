# HTHTTP 快速使用文档

----

## 基本使用方法
HTHTTP框架在上层封装了一个名为`HTBaseRequest`的类作为网络请求的基类，SDK的使用者只需要为每一种请求创建一个HTBaseRequest的子类，然后在发送该请求的时候实例化对应子类的对象即可。

第一步:
必须事先配置后要使用的RKObjectManager, 这一步需要在发送所有的请求之前做；建议可以在应用启动的时候就完成该工作. 例如:
    
    NSURL *baseURL = [NSURL URLWithString:@"http://localhost:3000"];
    RKObjectManager *manager = [HTNetworkAgentHelper defaultRKObjectManagerWithURL:baseURL errorMsgKeyPath:@"code"];
    
    // 如果有需要，可以在这里对manager进行配置, 例如编码方式等等.
    // 例如，返回数据的MIMEType为@"text/plain", 实际的数据格式为JSON, 则加上下面的代码：
    // 如果实际返回的MIMEType即为@"application/json"; 那么不需要这种处理；
	[RKMIMETypeSerialization registerClass:[RKNSJSONSerialization class] forMIMEType:@"text/plain"];
    
    // 表明HTNetworkAgent只使用这一个manager进行请求的发送.
    [HTNetworkAgent setupWithObjectManager:manager];
    
第二步: 根据请求的类型实现一个HTBaseRequest的子类，并且指定请求的url，参数, responseMapping等等.
例如，假定有对如下请求: 

Method: GET URL: http://localhost:3000/user. 返回JSON数据为: 

	{"data":{"userId":1854002,"balance":500,"updateTime":1429515081463,"version":26,"status":0,"blockBalance":600},"code":200}

那么对该请求描述的一个类一个简单的GET请求的子类定义与实现如下:

	@interface HTDemoGetUserInfoRequest : HTBaseRequest
	
	@end

	@implementation HTDemoGetUserInfoRequest
	
	+ (NSString *)requestUrl {
	    return @"/user";
	}
	
	+ (RKMapping *)responseMapping {
	    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[RKDemoUserInfo class]];
	    [mapping addAttributeMappingsFromArray:@[@"userId", @"balance", @"version"]];
	    [mapping addAttributeMappingsFromDictionary:@{@"version":@"name", @"status":@"password"}];
	
	    return mapping;
	}
	
	+ (NSString *)keyPath {
	    return @"data";
	}
	
	@end

从上面的实现代码中我们可以看到这个子类指定了请求的path为/user, 并且指定了返回的JSON结果的Mapping对象，会和RKDemoUserInfo进行映射. 这里对映射的描述既可以通过responseMapping, pathPattern和keyPath来描述，也可以通过自己创建的ResponseDescriptor来描述; 根据通常的使用情况，使用responseMapping进行描述即可，pathPattern一般与requestUrl完全相同，不需要额外描述；keyPath返回的是JSON返回数据中业务数据的key, responseMapping方法中使用到的Model类与业务数据的JSON描述对应。

如果JSON的key值与Model类的属性一一对应，那么方法`responseMapping`可以简化为:
	
	+ (RKMapping *)responseMapping {
		return [RKDemoUserInfo ht_modelMapping];
	}

实际使用过程中，我们都会根据返回的JSON数据的格式与内容来定义这个Model类`RKDemoUserInfo`; 因此一般情况下会保证JSON的key值与Model类的属性一一对应.

同理，一个简单的带参数的POST请求的子类实现如下：

	@implementation HTDemoGetUserPhotoListRequest
	
	- (RKRequestMethod)requestMethod {
	    return RKRequestMethodPOST;
	}
	
	+ (NSString *)requestUrl {
	    return @"/collection";
	}
	
	- (NSDictionary *)requestParams {
	    return @{@"name":@"lwang", @"password":@"test", @"type":@"photolist"};
	}
	
	+ (RKMapping *)responseMapping {
		return [HTDemoPhotoInfo ht_modelMapping];
	}
	
	+ (NSString *)keyPath {
	    return @"photolist";
	}

	@end

这里是指明了这是一个POST请求，然后告知了请求的path和参数.

发送请求的示例代码如下, 从mappingResult中可以根据keyPath获取到数据.

    HTDemoGetUserPhotoListRequest *request = [[HTDemoGetUserPhotoListRequest alloc] init];
    [request startWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
		// 成功的回调
		// 获取映射后的结果. keyPath与
		NSString *keyPath = @"photolist";
		NSObject *result = [mappingResult.dictionary objectForKey:keyPath];
		
		// 下面的方法展示如何获取不同层面的返回结果.
        NSLog(@"Response Object: %@, Response String; %@, URL: %@, response Header : %@", operation.responseObject, operation.HTTPRequestOperation.responseString, operation.HTTPRequestOperation.request.URL.absoluteString, operation.HTTPRequestOperation.response.allHeaderFields);
        NSLog(@"HTTP BODY: %@, response Data : %@", operation.HTTPRequestOperation.request.HTTPBody, operation.HTTPRequestOperation.responseData);
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
		// 失败的回调
    }];

## 如何写responseMapping
从上一节可以看出，描述一个请求的重点在于如何描述返回的JSON数据与待映射的Model之间的关系；本教程描述推荐的一般做法；

### 方案一 使用HTHTTPModel
1. 待映射的Model类从HTHTTPModel的子类派生；
2. 如果该Model的定义存在集合的嵌套，例如存在如下属性:

		@property (nonatomic, strong) NSArray<HTDemoSubscriber *> *subscribers;
	
	那么需要实现如下方法, 其中，key为属性名，value为NSArray中每个Item的类型名. 如果Item的类型为基本类型，则不需要实现该方法.

		+ (NSDictionary *)collectionCustomObjectTypes {
		    return @{@"subscribers" : @"HTDemoSubscriber"};
		}

	说明：需要手动实现该方法的原因是，通过runtime无法取到类定义中数组中每个Item的类型信息.
3.  responseMapping写法如下:

	+ (RKMapping *)responseMapping {
		return [HTDemoPhotoInfo defaultResponseMapping];
	}

### 方案二 使用ht_modelMapping
如果没有Collection类型的嵌套，即不存在某个Model的属性类型数组类型并且数组中每个Item类型是另一个Model类，那么定义Model时保证JSON Key与Model属性名一一对应即可，responseMapping写法如下:

	+ (RKMapping *)responseMapping {
		return [HTDemoPhotoInfo ht_modelMapping];
	}
	
注意：需要包含头文件: `NSObject+HTMapping.h`	

### 方案三 手写responseMapping

	+ (RKMapping *)responseMapping {
	    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[RKDemoUserInfo class]];
	    [mapping addAttributeMappingsFromArray:@[@"userId", @"balance", @"version"]];
	    
	    // key对应JSON key, value对应RKDemoUserInfo中的属性定义.
	    [mapping addAttributeMappingsFromDictionary:@{@"version":@"name", @"status":@"password"}];
	
	    return mapping;
	}

复杂的描述请直接参阅[如何写rkrequestdescriptor与rkresponsedescriptor.md](如何写rkrequestdescriptor与rkresponsedescriptor.md) 或者 [RestKit官方文档](https://github.com/RestKit/RestKit/wiki/Object-mapping)

## Demo

Demo在当前代码仓库中，参见https://git.hz.netease.com/open/HTHttp/tree/master/HTHttpDemo.

Demo简要说明：

1. [HTRKDemoViewController.m](https://git.hz.netease.com/open/HTHttp/blob/develop/HTHttpDemo/HTHttpDemo/Controllers/HTRKDemoViewController.m) 展示如何通过RKObjectMananger这一层发送请求；
2. [HTBaseRequestDemoViewController.m](https://git.hz.netease.com/open/HTHttp/blob/develop/HTHttpDemo/HTHttpDemo/Controllers/HTBaseRequestDemoViewController.m) 展示如何通过High Level的封装更简单的发送请求；
3. [HTRACDemoViewController.m](https://git.hz.netease.com/open/HTHttp/blob/develop/HTHttpDemo/HTHttpDemo/Controllers/HTRACDemoViewController.m) 展示如何结合ReactiveCocoa进行请求的调度；
4. [HTCacheDemoViewController.m](https://git.hz.netease.com/open/HTHttp/blob/develop/HTHttpDemo/HTHttpDemo/Controllers/HTCacheDemoViewController.m) 展示如何灵活运用cache相关功能；
5. [HTFreezeDemoViewController.m](https://git.hz.netease.com/open/HTHttp/blob/develop/HTHttpDemo/HTHttpDemo/Controllers/HTFreezeDemoViewController.m) 展示如何使用冻结请求相关的功能；

重点是`HTBaseRequestDemoViewController.m`中的示例.